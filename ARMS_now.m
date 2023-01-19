function [ARMS, mean_diff, std_diff] = ARMS_now(measured, original)
%ARMS_NOW Calculates ARMS error using the root sum of squares approximation
% of the mean and the std. Returns all three parameters.
%
% Elie Sarraf, Jan 19 2023

diff_vall = measured-original;
mean_diff= mean(diff_vall,'omitnan');
std_diff = std(diff_vall,'omitnan');
ARMS = sqrt(mean_diff.^2 + std_diff.^2);