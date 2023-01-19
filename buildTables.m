function [tableM, timetable] =  buildTables(pat, time_offset, writeout)
%BUILDTABLES Converts the pat struct into a consumable data for analysis of
%the variability that occurs from poor data sampling. Must specify a
%time_offset array which lists the time (in minutes) for the range of which 
%the sampling will occur (e.g. within 1 minute). This is done by calling
%the build_spo2 function. Three cases as described in the manuscript are 
%then added to output table. Returns the table with nan values for all data
%outside the desired range as well as a table used to demonstrate the exact
%point from which the data sampled. This latter table is for quality
%control
%
% Elie Sarraf, Jan 19 2023

if nargin<3
    writeout = false;
end

megatable = cell(length(pat),4);
timetable = cell(length(pat),2);
% time_offset = [1/12 1/6 1/4 1/2 1 2.5 5 10];

for iter = 1:length(pat)
    [locat_Spo2,locat_Spo2time,locat_time,locat_simtime] = build_spo2(pat(iter), time_offset);
    megatable{iter,1} = repmat(pat(iter).num,[length(locat_Spo2),1]);
    megatable{iter,2} = repmat(pat(iter).dataID,[length(locat_Spo2),1]);
    megatable{iter,3} = locat_Spo2;
    megatable{iter,4} = locat_Spo2time;
    timetable{iter,1} = locat_time;
    timetable{iter,2} = locat_simtime;
end


tableM = table(vertcat(megatable{:,1}), vertcat(megatable{:,2}), vertcat(megatable{:,3}), vertcat(megatable{:,4}), ...
'VariableNames', ["PatID","CaseID", "Spo2","Measured"]);

timetable = table(vertcat(timetable{:,1}), vertcat(timetable{:,2}), ...
    'VariableNames', ["BaseTime","Measured"]);

mu = [0 -1 -sqrt(2)];
sigma = [2 2*cos(pi/6) sqrt(2)];

addSpo2Error = tableM.Spo2 + repmat(mu,height(tableM.Spo2),1)+...
    randn(height(tableM.Spo2),3).*repmat(sigma,height(tableM.Spo2),1);
addSpo2Error= array2table(addSpo2Error,'VariableNames', ["VarErr","Bias_1", "Bias_Half"]);
tableM= [tableM(:,1:3) addSpo2Error tableM(:,4)];

tableM = splitvars(tableM,"Measured",'NewVariableNames', arrayfun(@(val) strcat("Measured_", sprintf('%.2g',val)), time_offset));

%Time Table helps control for data validity
timetable = splitvars(timetable,"Measured",'NewVariableNames', arrayfun(@(val) strcat("Measured_", sprintf('%.2g',val)), time_offset));
if writeout
    writetable(tableM,'out_file.csv')
end