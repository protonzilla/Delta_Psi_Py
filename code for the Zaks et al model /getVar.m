function vartoplot=getVar(sim, varname)





matchDynamic   = strcmp(sim.simparams.varsforsim, varname);


if (any(matchDynamic))
    
    [foo varidx]=find(matchDynamic);
    
    vartoplot=sim.simulatedvalues(varidx,:);
else
    [t q]=getStaticVals(sim);
    matchThylakoid = strcmp(fields(t),   varname);
    matchQuenching = strcmp(fields(q),   varname);
    switch 1
        case (any(matchThylakoid))
            if iscell(varname)
                vartoplot=t.(varname{1});
            else
                vartoplot=t.(varname);
            end
        case (any(matchQuenching))
            if iscell(varname)
                vartoplot=q.(varname{1});
            else
                vartoplot=q.(varname);
            end
            
        otherwise %There was no match
            error('no such variable')
    end
end




