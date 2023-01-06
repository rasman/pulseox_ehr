function [ba_data] =  build_ba(table_BA, ref, meas, id)

ignore_na = ~any(isnan(table_BA{:,[ref meas]}),2);
table_BA = table_BA(ignore_na,:);

mean_ba =  (table_BA{:,ref} + table_BA{:,meas})/2;
diff_ba =  table_BA{:,meas} - table_BA{:,ref};

table_BA.diff_ba = diff_ba;

id_name = table_BA.Properties.VariableNames{id};

bias_ba = mean(diff_ba);
aov_ba = anova(table_BA, strcat("diff_ba ~ ", id_name));
stats_ba = aov_ba.stats.MeanSquares;
GC_ba = groupcounts(table_BA.PatID);
divisor_ba = ((sum(GC_ba))^2 - sum (GC_ba.^2))/((length(GC_ba)-1)*sum(GC_ba));
std_ba = sqrt((stats_ba(1)-stats_ba(2))/divisor_ba+stats_ba(2));
ci_ba = [bias_ba + 1.96*std_ba, bias_ba - 1.96*std_ba];

ba_data.mean = mean_ba;
ba_data.diff = diff_ba;
ba_data.bias = bias_ba;
ba_data.std =std_ba;
ba_data.ci = ci_ba;
