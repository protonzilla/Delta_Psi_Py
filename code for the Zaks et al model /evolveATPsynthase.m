%% evolveATPsynthase
%
% simulates proton efflux through ATP synthase driven by proton motive
% force
%%
function out=evolveATPsynthase( atpsvars,inputs,params)



%% Setup Variables
LumenProtons      =atpsvars(1,:);
ATP               =atpsvars(2,:);
ActiveATPs        =atpsvars(3,:);
InactiveATPs=1-ActiveATPs;

%% Setup and Get Auxiliary Values
lumen.Protons=LumenProtons;
lumen.Mg = inputs.LumenMg;
lumen.Cl=inputs.LumenCl;
lumen.K=inputs.LumenK;
stroma.Protons=1e-14*ones(size(lumen.Protons));
stroma.Cl=params.StromaClStart;
stroma.Mg=params.StromaMgStart;
stroma.K=params.StromaKStart;
s=getStaticThylakoidValues(lumen, stroma, params);
FractionADP=1;

%% Calculate Rates
% calculate flux of ions through thylakoid membrane
% if pmf is positive, protons flow out of lumen

rates(1,:)= params.ATPConductivity.* (s.pmf-params.thresholdpmf) ...
            .* ((s.pmf-params.thresholdpmf)>0).* FractionADP.*ActiveATPs; 

% units of Moles Protons/area flowing out of lumen into stroma
rates(2,:)=params.leakConductivity.*(s.pmf-params.leakpmf) ...
             .* ((s.pmf-params.leakpmf)>0);

% ATP synthase is activated by linear electron flow from Ferredoxin
rates(3,:)=params.kATPsActivate.*inputs.Fdxr.*InactiveATPs;
rates(4,:)=params.kATPsInactivate.*ActiveATPs;

%% Differential Equations
% Combine rate equations

dLumenProtons   =  -fluxToConcentration(rates(1,:)+rates(2,:), 'lumen', params);

% We assume 12 Protons pumped through ATP synthase per 3 ATP molecules
% synthesized
ATPperProton=3/12;
%rates(4,:) is in moles protons per liter; ActiveATPs is in ATP per PSII,
%so we multiple by a conversion factor
vscale=params.Na*params.LumenVolume/params.lumenVolumePerArea;
dATP            =  (rates(1,:))*ATPperProton *vscale ; 

dActiveATPs     =   rates(3,:)-rates(4,:);

out=[dLumenProtons; dATP; dActiveATPs];