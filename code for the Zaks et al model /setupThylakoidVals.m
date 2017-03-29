function [ lumen stroma]=setupThylakoidVals(inputObject, inputObject2)

if nargin==2%called from ATP synthase
    if isfield(inputObject2, 'LumenMg')
    atpsvars=inputObject;
    inputs=inputObject2;
    
    stroma.Protons=atpsvars(1,:);
    lumen.Protons=atpsvars(2,:);
    
    stroma.Mg=inputs.StromaMg;
    stroma.Cl=inputs.StromaCl;
    stroma.K=inputs.StromaK;
    
    lumen.Mg=inputs.LumenMg;
    lumen.Cl=inputs.LumenCl;
    lumen.K=inputs.LumenK;
    end
     if isfield(inputObject2, 'StromaProtons')
    lumenstromavars=inputObject;
    inputs=inputObject2;
    
    StromaProtons  = inputs.StromaProtons;
    LumenProtons   = inputs.LumenProtons;
    StromaMg       = lumenstromavars(1,:);
    LumenMg        = lumenstromavars(2,:);
    StromaCl       = lumenstromavars(3,:);
    LumenCl        = lumenstromavars(4,:);
    StromaK        = lumenstromavars(5,:);
    LumenK         = lumenstromavars(6,:);
    
    stroma.Protons =StromaProtons;
    stroma.Mg      =StromaMg;
    stroma.Cl      =StromaCl;
    stroma.K       =StromaK;
    
    lumen.Protons  =LumenProtons;
    lumen.Mg       =LumenMg;
    lumen.Cl       =LumenCl;
    lumen.K        =LumenK;
    end
    
end

if isstruct(inputObject) %input is sim
    sim=inputObject;
    stroma.Protons=sim.simulatedvalues(  find(strcmp(sim.simparams.varsforsim, 'StromaProtons')),:);
    stroma.Mg     =sim.simulatedvalues(find(strcmp(sim.simparams.varsforsim, 'StromaMg')),:);
    stroma.Cl     =sim.simulatedvalues(find(strcmp(sim.simparams.varsforsim, 'StromaCl')),:);
    stroma.K=sim.simulatedvalues(find(strcmp(sim.simparams.varsforsim, 'StromaK')),:);
    
    lumen.Protons=sim.simulatedvalues(  find(strcmp(sim.simparams.varsforsim, 'LumenProtons')),:);
    lumen.Mg     =sim.simulatedvalues(find(strcmp(sim.simparams.varsforsim, 'LumenMg')),:);
    lumen.Cl     =sim.simulatedvalues(find(strcmp(sim.simparams.varsforsim, 'LumenCl')),:);
    lumen.K      =sim.simulatedvalues(find(strcmp(sim.simparams.varsforsim, 'LumenK')),:);
    
end
 
end