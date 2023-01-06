% Run the below once to build the dataset
% pat = extractSpo2;
megatable = cell(length(pat),4);
timetable = cell(length(pat),2);
time_offset = [1/12 1/6 1/4 1/2 1 2.5 5 10];

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
% addSpo2Error(addSpo2Error>100) = 100;
addSpo2Error= array2table(addSpo2Error,'VariableNames', ["VarErr","Bias_1", "Bias_Half"]);
tableM= [tableM(:,1:3) addSpo2Error tableM(:,4)];

tableM = splitvars(tableM,"Measured",'NewVariableNames', arrayfun(@(val) strcat("Measured_", sprintf('%.2g',val)), time_offset));
writetable(tableM,'out_file.csv')

%Time Table helps control for data validity
timetable = splitvars(timetable,"Measured",'NewVariableNames', arrayfun(@(val) strcat("Measured_", sprintf('%.2g',val)), time_offset));

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


% Repeated Measures Bland Altman plot:
logic_force = tableM.Bias_1<=95 & tableM.Bias_1>=75;
table_BA = tableM(logic_force,[1:3, 5 11 13]);

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
line(repmat(xlim_val',1,2), repmat(ba_5.ci,2,1),'Color', 'b','LineStyle',"-.")
line(repmat(xlim_val',1,2), repmat(ba_1.ci,2,1),'Color','r','LineStyle',"-.")
pl(4:5)=line(repmat(xlim_val',1,2), repmat(ba_ref.ci,2,1),'Color','k','LineStyle',"-.");
line(repmat(xlim_val,1,1), repmat(ba_5.bias,1,2),'Color', 'b','LineStyle',"--")
line(repmat(xlim_val,1,1), repmat(ba_1.bias,1,2),'Color','r','LineStyle',"--")
pl(6)=line(repmat(xlim_val,1,1), repmat(ba_ref.bias,1,2),'Color','k','LineStyle',"--");
xlim(xlim_val)
ylim([-8, 10])
hCopy = copyobj(pl, ax);
set(hCopy,'XData', NaN', 'YData', NaN)
hCopy(1).MarkerSize = 15; 
hCopy(2).MarkerSize = 15; 
hCopy(3).MarkerSize = 15; 
xlabel('Average of Measurements')
ylabel('Difference in Measurements')
legend(hCopy([3:-1:1 6 4] ), {'No error', '1 min', '5 min', 'Bias','Confidence Interval'},'Location','northwest')
set(gcf, 'Position', [680   100   1200   800])
