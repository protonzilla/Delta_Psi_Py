LightIntensities=[ 0.1 1500 1500 1500 0.1  ]
durat=[10 10 10 10 100];
params=getparamsfromfilename('params.txt');


simtype='test'
tic
simPSII=chloroplastSim(LightIntensities, durat, params, 0, simtype);
toc

a=getChlorophyllkRates(simPSII)
figure(4)
set(gca, 'Fontsize', 22)
semilogx(simPSII.timevalues-10, a.fluorescenceyield)
xlim([1e-5 1e0])