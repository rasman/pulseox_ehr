subplot(2,2,1)
offset = 0;
semilogx(time_offset, ARMS_result,'o')
ylim([0,4.5])
xticks(time_offset)
xticknow={'5 s', '10 s', '15 s', '30 s', '1 min', '2.5 min', '5 min', '10 min'};
set(gca,'XTickLabel', xticknow);
title('a) ARMS vs Deviation Time')
xlabel ('Deviation Time')
ylabel ('ARMS')
hold on;
set(gca,'ColorOrderIndex',1)
semilogx(time_offset([1,8]),log(time_offset([1,8])).*coefs((1:4)+offset,2) + coefs((1:4)+offset,1),':')
legend ({'Baseline', 'Case 1', 'Case 2', 'Case 3'},'Location','southeast')
hold off;
subplot(2,2,2)
offset = 4;
semilogx(time_offset, mean_result,'o')
ylim([0,3])
xticks(time_offset)
xticknow={'5 s', '10 s', '15 s', '30 s', '1 min', '2.5 min', '5 min', '10 min'};
set(gca,'XTickLabel', xticknow);
title('b) Mean Error vs Deviation Time')
xlabel ('Deviation Time')
ylabel ('Mean Error')
hold on;
set(gca,'ColorOrderIndex',1)
semilogx(time_offset([1,8]),log(time_offset([1,8])).*coefs((1:4)+offset,2) + coefs((1:4)+offset,1),':')
legend ({'Baseline', 'Case 1', 'Case 2', 'Case 3'},'Location','southeast')
hold off;
subplot(2,2,3)
offset = 8;
semilogx(time_offset, std_result,'o')
ylim([0,4])
xticks(time_offset)
xticknow={'5 s', '10 s', '15 s', '30 s', '1 min', '2.5 min', '5 min', '10 min'};
set(gca,'XTickLabel', xticknow);
title('c) SD Error vs Deviation Time')
xlabel ('Deviation Time')
ylabel ('SD Error')
hold on;
set(gca,'ColorOrderIndex',1)
semilogx(time_offset([1,8]),log(time_offset([1,8])).*coefs((1:4)+offset,2) + coefs((1:4)+offset,1),':')
legend ({'Baseline', 'Case 1', 'Case 2', 'Case 3'},'Location','southeast')
hold off;
subplot(2,2,4)
offset = 12;
semilogx(time_offset, BA_result,'o')
ylim([0,16])
xticks(time_offset)
xticknow={'5 s', '10 s', '15 s', '30 s', '1 min', '2.5 min', '5 min', '10 min'};
set(gca,'XTickLabel', xticknow);
title('d) BA LOA vs Deviation Time')
xlabel ('Deviation Time')
ylabel ('Bland-Altman Limits of Agreement Spread')
hold on;
set(gca,'ColorOrderIndex',1)
semilogx(time_offset([1,8]),log(time_offset([1,8])).*coefs((1:4)+offset,2) + coefs((1:4)+offset,1),':')
legend ({'Baseline', 'Case 1', 'Case 2', 'Case 3'},'Location','southeast')
hold off;
set(gcf, 'Position', [680   100   1200   800])
saveas(gcf,'Error.tiff')