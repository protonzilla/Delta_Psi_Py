function k=plotFluorescenceYield(sim, fnum, plotstyle)


krates=getChlorophyllkRates(sim);
tignore=5e-3 ;%seconds of first section to ignore
indicestoplot=[];
for k=1:sim.nsections
    tstartindex  =  interp1(sim.timevalues(sim.sectionstart(k):(sim.sectionstart(k)+sim.sectionlength(k)-1))-sim.timevalues(sim.sectionstart(k)),...
        sim.sectionstart(k):(sim.sectionstart(k)+sim.sectionlength(k)-1),...
        tignore, 'nearest');
    indicestoplot=[indicestoplot (tstartindex):(sim.sectionstart(k)+sim.sectionlength(k)-1)];
end



if nargin==1
    fnum=figure
end
if ishandle(fnum)
    g=fnum;
else
    %~ishandle(fnum)
g=figure(fnum);
end



if nargin<3
    plotstyle='k';
end

[s q]=getStaticVals(sim);


set(g, 'fontsize', 22)

sspan=1;

plot(g,sim.timevalues(indicestoplot), krates.fluorescenceyield(indicestoplot), plotstyle);

title(g,'Chl fluorescence yield')
xlabel(g,'seconds')
ylabel(g,'\Phi_F')
grid(g,'off')
%ylim([0 0.15])

