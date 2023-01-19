function [locat_Spo2,locat_Spo2time,locat_time,locat_simtime] =  build_spo2(pat, time_offset)
%BUILD_SPO2 Converts the pat struct into a list of arrays for analysis of
%the variability that occurs from poor data sampling. Must specify a single
%patient data strcut along with the time_offset array which lists the time 
%(in minutes) for the range of which the sampling will occur (e.g. within 1
%minute). If no idenfiable data is found, or is ouside the requested
%range, a nan valu will be returned. The property does insert a bias in
%the dataset favoring the null hypothesis, yet it is believed to be
%sufficiently small to be ignored.
%
% Elie Sarraf, Jan 19 2023

time_offset = time_offset *60;
if pat.time(end)-pat.time(1) <= 2*max(time_offset)
    locat_Spo2 = [];
    locat_Spo2time = [];
    locat_time = [];
    locat_simtime = [];
    return
end
set_val = max(600, max(time_offset));
startIter = pat.time(1)+ set_val;
endIter = pat.time(end)- set_val;
timeIter = startIter:30*60:endIter;
timeIter = unique(timeIter');
try
    locat_timeIter = interp1(pat.time,1:length(pat.time),timeIter,'nearest');
catch
    locat_Spo2 = [];
    locat_Spo2time = [];
    locat_time = [];
    locat_simtime = [];
    return
end
locat_Spo2 = pat.Spo2(locat_timeIter);
locat_time = pat.time(locat_timeIter);

locat_Randtime = nan(length(locat_timeIter), length(time_offset));
locat_Spo2time = locat_Randtime;

for iter = 1:length(time_offset)
    randomizer = unifrnd(-time_offset(iter),time_offset(iter),size(timeIter));
    unifRandtime = pat.time(locat_timeIter)+randomizer;

    pos_now = interp1(pat.time,1:length(pat.time),unifRandtime,'nearest');

    check_pos_now = pos_now<1 | pos_now > length(pat.time) | isnan(pos_now);
    pos_now(check_pos_now) = 1;
    time_diff = abs(pat.time(pos_now) - locat_time);
    check = time_diff >= -time_offset(iter) & time_diff <= time_offset(iter);
    locat_Randtime(:,iter) = pos_now;
    locat_Spo2time(:,iter) = pat.Spo2(locat_Randtime(:,iter));
    locat_Spo2time((~check)|check_pos_now,iter)=nan;
end
locat_simtime = pat.time(locat_Randtime);

if size(locat_simtime,2) ~= length(time_offset)
    locat_simtime = locat_simtime';
end

