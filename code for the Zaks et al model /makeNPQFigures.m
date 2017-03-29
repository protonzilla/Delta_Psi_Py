%% makeStaticFigures
%%

function makeNPQFigures( samplepam)

%folder for saving figures
figfolder='/Users/jzaks/Documents/GradSchool/FlemingLab/Conferences/BPS2012/BPS2012Poster/posterfigures';
lighttime=[0 750]

foffset=0;
offset=10
%close all
quenchyes=2;
idxhigh=1;
idxlow=1;

psbscolor=[0 0 0];
psbsls='--';

vdecolor=[ 0 0  0.6];
vdels='-';


anthcolor=[0 0.5 0.5];
anthls='-.';
zeacolor=[ 0.8 0 0.8];
zeals='-.';
qcolor =[ 1 0.65 0];
qls='-';


makefigure(idxhigh, {'ActivePsbS'},1,  [ 0.7 0.45 0.01 0.01], {psbscolor})
xlim([0 1500])
ylabel('Fraction')
makefigure(4, {'ActivePsbS' 'ActiveVDE'},idxhigh,  [  0.73 0.45 0.01 0.01], {psbscolor vdecolor}, 'Fraction Protonated Species', {psbsls vdels})
xlim([0 1500])
ylabel('Fraction')
makefigure(6, {'ActiveVDE' 'Anth' 'Zea'},idxhigh,  [ 0.73 0.45 0.01 0.001], {vdecolor  anthcolor zeacolor}, 'Fraction', {vdels  anthls zeals})
xlim([0 1500])
ylabel('Fraction')

makefigure(foffset+7, { 'ActivePsbS' 'Anth' 'Zea' 'TotalQ'},idxhigh,  [ 0.70 0.45 0.1 0.01], { psbscolor anthcolor zeacolor qcolor}, 'Fraction', { psbsls anthls zeals qls})
ylabel('Quenching Species (Fraction)')
xlim([0 1500])

function makefigurecompare(fnum, value, idx, legendposition,ylab, varargin)
figure(fnum)
hold on
plotStaticVal(fnum,samplepam{idx,quenchyes}, value, 'k', 0,varargin)
plotStaticVal(fnum,samplepam{idx,1}, value, 'r', offset, varargin)
legend('with qE', 'no qE')
setlegend(fnum,'position',  legendposition)
setlegend(fnum,'fontsize',  22)

a=unique(samplepam{idx,quenchyes}.LightIntensity)
act=a(3)
figure(fnum)
xlim([0 1350])
addlightdarkstrip(fnum, 100+lighttime, act, 20)
ylabel(ylab)
print(['-f' num2str(fnum)], '-depsc', [figfolder value num2str(act)])
%exportfig([fnum],  [figfolder value num2str(act)], 'color', 'cmyk')
end


function makefigure(fnum, values, idx, legendposition, plotstyle, ylab, varargin)
   
figure(fnum)
offsets=[ 5 10 15 20]
fname='';
hold on
for k=1:length(values)
    if ~any(size(varargin))||~any(size(varargin{1}))
        lst='-';
    else 
        lst=varargin{1}{k};
    end
plotStaticVal(fnum,samplepam{idx,quenchyes}, values{k}, plotstyle{k}, offsets(k),lst)
fname=[fname values{k}]
end

legend(values)
setlegend(fnum,'position',  legendposition)
setlegend(fnum,'fontsize',  22)
xlim([0 1500])
a=unique(samplepam{idx,quenchyes}.LightIntensity)
act=a(3)
ylim('auto')
yl=ylim
if yl(2)==1
    yl(2)=1.2
    yl(1)=-0.05
    ylim([yl])
end

addlightdarkstrip(fnum, 100+lighttime, act)




if nargin>=6
    ylabel(ylab)
end
xlim([0 1500])
set(gca, 'XTick', [0 300 600 900 1200])
print(['-f' num2str(fnum)], '-depsc2', [figfolder fname num2str(act)])
%exportfig([fnum], [figfolder fname num2str(act)], 'color', 'cmyk')
end


end






function plotStaticVal(fnum, siml,value, plotcolor, offset,varargin)
if ~any(size(varargin{1}))
    lst='-'
else
    lst=varargin{1}
end

figure(fnum)
set(gca, 'fontsize', 22)
[s q]=getStaticVals(siml);
r=catstruct(s,q)
if nargin==4
    offset=siml.timevalues(1);
end

try plot(siml.timevalues-offset, r.(value), 'Color', plotcolor, 'Linestyle', lst,'Linewidth', 4);
catch
    b=1
end
    hold on
grid off
box on
ylstart=[min(r.(value)) max(r.(value))]
yrange=ylstart(2)-ylstart(1);
ylcurrent=ylim;
yl  =  [max(0, ylstart(1)-yrange*0.1) ylstart(2)+yrange*0.2 ]
if yl(1)>=yl(2)
    yl=ylcurrent;
end
xlabel('time (seconds)')
ylabel(value)
ylim(yl)

end


