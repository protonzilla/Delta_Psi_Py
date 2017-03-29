%% evolvePSI
% Simulates light intensity-dependent electron transfer from plastocyanin to ferredoxin 
%%

function out=evolvePSI( PSIvars, inputs, params)

%% Load Variables



PCr      =     PSIvars(1,:) ;
P700ox   =     PSIvars(2,:) ;
P700r    =     PSIvars(3,:) ;
Fdxr     =     PSIvars(4,:) ;
Fdxox    =     PSIvars(5,:) ;
TotalLEF =     PSIvars(6,:);

PCox   =    params.PCperPSI-PCr  ;


%% Calculate Rates
rates(1,:)= params.kETPCP700   .*PCr.*P700ox;       %electron transfer from Plastocyanin to P700;
rates(2,:)= inputs.LightIntensity*params.PSIcrossSection.*params.kETP700Fdx.*P700r .* Fdxox ;       %Electron transfer from P700 to ferredoxin


rates=rates.*(rates>0); %enforce nonnegativity of rates

%% Calculate Differential Equations
dPCr      =  -rates(1,:);
dP700ox   =  -rates(1,:) +rates(2,:) ;
dP700r    =  rates(1,:) -rates(2,:) ;
dFdxr     =  rates(2,:);
dFdxox    = -dFdxr;
dTotalLEF =rates(2,:);


out=[dPCr;  dP700ox; dP700r; dFdxr; dFdxox; dTotalLEF];





