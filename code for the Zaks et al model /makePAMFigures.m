%% makePAMFigures
%%

function makePAMFigures

%Folder for saving figures
figfolder='/Users/jzaks/Documents/GradSchool/FlemingLab/Papers/qEmodel/figuresFromMatlab/';
%% Load experimental data
cd html/data
a=pamtraceAv('100uE')
b=pamtraceAv('500uE')
c=pamtraceAv('1000uE')


lighttime=[130 850]
offset  = 10;
normtype= 'FvFm'

%%
% Plot experimental data
%%
figure(10)
a.pamtraces{1}.plot('wt', 10 ,   'k-',   0    )
a.pamtraces{1}.plot('npq4', 10 , 'r-', offset)
legend( 'wt', 'npq4')
f10name='100uEPAM'

ylabel('Fl. Yield (Relative)')

xlim([0 1100])

figure(11)
hold on
c.pamtraces{1}.plot('wt', 11 , 'k-', 0)
c.pamtraces{1}.plot('npq4', 11 , 'r-', offset)
legend( 'wt', 'npq4')
setlegend(11,'position',  [ 0.7 0.65 0.05 0.05])
ylabel('Fl. Yield (Relative)')


f11name='1000uEPAM'
xlim([0 1100])



figure(12)
hold on
c.plotdiff( 12 , 'k-')
ylim([-0.4 2.3])
ylabel('qE=\Delta NPQ')
f12name='1000DiffNPQWTNPQ4'
xlim([0 1100])


figure(13)
hold on
a.plotdiff( 13 , 'k-')
ylim([-0.4 2.3])
ylabel('qE=\Delta NPQ')
f13name='100DiffNPQWTNPQ4'
xlim([0 1100])



figure(31)
hold on
c.plotnpqmean('wt'  , 31 , 'ko-')
c.plotnpqmean('npq4', 31 , 'rs-')
legend( 'wt', 'npq4')
ylim([0 3.3])
setlegend(31,'position',  [ 0.55 0.55 0.05 0.05])

ylabel('NPQ')

f31name='1000uENPQ'
xlim([0 1100])

figure(32)
hold on
a.plotnpqmean('npq4', 32 , 'rs-')
a.plotnpqmean('wt'  , 32 , 'ko-')
legend( 'wt', 'npq4')
ylim([0 1.8])
setlegend(32,'position',  [ 0.55 0.55 0.05 0.05])


ylabel('NPQ')
f32name='100uENPQ'
xlim([0 1100])
cd /Users/jzaks/Documents/GradSchool/FlemingLab/NPQ/ModelPaper1

addlightdarkstrip(31, lighttime, 1000)
addlightdarkstrip(32, lighttime, 100)
addlightdarkstrip(12, lighttime, 1000)
addlightdarkstrip(13, lighttime, 100)

addlightdarkstrip(11, lighttime, 1000)
addlightdarkstrip(10, lighttime, 100)
%% Save figures as EPS files
print('-f10', '-depsc', [figfolder f10name])
print('-f11', '-depsc', [figfolder f11name])
print('-f12', '-depsc', [figfolder f12name])
print('-f13', '-depsc', [figfolder f13name])
print('-f31', '-depsc', [figfolder f31name])
print('-f32', '-depsc', [figfolder f32name])

end

%PamSim