%% makeFigures
%%

function makePAMFiguresfromsim( samplepam, quenchyes, color)

%% Import and Plot Experimental Data 


% specify folder in which to save figures
%figfolder='/Users/jzaks/Documents/GradSchool/FlemingLab/Papers/qEmodel/figuresFromMatlab/';
idx=1;


lighttime=[130 850]; %times that light is on and off
offset=10 %amount by which to offset npq4 from wt
if nargin==1
quenchyes=4; %index of column in variable samplepam that has quenching 
end
if nargin<3
    color='b'
end
%% Plot PAM trace fo 100 uE
figure(12)
hold on
plotPAM(samplepam{1,quenchyes}, 12 , 'k-', 0)
plotPAM(samplepam{1,1}, 12 , 'r-', offset)
f12name='100uESimPAM'
xlim([0 1100])
ylim([-0.0 0.08])
legend('with qE', 'no qE')
setlegend(12,'position',  [ 0.8 0.8 0.01 0.01])
setlegend(12,'fontsize',  18)
addlightdarkstrip(12, lighttime, 100)


%% Plot PAM trace fo 1000 uE
figure(13)
hold on
plotPAM(samplepam{idx,quenchyes}, 13 , 'k-', 0)
plotPAM(samplepam{idx,1}, 13 , 'r-', offset)
f13name='1000uESimPAM'
xlim([0 1300])
ylim([-0.0 0.08])
legend('with qE', 'no qE')
setlegend(13,'position',  [ 0.8 0.8 0.01 0.01])
setlegend(13,'fontsize',  18)
addlightdarkstrip(13, lighttime, 1000)






figure(25)
xlim([-10 1100])
ylim([-0.2 1.8])
%set(gca,'YTick',[-0.1 0 0.1 0.2 0.3 0.4 0.5])
ylabel('qE= NPQ_{wt}-NPQ_{npq4}')
addlightdarkstrip(25, lighttime, 100, 22)

hold on
figure(27)
xlim([0 1100])
ylim([-0.4 2.2])
addlightdarkstrip(27, lighttime, 1000,22)
ylabel('qE= NPQ_{wt}-NPQ_{npq4}')
hold on

figure(28)
xlim([-10 1100])
ylim([-0.0 2.5])
addlightdarkstrip(28, [100 820], 500)
%title('Difference in NPQ')


plotNPQfromPAM(samplepam{1,quenchyes}, 25, [ color '--'])
plotNPQfromPAM(samplepam{idx,quenchyes}, 27, [ color '--'])

figure(25)
legend('Experiment' ,'Simulation')
setlegend(25,'position',  [ 0.5 0.5 0.05 0.05])

figure(27)
legend('Experiment' ,'Simulation')
setlegend(27,'position',  [ 0.5 0.5 0.05 0.05])



end
%% Extra functions that are useful for looking at data
function plotallqEs(f, fnum)
f.plotparam('wt',  fnum, 'b-', 'npq')
figure(fnum)
hold on
f.plotparam('npq4', fnum, 'g-', 'npq')
f.plotparam('npq1', fnum, 'm-', 'npq')
legend('wt', '', 'npq4','',  'npq1')
end


function plotqPs(f, fnum)
f.plotparam('wt',  fnum, 'b-', 'qP')
figure(fnum)
hold on
f.plotparam('npq4', fnum, 'g-', 'qP')
f.plotparam('npq1', fnum, 'm-', 'qP')
legend('wt', '', 'npq4','',  'npq1')
end



function plotdeltaqEs(f, fnum, plotstyle)
lw=2;
qEZI=f.params.wt.npq-f.params.npq1.npq;
qETotal=f.params.wt.npq-f.params.npq4.npq;
qENPQ4NPQ1=f.params.npq1.npq-f.params.npq4.npq;
figure(fnum)
set(gca, 'fontsize', 22);
set(gca, 'linewidth', 2);
plot(f.params.wt.pulsetimes, qEZI, plotstyle);
hold on
plot(f.params.wt.pulsetimes, qETotal, [plotstyle '--'], 'linewidth', lw);
plot(f.params.wt.pulsetimes, qENPQ4NPQ1, [plotstyle 'o-']);
legend('wt-npq1', 'wt-npq4', 'npq1-npq4')
plot(f.params.wt.pulsetimes, zeros(size(f.params.wt.pulsetimes)), 'k');
grid off
title(f.basefilename)

end







function plotTotalqE(t, fnum, plotstyle, offset)

figure(fnum)
set(gca, 'fontsize', 22)

qETotal=(t.params.wt.npq-t.params.npq4.npq);
if nargin==3
    offset=t.params.wt.pulsetimes(1);
end

plot(t.params.wt.pulsetimes-offset, qETotal, plotstyle);
hold on
grid off
title('total qE')
xlabel('time(seconds)')
%ylabel('qE( NPQ_{wt}-NPQ_{npq4})')

ylabel('qE= NPQ_{wt}-NPQ_{npq4}')
title('')
end


function plotTotalNPQ(t,fnum, plotstyle)

figure(fnum)
set(gca, 'fontsize', 22)

NPQWT=t.params.wt.npq
NPQ4 =t.params.npq4.npq;

plot(t.params.wt.pulsetimes-t.params.wt.pulsetimes(1), NPQWT, 'ks-');
hold on
plot(t.params.wt.pulsetimes-t.params.wt.pulsetimes(1), NPQ4, ['ko--'  ]);

hold on

grid off
title('total NPQ')
xlabel('time(seconds)')
ylabel('NPQ')

end


function npq=plotPAM(sim, fnum, plotstyle, offset)


npq=calcNPQfromsim(sim);


figure(fnum)
[s q]=getStaticVals(sim)

set(gca, 'fontsize', 22)
plot(sim.timevalues+offset, npq.fluorescenceyield, plotstyle);%, sim.timevalues, npq.fluorescenceyieldRCC)
grid off
 xlabel('time(seconds)')
ylabel('\Phi_F')

end


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


function npq=plotSimQ(sim, fnum, plotstyle)


npq=calcNPQfromsim(sim);


figure(fnum)
[s q]=getStaticVals(sim)


figure(fnum)
set(gca, 'fontsize', 22)

plot(sim.timevalues, q.Zea, sim.timevalues, q.QuenchersZea,sim.timevalues, q.Anth, sim.timevalues, q.QuenchersAnth,  sim.timevalues, 0.5*q.QuenchersAnth+q.QuenchersZea )
legend('Zea', 'Zea Quenchers', 'Anth', 'Anth Quenchers', 'Total Quenchers')
title('Quenching-Active Species')
grid off
end






