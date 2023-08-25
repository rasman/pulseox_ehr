figure;
subplot(1,2,1);
hold on;

val = 3;
logic_force = tableM{:,val}<=95 & tableM{:,val}>=75;
table_val = tableM(logic_force,:);
example_1= build_ba(table_val, val, 7, 2);
plot(example_1.mean,example_1.diff,'.')
line([70 100],[0 0]+example_1.bias,'Color', 'Black', 'LineStyle', ':','LineWidth',2)
line([70 100],[0 0]+example_1.loa(1),'Color', 'Red', 'LineStyle', ':','LineWidth',2)
line([70 100],[0 0]+example_1.loa(2),'Color', 'Red', 'LineStyle', ':','LineWidth',2)

title('BA plot: Ideal Device, 5 s')
xlabel('Average Of Values (%)')
ylabel('Difference Between Values (%)')
xlim([70 100])
ylim([-20 20])
legend({'', 'Bias', 'Limits of Agreement'},'Location','northwest')

subplot(1,2,2);
hold on;

val = 4;
logic_force = tableM{:,val}<=95 & tableM{:,val}>=75;
table_val = tableM(logic_force,:);
example_1= build_ba(table_val, val, 13, 2);
plot(example_1.mean,example_1.diff,'.')
line([70 100],[0 0]+example_1.bias,'Color', 'Black', 'LineStyle', ':','LineWidth',2)
line([70 100],[0 0]+example_1.loa(1),'Color', 'Red', 'LineStyle', ':','LineWidth',2)
line([70 100],[0 0]+example_1.loa(2),'Color', 'Red', 'LineStyle', ':','LineWidth',2)

title('BA plot: Device #1, 10 min')
xlabel('Average Of Values (%)')
xlim([70 100])
ylim([-20 20])

set(gcf, 'Position', [680   100   1200   800])
saveas(gcf,'BA_plots.tiff')