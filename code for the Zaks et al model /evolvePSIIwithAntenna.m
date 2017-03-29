%% evolve PSII
% Simulates light harvesting, qE quenching, and energy and electron
% transfer to reaction center to $Q_A$
%%


function [out lhrates]=evolvePSIIwithAntenna( PSIIvars,inputs,params)

%% Setup Variables
LightIntensity=inputs.LightIntensity;

%make ChlEx a 24 by 24 matrix of antenna chlorophylls
ChlEx         =     PSIIvars(1,:);
P680ex        =     PSIIvars(2,:);
P680plus      =     PSIIvars(3,:);
PheAnion      =     PSIIvars(4,:); %Pheophytin

QAox          =     PSIIvars(5,:);  
LumenProtons  =     PSIIvars(6,:);


%% Get inputs
lumen.Protons=LumenProtons;
lumen.Mg = inputs.LumenMg;
lumen.Cl =inputs.LumenCl;
lumen.K=inputs.LumenK;
stroma.Protons=1e-14*ones(size(lumen.Protons));
stroma.Cl=params.StromaClStart;
stroma.Mg=params.StromaMgStart;
stroma.K=params.StromaKStart;
s=getStaticThylakoidValues(lumen, stroma, params);

%%
% Calculate effect of transmembrane electric field (|s.deltapsi|) on
% electron transfer. We assume
%
% $$k_{ET} \sim e^{- \alpha \Delta \Psi}$$
%     
% 
% where $\alpha$ is  a coefficient that is a measure of the effect of the
% transmembrane electric field on the rate of electron transfer. Following
% Rubin and Riznichenko (Photosynthesis In Silico, 2009), we use
% $$\alpha=0.4$
% for electron transfer through thr RC and $\alpha=0.1$ for electron transfer
% through the plastoquinone pool
%%
EfieldSlowDownR=exp(-params.alphaRC*s.deltapsi/params.voltsperlog);
EfieldSlowDownQ =exp(-params.alphaQ*s.deltapsi/params.voltsperlog);

nrates=18;
rates=zeros(nrates, size(PSIIvars,2));
s=size(PSIIvars);
QAred=ones(size(QAox))-QAox;

P680neut=ones(size(P680ex));
%to be more precise, this can be replaced with
%max(0,(1-P680ex-P680broken-P680plus));

Pheneut=1-PheAnion;
dPheneut=-ones(size(PheAnion));
IntactRC=(params.fracIntactRC);
QAred=QAred.*IntactRC;
dQAred=-ones(size(QAox));
Pheneut=Pheneut.*IntactRC;

pHLumen=getLumenpH(LumenProtons, params);

quenchingvars=[inputs.Antheraxanthin ; inputs.Zeaxanthin; inputs.PsbSQ];
q=getStaticQuencherValues(quenchingvars, pHLumen, params, inputs.quenchmodel);

lhrates.Qfrac=q.TotalQ;


%% Light Absorption
%
% The variable $[ChlEx]$ represents the number of excited chlorophylls 
% associated with one PSII. The cross section $\sigma$ determines how
% many chlorophylls per PSII get excited per $\mu$mol photon $m^{-2} s$
% It can in principle be greater than 1 if, for
% example, all 250 chlorophylls are excited, but in reality the value
% should always be much lower than 1 in normal sunlight intensities because
% the lifetime of chlorophyll in the PSII antenna is short (<1 ns) compare
% to the number of photons absorbed PSII in full sunlight (~1000-2000 per second).
%
% The Appearance of excited chlorophylls in PSII antenna uses the equation
%
% $\frac{d[ChlEx]}{dt}=I \sigma [RCO]$
%
% number of 
%%
rates(1,:)    =   LightIntensity.*params.crosssection.*IntactRC;

%% qE quenching of Excited Chlorophylls
%
% quenching of excited chlorophylls in PSII by a qE site  uses the equation
%
% $\frac{dChl}{dt}=-k_Q  \times ChlEx \times [Q]$
% where $[Q]$ is the fraction of possible quenching sites
%%
rates(2,:)   =    params.kQ.*ChlEx.*(lhrates.Qfrac);                 

%% Non-qE Exciton Quenching in Antenna
rates(3,:)   =    params.kF.*ChlEx;                                  
%fluorescence

rates(4,:)   =    params.kquenchP680plus.*ChlEx.* P680plus;       
%Quenching by P680+

rates(5,:)   =    params.kNRantenna.*ChlEx ;                       
%Nonradiative Quenching in Antenna (ISC, IC)

%% Energy Transfer to open P680
% Excitation energy is trapped by 
% 
rates(7,:)   =   (params.kEETLHP680QAox*ChlEx.*QAox ...
                + params.kEETLHP680QAred*ChlEx.*QAred).*P680neut ;   
% energy transfrom from antenna to P680; 
% P680neut is so close to 1 that we don't multiply by it for simplicty
%%
% Energy can also transfer from excited P680 back to the PSII antenna,
%%

rates(8,:)       =   params.kEETLHP680revQAox.*P680ex.*QAox ...
                 +   params.kEETLHP680revQAred.*P680ex.*QAred ; 


%% Non-radiative dissipation of P680

rates(9,:)          =   params.kNRP680.*P680ex;              
%intersystem crossing to form chlorophyll triplet



%% Electron transfer

rates(12,:)  =   params.kETP680PheOpenRC.*  P680ex.*Pheneut.* ...
    QAox .* EfieldSlowDownR;  
%electron transfer between P680 and Phe, open RC

rates(13,:)  =   params.kETP680PheClosedRC.* P680ex.*Pheneut.* ...
    QAred .* EfieldSlowDownR;  
%electron transfer between P680 and Phe, closed RC

rates(14,:)         =   params.kETPheToQA.*PheAnion.*QAox .* EfieldSlowDownR; 
%electron transfer pheophytin to QA

rates(15,:)         =   params.kETWaterOxidation.*P680plus .* EfieldSlowDownQ ; 
% water oxidation

%% Electron recombination

rates(16,:)=params.kP680Pherecombination.*P680plus.*PheAnion./EfieldSlowDownR; 
%recombination P680^+ and Phe causes damage

rates(17,:)= params.kP680QArecombination.*P680plus.* QAred.*(Pheneut)./ EfieldSlowDownR; 
%recombination P and Q, Phe neutral

rates(18,:)= params.kP680QArecombinationClosedRC.*P680plus.* QAred.*PheAnion./EfieldSlowDownR; 
%recombination P and Q, Phe reduced


%% Combining Rates into Differential Equations

rates=rates.*(rates>0);
ChlExrateindices=[ 1 8  2  3   4    5     7]; 
ChlExratesigns  =[ 1 1 -1 -1 -1  -1   -1];

dChlEx         =sumoverrates(rates, ChlExrateindices, ChlExratesigns);


P680exrateindices=[7 8 9 10  12  13]; 
P680exsigns      =[1 -1 -1 -1 -1 -1];
dP680ex         = rates(7,:)-rates(8,:)-rates(9,:)-rates(10,:)-rates(12,:) -rates(13,:);
dP680ex         =sumoverrates(rates, P680exrateindices, P680exsigns);

P680plusrateindices =[12 13   15  16  17 18];
P680plussigns         =[1   1    -1  -1  -1  -1];

dP680plus     =   sumoverrates(rates, P680plusrateindices, P680plussigns);

a=rates(12,:)+rates(13,:)-rates(14,:)-rates(15,:)-rates(16,:)-rates(17,:)-rates(18,:);


PheAnionrateindices =[12 13 14 16];
PheAnionsigns        =[1   1  -1  -1];
dPheAnion   =   sumoverrates(rates, PheAnionrateindices, PheAnionsigns);


dQAox =   -rates(14,:)+rates(17,:) +rates(18,:);
%%
% for calculating proton flux, we need to convert number of protons per PSII,
% which is the quantity given in rate 15, to moles of protons per liter: 
%%
dLumenProtons= rates(15,:)./(params.Na*params.LumenVolume);


%% Create Output Vector
lhrates.dx=[ dChlEx ; dP680ex ;  dP680plus ; dPheAnion ;dQAox ; dLumenProtons];
out=lhrates.dx;

lhrates.rates=rates;



 
%% Function to Sum Over Rates
function foo=sumoverrates( matrix, indices,signs )
extractedvalues=matrix(indices,:,:);
s=size(matrix);
foo=zeros([1 s(2:end)]);
for j=1:length(signs)
try foo=foo+signs(j)*extractedvalues(j,:,:);
catch
    a='err'; 
    %one can put a breakpoint here for debugging purposes
end
end