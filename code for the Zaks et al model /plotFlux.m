function a=plotFlux(sim, varname, fnum)
a=1;

flux=getFlux(sim, varname);

if nargin==2
    fnum=figure
end

fnames=fields(flux);
colors='rgbcmk'
%more than 1 process contributes to flux
    figure(fnum)
    
    set(gca, 'fontsize', 22)
    for  k=1:length(fnames)
        plot(sim.timevalues, flux.(fnames{k}), colors(k))
        hold on
    end
    grid off
    legend(fnames);
    setlegend(fnum, 'fontsize', 16)
    title(['Flux' varname])
