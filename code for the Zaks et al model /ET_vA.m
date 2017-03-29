function [rate_f, rate_qe, rate_rc] = ET_vA(Q, R )
%ET_vA This function has as input arguments the fraction of open reaction centers R, the fraction
% of open quenching sites Q, rate of quenching and the
%rate of charge separation in the RC and as output arguments, the quantum
%yields of fluorescence, quenching, and charge separation.
%   R and Q are numbers between 0 and 1
%   PSII4LHCTrimers is a .asc file with the connectivity of of all the
%   complexes that is used in Broess, et al., 2008, BBA.  Need to import
%   that file to workspace before using this function.
load PSII4LHCTrimers

tauqE = 10.0;
%   tauqE is the time (1/rate) in ps of energy dissipation at a quenching site (here,
%   CP29) such that, when Q = 1 and R = 0, the average lifetime is 330 ps.
tauCS = 5.5;
%   tauCS is the time (1/rate) of energy dissipation at the reaction center such
%   that, when Q = 0 and R = 1, the average lifetime is 260 ps with the migration time half of
%   the overall lifetime.  (van Oort, Biophys. J, 2010)
tF = 2000;
%   tF is the time    (1/rate) of fluorescence of excitations in the
%   antenna in ps.



%%% Variables
tHop = 17.0; %in ps; time for transfer between all connected complexes

tQ = 1/(Q*1/tauqE); %in ps; time for quenching of excitation once on minor complex

tCS = 1/(R*1/tauCS); %in ps; time for primary charge separation to occur, once an excitation
%has reached one of the six central chlorins in the RC

tiCS = tCS/6; %in ps; time for charge separation to occur, once an excitation
% is located on the primary donor
tRP = 137; %in ps; time for secondary charge separation to occur,
%once primary charge separation has occurred
deltaG = 826; % in cm^-1; drop in free energy upon primary CS; determines equil.
k = 0.695; %Boltzmann constant in cm^-1/K
T = 286; % temperature, in Kelvin
kT = k*T;
supersites = 24; %number of individual complexes
RP = 2; %additional radical pairs involved per dimer photosystem


%%% Number of chlorophyll a molecules in each complex
Chla = zeros(supersites,1);
for i = 1:supersites
    
    if i==1 || i==13
        Chla(i) = 6;  %D1/D2
    end
    
    if i==2 || i==14
        Chla(i) = 16; %CP47
    end
    
    if i==3 || i==15
        Chla(i) = 6;  %CP29
    end
    
    if i==4 || i==16
        Chla(i) = 5;  %CP24
    end
    
    if (i>=5 && i<=10) || (i>=17 && i<=22)
        Chla(i) = 8;  %LHC2 monomers
    end
    
    if i==11 || i==23
        Chla(i) = 6;  %CP26
    end
    
    if i==12 || i==24
        Chla(i) = 13; %CP43
    end
    
end

%%% Connectivity Matrix of PSII Model  (see figure 4 of paper)

Conn = PSII4LHCTrimers;

%%% Adjacency Matrix

A = zeros(supersites,supersites);  %Adjacency matrix
for i = 1:supersites
    for j = 1:supersites
        
        if Conn(i,j) == 0
            A(i,j) = 0;
        elseif (Chla(i) >= Chla(j)) && (i ~= j)
            A(i,j) = -1;
        elseif Chla(i) < Chla(j)
            A(i,j) = -Chla(i)/Chla(j);
        end
        
    end
end


for k=1:supersites
    A(k,k) = sum(-A(:,k)) + tHop/tF + (tHop/tCS)*(kdelta(k,1) + kdelta(k,13)) + (tHop/tQ)*(kdelta(k,3) + kdelta(k,15));%+ kdelta(k,4) + kdelta(k,16)+ kdelta(k,11) + kdelta(k,23));
end
% To get yields, make sure that there are no rates of transfer out of the
% quenching sites (RC - 1,13, etc.).


%%% Transfer Matrix, Calculating Eigenvalues and Eigenvectors

T1 = (-1/tHop)*A;  %Transfer Matrix w/o reversible CS

% Include radical pair state that is in equilibrium with excited primary
% electron donor.
kf = 1/tCS; %forward rate from RC* to RP1
kb = kf*exp(-deltaG/(kT));  %backward rate from RP1 to RC*
kRP = 1/tRP;  %rate for decay of secondary charge sep. state
kQ = 1/tQ; %rate for quenching of excitation from quenching sites

T = zeros(supersites + RP + 4, supersites + RP + 4);
T(1:24,1:24) = T1;
T(1,25) = kb;
T(13,26) = kb;
T(25,1) = kf;
T(26,13) = kf;
T(25,25) = -kRP - kb;
T(26,26) = -kRP - kb;
T(27,25) = kRP;
T(28,26) = kRP;
T(29,3) = kQ;
T(30,15) = kQ;

[phi, dummy] = eig(T); %phi are the eigenvectors of T in terms of our basis of supersites
lambda = dummy;  %lambda is a diagonal matrix with the eigenvalues of T

%%% Time evolution of P

% The transformation matrix between the coupled basis and our site basis is
C = phi;  %see p. 130-131 of Cohen-Tannoudji

phi0 = eye(supersites + RP);  %matrix with eigenvectors of our basis

% evolve this state in time
dt = 5;  % in ps
t=0:dt:5000;

% initial condition: construct an arbitrary state vector in the site basis as your initial
% condition
% initial populations
% based on number of Chl a's in each complex.
init = Chla ./ sum(Chla);
phistory = zeros(30,1);
phistory(1:24,1) = init;

% The "time evolution" operators
TevolveExciton = diag(exp( diag(lambda) * dt  ));  %time evolution operator in coupled basis
TevolveSite = C * TevolveExciton/C;  %time evolution operator in our basis; TevolveExciton/S = TevolveExciton * inv(S)

totprob = zeros(1,length(t));
totprob(1) = sum(phistory(:,1));

for j = 2:length(t)
    % Evolve the state vector using the site basis evolution operator
    phistory(:,j) = TevolveSite * phistory(:,j-1);
    totprob(j) = sum(phistory(1:30,j));
    
end


f2=phistory(29,:)+phistory(30,:);
f2_norm=f2/max(f2);
[m idx_2]=min(abs(f2_norm-(1-exp(-1))));
tau_qe=dt*(idx_2-1);


f1=phistory(27,:)+phistory(28,:);
f1_norm=f1/max(f1);
[m idx_1]=min(abs(f1_norm-(1-exp(-1))));
tau_rc=dt*(idx_1-1);


QY_Q = phistory(29,j) + phistory(30,j);
QY_CS = phistory(27,j) + phistory(28,j);
QY_Fl = 1 - QY_Q - QY_CS;

rate_rc=1/(tau_rc*1e-12);
rate_qe=1/(tau_qe*1e-12);
rate_f = 1/(tF*1e-12);


end

