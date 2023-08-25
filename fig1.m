data_points = 105970+(1:25*60);
pat_num = 119;
time_val = seconds(pat(pat_num).time(data_points));
time_val = time_val-time_val(1);
SpO2 = pat(pat_num).Spo2(data_points);
figure;
sfh1 = subplot(10,10,setdiff(1:99, [10:10:100]));
hold on;
plot(time_val,SpO2)
xtickformat("mm:ss")
ylim([93,99])
ylabel('% Saturation')
xlabel ('Time (MM:SS)')

ref_point = round(length(data_points)/2);
plot(time_val(ref_point),SpO2(ref_point),'bo', 'linewidth',4)

%line([time_val(ref_point)- seconds(600) time_val(ref_point)+ seconds(600)],[SpO2(ref_point) SpO2(ref_point)], 'Color', 'Black', 'LineStyle', ':','LineWidth',1)
line((time_val(ref_point)- seconds(600))*[1 1],SpO2(ref_point)+[-1.5 1.5], 'Color', 'Black', 'LineStyle', ':','LineWidth',5)
line((time_val(ref_point)+ seconds(600))*[1 1],SpO2(ref_point)+[-1.5 1.5], 'Color', 'Black', 'LineStyle', ':','LineWidth',5)

sample_point= ref_point + 400;
plot(time_val(sample_point),SpO2(sample_point),'ksquare', 'linewidth',4)

x_gau = 92:0.1:100;
y_gau = gaussmf(x_gau,[sqrt(2) SpO2(ref_point)-sqrt(2)]);

% thick_sim = round((y_gau)*3*2)/2;
% C= find(diff(thick_sim)~=0);
% C = [1 C length(thick_sim)];

iter = 5;
%line([time_val(ref_point-50) time_val(ref_point-50)],[x_gau(C(iter)) x_gau(C(iter+1))], 'Color', 'Red', 'LineStyle', ':','LineWidth', thick_sim(C(iter)))

SpO2_lab = SpO2(ref_point)-2;
plot(time_val(ref_point),SpO2_lab,'rdiamond', 'linewidth',4)
line([time_val(sample_point),time_val(sample_point)], [SpO2_lab,SpO2(sample_point)-0.1], 'Color', 'Red','LineWidth',1);

line([time_val(ref_point) time_val(sample_point)],[SpO2_lab SpO2_lab], 'Color', 'Red', 'LineStyle', ':','LineWidth',1)

% for iter = 1: (length(C)-1)
%     line([time_val(ref_point-50) time_val(ref_point-50)],[x_gau(C(iter)) x_gau(C(iter+1))], 'Color', 'Red', 'LineStyle', ':','LineWidth', thick_sim(C(iter)))
% end

plot(time_val(sample_point),SpO2(sample_point)-0.1,'^r')
legend({'MIMIC-IV SpO2 data','Reference SpO2 Value','EHR Sample Range','','EHR SpO2 Sample','SaO2','Measurement Error'})
title ('Example of Data Point Simulation')
xlim_now = xlim;


sfh2 = subplot(10,10,10:10:100);
fill([0 y_gau 0],[92 x_gau 100], 'r')
ylim([93,99])
xlabel({'SaO2 Probability', 'Distribution'})
set(gca,'yticklabel',{[]})
set(gca,'YTick',[])


% sfh3 = subplot(10,10,1:9);
% fill(time_val, time_val< time_val(ref_point)+ seconds(600) & time_val > time_val(ref_point)- seconds(600), 'k')
% set(gca,'xticklabel',{[]})
% set(gca,'XTick',[])
% 
% xlim(xlim_now)
% ylabel({'Test Sample','Range'})
% title ('Example of Data Point Simulation')
% ylim([-1,2])
% set(gca,'yticklabel',{[]})
% set(gca,'YTick',[])

set(gcf, 'Position', [680   100   1200   800])

saveas(gcf,'Simulation.tiff')