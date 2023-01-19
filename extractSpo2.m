function pat = extractSpo2
%Extracts SpO2 Data from MIMIC-IV database on physionet. This is done by
%location all relevant CSV file, dowloading and extracting them, and
%finally loading them into one big struct for rapid analysis
%
% Elie Sarraf, Jan 19 2023
siteLink = 'https://physionet.org/files/mimic4wdb/0.1.0/';
lines = readlines(strcat(siteLink,'RECORDS'));
lines = lines(~cellfun(@isempty,lines));
pat_stuct = struct('num', nan, 'dataID', '', 'time_sample', nan, 'HR', [], 'Spo2', [], 'time', []);
pat(500) = pat_stuct;
warning('off','MATLAB:table:ModifiedAndSavedVarnames')

for line_num = 1:length(lines)
    current_line = lines(line_num);
    file_name = split(current_line,'/');
    lines2 = readlines(strcat(siteLink,current_line,'RECORDS'));
    lines2 = lines2(~cellfun(@isempty,lines2));
    for line_num2 = 1:length(lines2)
        current_line2 = lines2(line_num2);
        file_name2 = split(current_line2,'/');
        gz_file = strcat(siteLink,current_line,current_line2, 'n.csv.gz');
        try
            gunzip(gz_file,'csv')
            header_file = strcat(siteLink,current_line,current_line2, '.hea');
            header_line = readlines(header_file);
            time_val = split(header_line(2),{'/',' '});
            pat(line_num).num = file_name(2);
            pat(line_num).dataID = file_name2(end);
            pat(line_num).time_sample = time_val(5);
            file_now = readtable(strcat('csv/',file_name2(1), 'n.csv'));
            file_now = file_now(~isnan(file_now.SpO2___),{'time', 'SpO2___','Pulse_SpO2__bpm_'});
            pat(line_num).Spo2 = table2array(file_now(:,2));
            pat(line_num).HR = table2array(file_now(:,3));
            pat(line_num).time = table2array(file_now(:,1))/double(time_val(5));
            negative_val = pat(line_num).time<0;
            pat(line_num).Spo2(negative_val)=[];
            pat(line_num).HR(negative_val)=[];
            pat(line_num).time(negative_val)=[];
        catch
             disp(strcat('error: ', file_name(2),' ', file_name2(1)))
        end
    end

end


pat = pat(arrayfun(@(val) ~isempty(val.time), pat));
