%% evovePQ
% simulates electron transfer through plastoquinone pool, from $Q_A$ to
% plastoquinol
%%

function dx=evolvePQ(quinonevars, inputs, params)

%% Load Variables

QAox       =     quinonevars(1,:); %quinols
QBox       =     quinonevars(2,:);
QBred1     =     quinonevars(3,:); %quinols
QBred2     =     quinonevars(4,:);
PQ         =     quinonevars(5,:);
PQH2       =     quinonevars(6,:);
QBempty    =     1-QBox-QBred1-QBred2;

%PQH2=params.QuinonePoolSize-PQ-QBox-QBred1-QBred2;
PQfrac=PQ/params.QuinonePoolSize;
PQH2frac=PQH2/params.QuinonePoolSize;
QAred=1-QAox;

%% Get Static Variables
lumen.Protons=inputs.LumenProtons;
lumen.Mg = inputs.LumenMg;
lumen.Cl=inputs.LumenCl;
lumen.K=inputs.LumenK;
stroma.Protons=1e-14*ones(size(lumen.Protons));
stroma.Cl=params.StromaClStart;
stroma.Mg=params.StromaMgStart;
stroma.K=params.StromaKStart;

s=getStaticThylakoidValues(lumen, stroma, params);



%% Calculate Rates

EfieldSlowDownQ =exp(-params.alphaQ*s.deltapsi/params.voltsperlog);
rates(2,:)= params.kETQAtoQB1.*QAred.*QBox.*EfieldSlowDownQ; %electron transfer fromr Qa to Qb, reducing QB and oxidizeing QA
rates(3,:)= params.kETQAtoQB2.*QAred.*QBred1.*EfieldSlowDownQ ;%electron transfer from A to QB (singly reduced)
rates(4,:)= params.kETQB1toQA.*QAox.*QBred1;
rates(5,:)= params.kETQB2toQA.*QAox.*QBred2;
rates(6,:)= params.PQdockingrate.*PQfrac.*QBempty;
rates(7,:)= params.PQH2undock.*QBred2;
rates(8,:)= params.PQH2undock.*PQH2frac/10;
rates(9,:)= params.PQdockingrate.*QBox/10;




 %% Calculate Differential Equations
dQAox        =   rates(2,:)  + rates(3,:)  -rates(4,:)-rates(5,:);
dQBox        =   rates(6,:)  + rates(4,:)  -rates(2,:);
dQBred1      =   rates(2,:)+rates(5,:)-rates(3,:)-rates(4,:);
dQBred2      =   rates(3,:)-rates(7,:)-rates(5,:)+rates(8,:);
dQBempty     =   rates(7,:) -rates(6,:)-rates(8,:) ;
dPQ          =  -rates(6,:) ;
dPQH2        =   rates(7,:) -rates(8,:);

dx=[    dQAox ; dQBox; dQBred1; dQBred2;  dPQ; dPQH2];
