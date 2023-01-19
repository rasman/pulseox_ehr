function [ba_data] =  build_ba(table_BA, ref, meas, id)
%BUILD_BA Calculates the necessary values for the repeated-measures
%Bland-Altman plot as described in the 2007 manuscript. Requires a data
%table to be privided with the location (index) of reference, measured
%value and id. Returns a struct with the calculated parameters. CI
%calculation needs to be reviewed.
%
%Reference:
%Bland, J. Martin orcid.org/0000-0002-9525-5334 and Altman, Douglas G. (2007)
%Agreement between methods of measurement with multiple observations per individual.
%Journal of Biopharmaceutical Statistics. pp. 571-582. ISSN 1520-5711 
% https://doi.org/10.1080/10543400701329422
%
% Elie Sarraf, Jan 19 2023

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
loa_ba = [bias_ba + 1.96*std_ba, bias_ba - 1.96*std_ba];

n_num = length(unique(table_BA{:,id}));
se = std_ba/sqrt(n_num);
t_val = tinv(1 - 0.05/2, n_num-1);

ba_data.mean = round(mean_ba,1);
ba_data.diff = round(diff_ba,1);
ba_data.bias = bias_ba;
ba_data.std =std_ba;
ba_data.loa = loa_ba;
ba_data.se = se;
ba_data.ci = t_val*se;
