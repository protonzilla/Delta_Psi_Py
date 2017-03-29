%% plotStaticVals
% plot a series of useful variables

function a= plotStaticVals(sim, foffset, whattoplot)

if nargin<2
    foffset=0;
end
%% Get Static Variables
[s q]=getStaticVals(sim)

%% Active Cytochrome b6f
figure(foffset+101)
set(gca, 'fontsize', 22)
plot(sim.timevalues, s.FractionActiveCytochrome)
legend('Fraction Active Cytochromeb6f')

grid off


%% $\Delta \psi$ and $\Delta$ pH

figure(foffset+102)
set(gca, 'fontsize', 22)
plot(sim.timevalues, s.deltapsi, sim.timevalues, sim.params.voltsperlog*s.deltapH)
legend('\Delta \psi', 'delta pH')

grid off

%% pH of lumen and stroma
figure(foffset+103)
set(gca, 'fontsize', 22)
plot(sim.timevalues, s.pHLumen,sim.timevalues, s.pHStroma)
legend('lumen', 'stroma')
title('pH')
grid off

%% proton motive force
figure(foffset+104)
set(gca, 'fontsize', 22)
plot(sim.timevalues, s.pmf )
ylabel('volts')
title('pmf')
grid off

%% Chemical Potential of Ions
figure(foffset+105)
set(gca, 'fontsize', 22)
plot(sim.timevalues, s.deltamuCl,sim.timevalues, s.deltamuMg,sim.timevalues, s.deltamuK )
ylabel('volts')
title('\Delta \mu')
legend('Cl', 'Mg', 'K')
grid off

%% Cytochrome b6f variables
figure(foffset+106)
set(gca, 'fontsize', 22)
PCr=getVar(sim, 'PCr');
PQH2=getVar(sim, 'PQH2');
PCox=sim.params.PCperPSI-PCr;
FractionActivePC=PCox/sim.params.PCperPSI;
FractionPQr=     PQH2/sim.params.QuinonePoolSize;
plot(sim.timevalues, s.FractionActiveCytochrome,sim.timevalues, FractionActivePC, sim.timevalues, FractionPQr )
legend('FractionCytochrome', 'Fraction PC', 'Fraction PQr')
title('FractionActive Cytochrome')
grid off



%% qE pH sensors
figure(foffset+107)
set(gca, 'fontsize', 22)

plot(sim.timevalues, q.ActivePsbS, sim.timevalues, q.ActiveVDE)
legend('Active PsbS', 'Active VDE')
title('pH-Sensing Enzymes for qE')
grid off

%% Xanthophyll cycle
figure(foffset+108)
set(gca, 'fontsize', 22)

plot(sim.timevalues, q.Zea, sim.timevalues, q.QuenchersXanthophyll,sim.timevalues, q.Anth, sim.timevalues, q.QuenchersLutein,  sim.timevalues, q.QuenchersXanthophyll+q.QuenchersLutein )
legend('Zea', 'Xanthophyll Quenchers', 'Anth', 'Lutein Quenchers', 'Total Quenchers')
title('Quenching-Active Species')
grid off



end