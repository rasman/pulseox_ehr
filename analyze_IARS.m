% This is the script to run the principal analysis. The scripts assumes
% that the data has already been extracted and put into structs named "pat"
% from the MIMIC-IV database and the main table with the added errors have
% been created.
%
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
for val = 3:6
    logic_force = tableM{:,val}<=95 & tableM{:,val}>=75;
    [ARMS_result(val-2,:), mean_result(val-2,:), std_result(val-2,:)] = ARMS_now(tableM{logic_force,7:end}, tableM{logic_force,val});
    [ARMS_diff_source(val-2), mean_diff_source(val-2), std_diff_source(val-2)] = ARMS_now(tableM{logic_force,3}, tableM{logic_force,val});
end

ARMS_print = sprintfc('%0.2f',[ARMS_diff_source ARMS_result]);
mean_print = sprintfc('(%0.2f, ',[mean_diff_source mean_result]);
std_print = sprintfc('%0.2f)',[std_diff_source std_result]);
total_print = strcat(ARMS_print,mean_print,std_print);

% Repeated Measures Bland Altman plot:
logic_force_BA = tableM.Bias_1<=95 & tableM.Bias_1>=75;
table_BA = tableM(logic_force_BA,:);

BA_result = [-diff(vertcat(arrayfun(@(val) build_ba(table_BA, 3, val, 1),7:14).loa),1,2)';
    -diff(vertcat(arrayfun(@(val) build_ba(table_BA, 4, val, 1),7:14).loa),1,2)';
    -diff(vertcat(arrayfun(@(val) build_ba(table_BA, 5, val, 1),7:14).loa),1,2)';
    -diff(vertcat(arrayfun(@(val) build_ba(table_BA, 6, val, 1),7:14).loa),1,2)'];

% Sees if caclulated values increase a fct of log(time)

val_list = [ARMS_result;mean_result;std_result;BA_result];
mdl_list = arrayfun(@(val) fitlm(log(time_offset), val_list(val,:)), 1:16,'UniformOutput', false);
lowest_rsqaured = min(cellfun(@(val) val.Rsquared.Adjusted,mdl_list));
highest_p = max(cellfun(@(val) val.Coefficients.pValue(2) ,mdl_list));

coefs =[cellfun(@(val) val.Coefficients.Estimate(1), mdl_list)', cellfun(@(val) val.Coefficients.Estimate(2), mdl_list)'];

offset = 0;
semilogx(time_offset, ARMS_result,'o')
ylim([0,4.5])
xticks(time_offset)
xticknow={'5 s', '10 s', '15 s', '30 s', '1 min', '2.5 min', '5 min', '10 min'};
set(gca,'XTickLabel', xticknow);
title('ARMS vs Deviation Time')
xlabel ('Deviation Time')
ylabel ('ARMS')
hold on;
set(gca,'ColorOrderIndex',1)
semilogx(time_offset([1,8]),log(time_offset([1,8])).*coefs((1:4)+offset,2) + coefs((1:4)+offset,1),':')
legend ({'Baseline', 'Case 1', 'Case 2', 'Case 3'},'Location','southeast')
hold off;
set(gcf, 'Position', [680   100   1200   800])
saveas(gcf,'ARMS.jpg')

offset = 4;
semilogx(time_offset, mean_result,'o')
ylim([0,3])
xticks(time_offset)
xticknow={'5 s', '10 s', '15 s', '30 s', '1 min', '2.5 min', '5 min', '10 min'};
set(gca,'XTickLabel', xticknow);
title('Mean Error vs Deviation Time')
xlabel ('Deviation Time')
ylabel ('Mean Error')
hold on;
set(gca,'ColorOrderIndex',1)
semilogx(time_offset([1,8]),log(time_offset([1,8])).*coefs((1:4)+offset,2) + coefs((1:4)+offset,1),':')
legend ({'Baseline', 'Case 1', 'Case 2', 'Case 3'},'Location','southeast')
hold off;
set(gcf, 'Position', [680   100   1200   800])
saveas(gcf,'Mean.jpg')

offset = 8;
semilogx(time_offset, std_result,'o')
ylim([0,4])
xticks(time_offset)
xticknow={'5 s', '10 s', '15 s', '30 s', '1 min', '2.5 min', '5 min', '10 min'};
set(gca,'XTickLabel', xticknow);
title('SD Error vs Deviation Time')
xlabel ('Deviation Time')
ylabel ('SD Error')
hold on;
set(gca,'ColorOrderIndex',1)
semilogx(time_offset([1,8]),log(time_offset([1,8])).*coefs((1:4)+offset,2) + coefs((1:4)+offset,1),':')
legend ({'Baseline', 'Case 1', 'Case 2', 'Case 3'},'Location','southeast')
hold off;
set(gcf, 'Position', [680   100   1200   800])
saveas(gcf,'SD.jpg')

offset = 12;
semilogx(time_offset, BA_result,'o')
ylim([0,15])
xticks(time_offset)
xticknow={'5 s', '10 s', '15 s', '30 s', '1 min', '2.5 min', '5 min', '10 min'};
set(gca,'XTickLabel', xticknow);
title('BA LOA vs Deviation Time')
xlabel ('Deviation Time')
ylabel ('Bland-Altman Limits of Agreement Spread')
hold on;
set(gca,'ColorOrderIndex',1)
semilogx(time_offset([1,8]),log(time_offset([1,8])).*coefs((1:4)+offset,2) + coefs((1:4)+offset,1),':')
legend ({'Baseline', 'Case 1', 'Case 2', 'Case 3'},'Location','southeast')
hold off;
set(gcf, 'Position', [680   100   1200   800])
saveas(gcf,'BA.jpg')


% for AMRS CI:

for val = 3:6
    logic_force = tableM{:,val}<=95 & tableM{:,val}>=75;
    temp1 = (tableM{logic_force,end} - tableM{logic_force,val}).^2;
    m1 = mean(temp1,'omitnan');
    s1 = 2*std(temp1,'omitnan')/sqrt(sum(~isnan(temp1)));
    ARMS_ci(val-2,:) = sqrt([m1-s1, m1 + s1]);
end