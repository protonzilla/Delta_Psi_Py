%% getStaticQuencherValues
%%
function out=getStaticQuencherValues(quenchingvars,pHLumen,params, quenchmodel)

if strcmp(quenchingvars,'getallmodes'); % this option is for the GUI
allmodes={'0--No Quenching' ...
          '1--PsbS* [z * (Zea+0.5 Anth) + (1-z)* Lut]' ...
          '2--PsbS* Lut' ...
          '3--PsbS* [z * (Zea+0.5 Anth)]' ...
          '4--PsbS'};
out=allmodes;
return;
else

%% Load Variables
out.Anth  = quenchingvars(1,:);
out.Zea   = quenchingvars(2,:);
out.PsbSQ = quenchingvars(3,:);


%% Calculate pH-sensitive quantities
out.ActivePsbS = pHEquilibriumProtonate(pHLumen, params.PsbSpKa, params.nPsbS);
out.ActivePsbS = out.PsbSQ;
out.ActiveVDE  = pHEquilibriumProtonate(pHLumen, params.VDEpKa, params.nVDE);

%parameters for quenching :k_Q: rate of quenching, f.constantquench


%% Select Quenching Mechanism
switch quenchmodel
    case 0
        %no quenching
        out.QuenchersXanthophyll=zeros(size(out.Zea));
        out.QuenchersLutein=zeros(size(out.PsbSQ));
  
    case 1
        %PsbS *(Zeaxanthin +lutein)     
        out.QuenchersXanthophyll=params.zfrac.*(out.Zea+0.5*out.Anth).*out.ActivePsbS;
        out.QuenchersLutein=(1-params.zfrac)*out.ActivePsbS;

        
    case 2
        %No Zeaxanthin; npq1
        out.QuenchersXanthophyll=0;
        out.QuenchersLutein=(1-params.zfrac)*out.ActivePsbS;
       
       
    case 3
        %No lutein; lut2
        out.QuenchersXanthophyll=params.zfrac.*(out.Zea+0.5*out.Anth).*out.ActivePsbS;
        out.QuenchersLutein=0;
        
    case 4
        %all zeaxanthin and lutein;npq2
        out.QuenchersXanthophyll=params.zfrac.*out.ActivePsbS;
        out.QuenchersLutein=(1-params.zfrac).*out.ActivePsbS;   
        
        
end
end
%% effect of PsbS Dosage
out.TotalQ=params.PsbSDose.* (out.QuenchersXanthophyll+out.QuenchersLutein);
