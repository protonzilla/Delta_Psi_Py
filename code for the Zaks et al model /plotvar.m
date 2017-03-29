function plotvar(fnum, sim, varname, linestyle, plotnow)
if ~isnumeric(fnum)
    error('the first entry must be the figure number or handle')
end

if ishandle(fnum)
    g=fnum;
else
    %~ishandle(fnum)
    g=figure(fnum);
end
vartoplot=getVar(sim, varname);

set(g, 'Fontsize', 22)


if nargin<4
    linestyle='b'
end

plot(g,sim.timevalues, vartoplot, linestyle)
title(g,varname);
grid(g,'off');