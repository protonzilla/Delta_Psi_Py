function [TransferMatrix Chla]=getTransferMatrix(Q,R,params, mode)

load PSII4LHCTrimers;

tQ = params.tauqE./(Q); % in s; time for quenching of excitation once on minor complex
tCS = params.tauCS./(R);% in ps; time for primary charge separation t o occur, once an excitation
%has reached one of the six central chlorins in the RC

%tCS     = tCS/6; %in ps; time for charge separation to occur, once an excitation
                  % is located on the primary donor

%kT      = params.kconst*params.Tconst;
supersites = 24; %number of individual complexes
RP = 2; %additional radical pairs involved per dimer photosystem

if length(Q)~=length(R)
    error('Q and R do not have the same size');
end

%% Number of chlorophyll a molecules in each complex
% fill in number of chlorophyll molecules per complex
% this quantity doesn't depend on 
Chla = zeros(supersites,1);

% D1/D2
Chla([1 13])   = 6 ;%D1/D2

% CP47
Chla([2 14])  = 16 ;% CP47

% CP29
Chla([3 15])   = 6 ;% CP29

% CP24
Chla([4 16])   = 5;% CP24

% LHCII
Chla([5:10 17:22])=8;  %LHC2 monomoers

% CP26
Chla([11 23])=6;  %CP26

% CP43
Chla([12 24])=13;  %CP43
%%


%%  Load Connectivity Matrix of PSII Model  (see figure 4 of paper)

Conn = PSII4LHCTrimers;

%% Adjacency Matrix
% this matrix is independent of the values of Q and R
% off diagonal elements of A are related to connectivity between complexes
% and probability moves between them using rate tHop
A = zeros(supersites,supersites);  %Adjacency matrix
for i = 1:supersites
    for j = 1:supersites
        
        if Conn(i,j) == 0
            A(i,j,:) = 0;  % sites are not connected
        
        
        elseif (Chla(i) >= Chla(j)) && (i ~= j)  %  number of chlorophylls in column i s greater than number of chlorophylls in column j?
            A(i,j,:) = -1;                         %  fraction of total probability loss (will sum to 1/tHop);
      
        
        elseif Chla(i) < Chla(j)
            A(i,j,:) = -Chla(i)/Chla(j);           %  fraction of probability gain to column i that comes from column j
        end
        
    end
end
%% Set the diagonal elements of the connectivity matrix
%  these elements are dependent on the values of Q and R
%  How probability leaves
T1  =zeros(size(A,1), size(A,2), length(Q));
A_d =zeros(size(A,1), size(A,2), length(Q));

for kk=1:length(Q)
    A_d(:,:,kk)=A;
    
    for k=1:supersites
        try
           
            A_d(k,k,kk) = sum(-A(:,k)) + params.tHop/params.tF;% + (tHop./tCS(kk))*(kdelta(k,1) + kdelta(k,13)) + (tHop/tQ(kk))*(kdelta(k,3) + kdelta(k,15));%+ kdelta(k,4) + kdelta(k,16)+ kdelta(k,11) + kdelta(k,23));
        catch
            disp('err')
        end
        
    end
    T1(:,:,kk) = (-1/params.tHop)*A_d(:,:,kk);  %Transfer Matrix w/o reversible CS
    
end
% To get yields, make sure that there are no rates of transfer out of the
% quenching sites (RC - 1,13, etc.).


%% Transfer Matrix, Calculating Eigenvalues and Eigenvectors


% Include radical pair state that is in equilibrium with excited primary
% electron donor.
% kf   = 1./tCS;                        % forward rate from RC* to RP1 (???Why)
% kb   = kf*exp(-params.deltaG/(kT));   % backward rate from RP1 to RC*
% kRP  = 1./params.tRP;                 % rate for decay of secondary charge sep. state

kQ   = 1./tQ;                           % rate for quenching of excitation from quenching sites
k_Fl = 1./params.tF;

T = zeros(supersites + RP + 4, supersites + RP + 4, length(Q));
T(1:24,1:24,:) = T1;
% 
% T(1,25,:)  =  kb;        % Recombination of initial CS state P680plus_Pheminus
% T(13,26,:) =  kb;        % Recombination of initial CS state
% 
% T(25,1,:)  =  kf;        % Formation of initial CS state
% T(26,13,:) =  kf;        % Formation of initial CS state
% 
% T(25,25,:) = -kRP - kb;  % Probability leaving the first CS state
% T(26,26,:) = -kRP - kb;  % probability leaving the second  cS state
% T(27,25,:) =  kRP;       % decay of secondary charge state
% T(28,26,:) =  kRP;
% 
% T(29,3,:)  =  kQ;        % quenching of chlorophyll antenna by a qE quenching site
% T(30,15,:) =  kQ;        % quenching of chlorophyll antenna by a qE quenching site


% Are sites 25 and 26 completely equivalent to each other? no, because one
% is connected to 13 and one is connected to 1

T(31,1:24,:) = k_Fl;    % Non-radiative relaxation including fluorescence
T(31,25:31,:) = 0  ;

switch mode
    case 'antenna'
        TransferMatrix=T1; % Transfer matrix without reversible CS
    case 'antennaAndRP'
        TransferMatrix=T;  % Transfer matrix with reversible CS
end

