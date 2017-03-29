function out=getFlux(sim, varname)

%Works for only one variable varname
varindex=getIndices(sim.simparams.varsforsim, {varname});

fnames=fields(sim.simparams.varindices)
kk=1;
for k=1:length(fnames)
    idx=find(sim.simparams.varindices.(fnames{k})==varindex);
   
    if (size(idx,2)==1)
        simValues.(fnames{k})=sim.simulatedvalues(sim.simparams.varindices.(fnames{k}),:);
        thisidx(kk)=idx;
        kk=kk+1;

    end
   
end
 dx=evolveVars (sim.simulatedvalues, simValues, sim.params,sim.simparams,sim.LightIntensity, sim.simparams.quenchmodel  );
            
            
            
            
thesefnames=fields(dx);
out.total=zeros(1,size(dx.(thesefnames{1}),2)); %sum over all fluxes

for k=1:length(thesefnames)
    out.(thesefnames{k})=dx.(thesefnames{k})(thisidx(k),:);
   
    out.total=out.total+out.(thesefnames{k});
     figure(4)
    plot(sim.timevalues, out.total)
    hold on
    
end
