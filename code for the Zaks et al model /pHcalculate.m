protonsIntoLumen= qEevolvedata(:,1)*200./(params.Na*params.LumenVolume); %protons per second

pHLumenStart=7;

pHInLumen=pHLumenStart-protonsIntoLumen./params.bufferCapacityLumen;

figure(4)
set(gca, 'Fontsize', 22)
plot(qEevolvedata(:,1), pHInLumen)