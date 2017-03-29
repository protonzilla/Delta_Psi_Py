%% evolvecytb6f
%
% Simulates plastoquinol oxidation at cytochrome b6f complex
%%
function out=evolvecytb6f( cytb6fvars,inputs,params)

%variables: Plastocyanin, P700, FeS, Ferredoxin,
%inputs: dPc/dC


%% Load Variables
PQ            = cytb6fvars(1,:);
PQH2            = cytb6fvars(2,:);
PCr            = cytb6fvars(3,:);
LumenProtons    = cytb6fvars(4,:);
%PQH2=params.QuinonePoolSize-PQ;


PCox=params.PCperPSI-PCr;

%% Get Static Variables
pHLumen         = getLumenpH(LumenProtons,params);
FractionActiveCytochrome=1-pHEquilibriumProtonate(pHLumen, params.pKaC, params.nC);
FractionActivePC=PCox/params.PCperPSI;
FractionPQr=     PQH2./(PQ+PQH2);
FractionPQox=     PQ/params.QuinonePoolSize;
FractionActivity=FractionActiveCytochrome.*FractionActivePC.*FractionPQr;

%% Evaluate rates
rates(1,:)= params.QReoxidationRate .*FractionActivity;

%% Evaluate Differential Equations
dPQ       =      rates(1,:);
dPQH2       =      -rates(1,:);
dPCr        =      (2/params.ElectronsPerPC)*rates(1,:);
dLumenProtons       =     4*rates(1,:)./(params.Na*params.LumenVolume);%Moles per Liter; 4 protons per PQH2 molecule



out=[dPQ;  dPQH2;  dPCr; dLumenProtons];





