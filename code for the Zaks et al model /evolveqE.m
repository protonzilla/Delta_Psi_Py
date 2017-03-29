%% evolveqE
% Evolves Xanthophyll cycle variables 
%%
function out=evolveqE(qEvars, inputs, params)

%% Get Variables and inputs
Anth=qEvars(1,:);
Zea=qEvars(2,:);
PsbSQ=qEvars(3,:);
Vio=params.TotalXanthophyll-Zea-Anth;
%%
% get auxiliary inputs
%%
pHLumen=getLumenpH(inputs.LumenProtons, params);
ActiveVDE=pHEquilibriumProtonate(pHLumen, params.VDEpKa, params.nVDE);
ActivePsbS=pHEquilibriumProtonate(pHLumen, params.PsbSpKa, params.nPsbS);

%%Calculate Rates
rates(1,:)=params.VDErateVioToAnth.*ActiveVDE.*(Vio);
rates(2,:)=params.VDErateAnthToZea.*ActiveVDE.*(Anth);
rates(3,:)=params.ZErate.*Zea;
rates(4,:)=params.ZErate.*Anth;
rates(5,:)=params.PsbSConvertRate .* ActivePsbS .* (1-PsbSQ);
rates(6,:)=params.PsbSConvertRate  .* (1-ActivePsbS) .* PsbSQ;
%%


%% Calculate Differential Equations
dAnth    =  rates(1,:)-rates(2,:)+rates(3,:)-rates(4,:); %Anth
dZea     =  rates(2,:)-rates(3,:); %dZea
dPsbSQ   =  rates(5,:)-rates(6,:); %dZea

out=[dAnth; dZea ; dPsbSQ];


end