function [ARMS, mean_diff, std_diff] = ARMS_now(measured, original)
diff_vall = measured-original;
mean_diff= mean(diff_vall,'omitnan');
std_diff = std(diff_vall,'omitnan');
ARMS = sqrt(mean_diff.^2 + std_diff.^2);