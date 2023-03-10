data_points = 105970+(1:25*60);
pat_num = 119;
time_val = seconds(pat(pat_num).time(data_points));
time_val = time_val-time_val(1);
SpO2 = pat(pat_num).Spo2(data_points);
figure;
hold on;
plot(time_val,SpO2)
xtickformat("mm:ss")
ylim([93,99])
ylabel('% Saturation')
xlabel ('Time (MM:SS)')

ref_point = round(length(data_points)/2);
plot(time_val(ref_point),SpO2(ref_point),'bo')

line([time_val(ref_point)- seconds(600) time_val(ref_point)+ seconds(600)],[SpO2(ref_point) SpO2(ref_point)], 'Color', 'Black', 'LineStyle', ':')
sample_point= ref_point + 400;
plot(time_val(sample_point),SpO2(sample_point),'ko')

x_gau = 92:0.1:100;
y_gau = gaussmf(x_gau,[sqrt(2) SpO2(ref_point)-sqrt(2)]);
thick_sim = round((y_gau)*3*2)/2;
C= find(diff(thick_sim)~=0);
C = [1 C length(thick_sim)];

iter = 5;
line([time_val(ref_point-50) time_val(ref_point-50)],[x_gau(C(iter)) x_gau(C(iter+1))], 'Color', 'Red', 'LineStyle', ':','LineWidth', thick_sim(C(iter)))

SpO2_lab = SpO2(ref_point)-2;
plot(time_val(ref_point),SpO2_lab,'ro')
line([time_val(sample_point),time_val(sample_point)], [SpO2_lab,SpO2(sample_point)-0.1], 'Color', 'Red');

line([time_val(ref_point) time_val(sample_point)],[SpO2_lab SpO2_lab], 'Color', 'Red', 'LineStyle', ':')

for iter = 1: (length(C)-1)
    line([time_val(ref_point-50) time_val(ref_point-50)],[x_gau(C(iter)) x_gau(C(iter+1))], 'Color', 'Red', 'LineStyle', ':','LineWidth', thick_sim(C(iter)))
end

plot(time_val(sample_point),SpO2(sample_point)-0.1,'^r')
legend({'SpO2','Reference Sample','Deviation Time','Test Sample','Lab Error Dist','Lab Measurment','Error Measurement'})

title ('Example of Data Point Simulation')
set(gcf, 'Position', [680   100   1200   800])

saveas(gcf,'Simulation.tiff')