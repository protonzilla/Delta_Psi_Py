function npq=plotNPQfromPAM(sim, fnum, plotstyle)


npq=calcNPQfromsim(sim);


if ishandle(fnum)
    g=fnum;
else
    %~ishandle(fnum)
g=figure(fnum);
end


npqtime=npq.pulsetime;%-npq.pulsetime(2);

set(g, 'fontsize', 22)
plot(g,npqtime, npq.qEpulse, plotstyle, 'Linewidth', 4)
grid(g, 'off')
%title('NPQ')
xlabel(g,'time(seconds)')


end
