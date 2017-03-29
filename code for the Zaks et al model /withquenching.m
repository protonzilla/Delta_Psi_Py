%%% Exciton Migration in PSII %%%
% Broess, et al., 2006, Biophys J., Vol. 91, pp. 3776-3786
% Full Model with secondary charge separation included
% Quenching sites incorporated

clear all

%%% Variables
tHop = 3.5; %in ps; time for transfer between all connected complexes
tQ = 0.5; %in ps; time for quenching of excitation once on minor complex
tCS = 5.5; %in ps; time for primary charge separation t o occur, once an excitation
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

importfile('C:\Documents and Settings\Admin\My Documents\MATLAB\Research\PSII Energy Transfer\PSII4LHCTrimers.asc')

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
    A(k,k) = sum(-A(:,k)) + (tHop/tCS)*(kdelta(k,1) + kdelta(k,13)) + (tHop/tQ)*(kdelta(k,3) + kdelta(k,15)+ kdelta(k,4) + kdelta(k,16)+ kdelta(k,11) + kdelta(k,23)); 
end
% Right now, all the minor complexes are sites of quenching
% To get yields, make sure that there are no rates of transfer out of the
% quenching sites (RC - 1,13, etc.).


%%% Transfer Matrix, Calculating Eigenvalues and Eigenvectors

T1 = (-1/tHop)*A;  %Transfer Matrix w/o reversible CS

% Include radical pair state that is in equilibrium with excited primary
% electron donor.
kf = 1/tCS; %forward rate from RC* to RP1
kb = kf*exp(-deltaG/(kT));  %backward rate from RP1 to RC*
kRP = 1/tRP;  %rate for decay of secondary charge sep. state

T = zeros(supersites + RP, supersites + RP);
T(1:24,1:24) = T1;
T(1,25) = kb;
T(13,26) = kb;
T(25,1) = kf;
T(26,13) = kf;
T(25,25) = -kRP - kb;
T(26,26) = -kRP - kb;


[phi, dummy] = eig(T); %phi are the eigenvectors of T in terms of our basis of supersites
lambda = dummy;  %lambda is a diagonal matrix with the eigenvalues of T

%%% Time evolution of P

% The transformation matrix between the coupled basis and our site basis is
C = phi;  %see p. 130-131 of Cohen-Tannoudji

phi0 = eye(supersites + RP);  %matrix with eigenvectors of our basis

% evolve this state in time
dt = 1;  % in ps
t=0:dt:1000;
% construct convenient array to hold the values of P(t)
phistory = zeros(supersites+RP,length(t));

% initial condition: construct an arbitrary state vector in the site basis as your initial
% condition 
phistory(:,1) = phi0(:,17); % our choice here is all population on site

% Let's try the same initial condition as in the paper: initial populations
% based on number of Chl a's in each complex.
% init = Chla ./ sum(Chla);
% phistory(1:24,1) = init;

% The "time evolution" operators
TevolveExciton = diag(exp( diag(lambda) * dt  ));  %time evolution operator in coupled basis
TevolveSite = C * TevolveExciton/C;  %time evolution operator in our basis; TevolveExciton/S = TevolveExciton * inv(S)

totprob = zeros(1,length(t));
totprob(1) = sum(phistory(:,1));

for j = 2:length(t)
    % Evolve the state vector using the site basis evolution operator
    phistory(:,j) = TevolveSite * phistory(:,j-1);
    totprob(j) = sum(phistory(1:24,j));
    
end

plot(totprob)


%%% Mean Lifetime

L = zeros(1,supersites+RP);
for i=1:(supersites+RP)
    L(i)=lambda(i,i);
end
Linv = 1 ./ L;
invlambda = diag(Linv);

tAvgvec = -C * invlambda/C * phistory(:,1);
tAvg = sum(tAvgvec(1:24));


%%% Animation of Energy Transfer
% Need phistory, pixel dimensions of PSII, widths in pixels of the
% complexes.
% 
% 
% imagedim = zeros(857,891);
% 
% importfile('C:\Documents and Settings\Admin\My Documents\MATLAB\Research\PSII Energy Transfer\PSIIcoords.asc')
% % This file is a supersites x 4 array.  The first column is the site, the
% % second is the row, the third the column, and the fourth is the diameter.
% 
% coords = PSIIcoords;
% 
% 
% tt = 1:10:ceil((1/2)*length(t));
% 
% aviobj = avifile('example3.avi','compression','None', 'fps',2);
% 
% 
% 
% for p=1:length(tt)
%     
%     imagedim = zeros(857,891);
%     
%     for i=1:supersites
%         
%         sigma = ceil((PSIIcoords(i,4))/3.5);
%         A = phistory(i,tt(p));
%         center = [PSIIcoords(i,2),PSIIcoords(i,3)];  %row, column
%         
%         xval = (center(2)-(2*sigma)):1:(center(2)+(2*sigma));
%         yval = (center(1)-(2*sigma)):1:(center(1)+(2*sigma));
%         
%         repgauss = Gaussian(A,sigma,center,xval,yval);
%         
%         imagedim = imagedim + repgauss;
%         
%         
%         
%     end
%     
%     imagedim(1,1) = 0.01;%1.2e-6;
%     contourf(imagedim);
%     set(gca, 'YDir', 'reverse')
%     shading flat
%     Frames(p) = getframe;
%     aviobj = addframe(aviobj,Frames(p));
% 
%   
% end
% 
% movie(Frames)
% aviobj = close(aviobj);

