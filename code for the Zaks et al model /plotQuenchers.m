function a= plotQuenchers(sim, fnum)

l=unique(sim.LightIntensity)
LightIntensity=l(3);
[s q]=getStaticVals(sim)
taxis=sim.timevalues;
xlims=[0 1800];

figure(fnum)
set(gca, 'fontsize', 22)

plot(taxis, q.ActivePsbS, taxis, q.ActiveVDE)
legend('Active PsbS', 'Active VDE')
title(['pH-Sensing Enzymes for qE ', num2str(LightIntensity) '\mu Mol photons/m^2 s'])
grid off
xlim(xlims)

figure(fnum+1)
set(gca, 'fontsize', 22)

plot(taxis,  q.ActiveVDE, taxis, q.Zea,taxis, q.Anth)
legend( 'Active VDE', 'Zea', 'Anth')
title(['De-epoxidation ', num2str(LightIntensity) '\mu Mol photons/m^2 s'])
grid off
xlim(xlims)



figure(fnum+2)
set(gca, 'fontsize', 22)

plot(taxis, q.Zea, taxis, q.QuenchersZea,taxis, q.Anth, taxis, q.QuenchersAnth,  taxis, q.QuenchersAnth+q.QuenchersZea )
legend('Zea', 'Zea Quenchers', 'Anth', 'Anth Quenchers', 'Total Quenchers')
title(['Quenching-Active Species ', num2str(LightIntensity) '\mu Mol photons/m^2 s'])
grid off
xlim(xlims)


end