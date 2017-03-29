%% evolve MV
% MV stands for Methyl Viologen, which is a strong oxidizing agent added to
% chloroplasts in order to act as an electron acceptor. 
% The advantage of this over-simplified scenario is that is is
% mathematically straighforward to describe with a single rate costant
% removing electrons from reduced ferredoxin. We also have an expression
% for the concentration of reduced thioredoxin
%%

function dx=evolveMV(MVvars, inputs, params)

%% Load Variables

Fdxr            =  MVvars(1,:);
Fdxox           =  MVvars(2,:);
Thrdx           =  MVvars(3,:);



%% Calculate Rates
rates(1,:)=params.kETFdxMV*Fdxr; %electrons from ferredoxin to Methyl Viologen
rates(2,:)=params.kETFdxThrdx*Fdxr; %electrons from ferredoxin to thioredoxin
rates(3,:)=params.kETThrdxOx*Thrdx; %oxidation of reduced thioredoxin


rates=rates.*(rates>0);%rates should be nonnegative

%% Calculate Differential Equations
dFdxr           = -rates(1,:);
dFdxox           = rates(1,:);
dThrdx           = rates(2,:)-rates(3,:);


dx=[dFdxr; dFdxox; dThrdx] ;

   