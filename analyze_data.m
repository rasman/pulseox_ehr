% This is the script to run the principal analysis. The scripts assumes
% that the data has already been extracted and put into structs named "pat"
% from the MIMIC-IV database and the main table with the added errors have
% been created.
%
% 2/8/2022 Code optimzation
% Elie Sarraf, Jan 19 2023


% Run the below once to build the dataset
% pat = extractSpo2;
time_offset = [1/12 1/6 1/4 1/2 1 2.5 5 10];
% tableM = buildTables(pat, time_offset, true);


% This builds Table 1
ARMS_result = nan(4,8);
mean_result=ARMS_result;
std_result = ARMS_result;
ARMS_diff_source = nan(4,1);
mean_diff_source = nan(4,1);
std_diff_source = nan(4,1);
BA_result = nan(4,8);
for val = 3:6
    logic_force = tableM{:,val}<=95 & tableM{:,val}>=75;
    table_val = tableM(logic_force,:);

    [ARMS_result(val-2,:), mean_result(val-2,:), std_result(val-2,:)] = ARMS_now(table_val{:,7:end}, table_val{:,val});
    [ARMS_diff_source(val-2), mean_diff_source(val-2), std_diff_source(val-2)] = ARMS_now(table_val{:,3}, table_val{:,val});
    % Repeated Measures Bland Altman plot
    BA_result(val-2,:) = -diff(vertcat(arrayfun(@(val1) build_ba(table_val, val, val1, 2),7:14).loa),1,2)';
end

ARMS_print = sprintfc('%0.2f',[ARMS_diff_source ARMS_result]);
mean_print = sprintfc('(%0.2f, ',[mean_diff_source mean_result]);
std_print = sprintfc('%0.2f)',[std_diff_source std_result]);
total_print = strcat(ARMS_print,mean_print,std_print);

% Sees if caclulated values increase a fct of log(time)

val_list = [ARMS_result;mean_result;std_result;BA_result];
mdl_list = arrayfun(@(val) fitlm(log(time_offset), val_list(val,:)), 1:16,'UniformOutput', false);
lowest_rsqaured = min(cellfun(@(val) val.Rsquared.Adjusted,mdl_list));
highest_p = max(cellfun(@(val) val.Coefficients.pValue(2) ,mdl_list));

coefs =[cellfun(@(val) val.Coefficients.Estimate(1), mdl_list)', cellfun(@(val) val.Coefficients.Estimate(2), mdl_list)'];

% for AMRS CI:

for val = 3:6
    logic_force = tableM{:,val}<=95 & tableM{:,val}>=75;
    temp1 = (tableM{logic_force,end} - tableM{logic_force,val}).^2;
    m1 = mean(temp1,'omitnan');
    s1 = 2*std(temp1,'omitnan')/sqrt(sum(~isnan(temp1)));
    ARMS_ci(val-2,:) = sqrt([m1-s1, m1 + s1]);
end

for val = 3:6
    logic_force = tableM{:,val}<=95 & tableM{:,val}>=75;
    temp1 = (tableM{logic_force,7} - tableM{logic_force,val}).^2;
    m1 = mean(temp1,'omitnan');
    s1 = 2*std(temp1,'omitnan')/sqrt(sum(~isnan(temp1)));
    ARMS_ci_min(val-2,:) = sqrt([m1-s1, m1 + s1]);
end

fig2;
