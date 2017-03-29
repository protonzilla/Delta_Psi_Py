function plotsamplenpq(sample)
colors='kkm'


for k=[ 1 2 3 ]
    figure(1)
    hold on
plotNPQfromPAM(sample{1,k}, 1, [colors(k) '--'])
end
figure(1)
title('qE in mutants')
ylabel('NPQ')

legend('no qE',  ' only lutein (npq1)','zeaxanthin and lutein') 
%legend('no qE', 'zeaxanthin and lutein', ' only lutein (npq1)', 'only zeaxanthin (lut2)', 'no violaxanthin (npq2)') 
xlim([0 1200])
ylim([-0.5 3])
function npq=plotNPQfromPAM(sim, fnum, plotstyle)


npq=calcNPQfromsim(sim);


figure(fnum)

npqtime=npq.pulsetime;%-npq.pulsetime(2);

set(gca, 'fontsize', 22)
plot(npqtime, npq.qEpulse, plotstyle, 'Linewidth', 4)
grid off
%title('NPQ')
xlabel('time(seconds)')


end
end