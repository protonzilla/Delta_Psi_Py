function npq=plotNPQ(sim, fnum, plotstyle)


npq=calcNPQfromsim(sim)



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
    plotstyle='b';
end

[s q]=getStaticVals(sim)

set(g, 'fontsize', 22)
plot(g,sim.timevalues, npq.fluorescenceyield, plotstyle, sim.timevalues, npq.fluorescenceyieldRCC)
grid(g,'off')
title(g,'Chl fluorescence yield')
xlabel(g,'seconds')
ylabel(g,'\Phi_F')
ylim([0 0.15])

figure(fnum+1)
set(gca, 'fontsize', 22)


plot(sim.timevalues, q.Zea, sim.timevalues, q.QuenchersXanthophyll,sim.timevalues, q.Anth, sim.timevalues, q.QuenchersLutein,  sim.timevalues, q.QuenchersXanthophyll+q.QuenchersLutein )
legend('Zea', 'Zea Quenchers', 'Anth', 'Lutein Quenchers', 'Total Quenchers')
title('Quenching-Active Species')
grid off