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

% Check to ensure ARMS values are correctly set
[ARMS_diff, mean_diff, std_diff] = ARMS_now(table2array(tableM(tableM.Spo2<95,3)),table2array(tableM(tableM.Spo2<95,4:6)));
ARMS_print_diff = sprintfc('%0.2f',ARMS_diff);
mean_print_diff = sprintfc('(%0.2f, ',mean_diff);
std_print_diff = sprintfc('%0.2f)',std_diff);
total_print_diff = strcat(ARMS_print_diff,mean_print_diff,std_print_diff);

% Sees if caclulated values increase a fct of log(time)

val_list = [ARMS_result;mean_result;std_result];
mdl_list = arrayfun(@(val) fitlm(log(time_offset), val_list(val,:)), 1:8,'UniformOutput', false);
lowest_rsqaured = min(cellfun(@(val) val.Rsquared.Adjusted,mdl_list));
highest_p = max(cellfun(@(val) val.Coefficients.pValue(2) ,mdl_list));

% Repeated Measures Bland Altman plot:
logic_force_BA = tableM.Bias_1<=95 & tableM.Bias_1>=75;
table_BA = tableM(logic_force_BA,[1:3, 5 11 13]);

ba_ref = build_ba(table_BA, 4, 3, 1);
ba_1 = build_ba(table_BA, 4, 5, 1);
ba_5 = build_ba(table_BA, 4, 6, 1);


xlim_val =[75,100];
hold off
clf
ax = axes(); 
pl(1)= plot(ba_5.mean,ba_5.diff,'b.','MarkerSize',3);
hold on
pl(2)=plot(ba_1.mean,ba_1.diff,'r.','MarkerSize',3);
pl(3)=plot(ba_ref.mean,ba_ref.diff,'k.','MarkerSize',3);
line(repmat(xlim_val',1,2), repmat(ba_5.loa,2,1),'Color', 'b','LineStyle',"-.")
line(repmat(xlim_val',1,2), repmat(ba_1.loa,2,1),'Color','r','LineStyle',"-.")
pl(4:5)=line(repmat(xlim_val',1,2), repmat(ba_ref.loa,2,1),'Color','k','LineStyle',"-.");
line(repmat(xlim_val,1,1), repmat(ba_5.bias,1,2),'Color', 'b','LineStyle',"--")
line(repmat(xlim_val,1,1), repmat(ba_1.bias,1,2),'Color','r','LineStyle',"--")
pl(6)=line(repmat(xlim_val,1,1), repmat(ba_ref.bias,1,2),'Color','k','LineStyle',"--");
xlim(xlim_val)
ylim([-6.5, 11.5])
hCopy = copyobj(pl, ax);
set(hCopy,'XData', NaN', 'YData', NaN)
hCopy(1).MarkerSize = 15; 
hCopy(2).MarkerSize = 15; 
hCopy(3).MarkerSize = 15; 
xlabel('Average of Measurements')
ylabel('Difference in Measurements')
legend(hCopy([3:-1:1 6 4] ), {'No error', '1 min', '5 min', 'Bias','Limits of Agreement'},'Location','northwest')
set(gcf, 'Position', [680   100   1200   800])
saveas(gcf,'Bland_Altman_LOA.tiff')

print_BA = [(sprintfc('%0.2f ',[ba_5.bias ba_5.loa(2:-1:1)]));
(sprintfc('%0.2f ',[ba_1.bias ba_1.loa(2:-1:1)]));
(sprintfc('%0.2f ',[ba_ref.bias ba_ref.loa(2:-1:1)]))];

