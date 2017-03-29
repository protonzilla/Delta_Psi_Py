%% plotallvars
% Plots all variables in simulation |sim|
% |plotset| is an optional input parameter that calls for some pre-set
% combination of variables to plot
function plotallvars(sim, plotset)
if nargin==2
    f=fields(sim.simparams.varindices)
    if any(strcmp(plotset, f))
        idx=find(strcmp(plotset, f));
        varnames=sim.simparams.varnames.(f{idx});
    end
    switch plotset
        case 'cb'
            varnames= {        'ATP'        'Fdxr'  'Thrdxr' 'ActiveCBEnzymes' };
        case 'antenna'
            varnames= sim.simparams.varnames.PSII_Antenna;
        case 'PSIIRC'
            varnames= sim.simparams.varnames.PSII_RC;
        case 'PSI'
            varnames= sim.simparams.varnames.PSI;
    end
    
else
    varnames=sim.simparams.varsforsim;
end
for k=1:length(varnames)
    plotvar(k, sim, varnames{k})
    title(varnames{k})
    
end
if strmatch(sim.simparams.simvars, 'LumenStromaFlux')
    plotStaticVals(sim)
end
end
