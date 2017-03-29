function [s q]=getStaticVals(sim)

[ lumen stroma]=setupThylakoidVals(sim); 
f=fields(stroma);
for k=1:length(f)
    
    if (size(stroma.(f{k}),1)==0)
        fname=['Stroma' f{k} 'Start'];
        stroma.(f{k})=sim.params.(fname);
        
    end
end

s=getStaticThylakoidValues(lumen, stroma, sim.params);
quenchingvars=[getVar(sim,'Antheraxanthin') ; getVar(sim,'Zeaxanthin'); getVar(sim,'PsbSQ')];
q=getStaticQuencherValues(quenchingvars, s.pHLumen, sim.params, sim.simparams.quenchmodel);
