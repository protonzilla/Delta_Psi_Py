function  plotSimVar(sim, varname, figurenum, linestyle)
figure(figurenum)
varidx=find(strcmp(sim.simparams.varsforsim, varname))

set(gca, 'fontsize', 22)
plot(sim.timevalues, sim.simulatedvalues(varidx,:));