function [locat_Spo2,locat_Spo2time,locat_time,locat_simtime] =  build_spo2(pat, time_offset)


time_offset = time_offset *60;
if pat.time(end)-pat.time(1) <= 2*max(time_offset)
%     ARMS = nan(1, length(time_offset));
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
%     ARMS = nan(1, length(time_offset));
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
% ARMS = nan(1, length(time_offset));

for iter = 1:length(time_offset)
    randomizer = unifrnd(-time_offset(iter),time_offset(iter),size(timeIter));
    unifRandtime = pat.time(locat_timeIter)+randomizer;

    pos_now = interp1(pat.time,1:length(pat.time),unifRandtime,'nearest');
%     pos_now(randomizer>=0)= interp1(pat.time,1:length(pat.time),unifRandtime(randomizer>=0),'previous');

    check_pos_now = pos_now<1 | pos_now > length(pat.time) | isnan(pos_now);
    pos_now(check_pos_now) = 1;
    time_diff = abs(pat.time(pos_now) - locat_time);
    check = time_diff >= -time_offset(iter) & time_diff <= time_offset(iter);
    locat_Randtime(:,iter) = pos_now;
    locat_Spo2time(:,iter) = pat.Spo2(locat_Randtime(:,iter));
    locat_Spo2time((~check)|check_pos_now,iter)=nan;
%     invalid_time = pos_now==locat_timeIter;
%     locat_Spo2time(invalid_time,iter)=nan;
%     ARMS(iter) = ARMS_now(locat_Spo2time(locat_Spo2<=threshold,iter), locat_Spo2(locat_Spo2<=threshold));
end
locat_simtime = pat.time(locat_Randtime);

if size(locat_simtime,2) ~= length(time_offset)
    locat_simtime = locat_simtime';
end

