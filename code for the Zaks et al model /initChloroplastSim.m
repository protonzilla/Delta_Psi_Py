
%%initChloroplastSim
%%


%%
% * |sp stands| for "simulation parameters".
% * |sp.varnames| is a structure with the names of the variables in each modeule
% * |sp.init| is the initial values for a given simulation
% * |sp.function| is a function that evolves PSII
% * |sp.inputs| is a structure of variablees from other modules that are not
% modified by the function
%
%%


function sp =initChloroplastSim(mode, params, quenchmodel)


%% Select Mode for Simulation

%list all the available modes

if strcmp(mode,'getallmodes');
allmodes={'PSI' 'LEF' 'PSII' 'CEF' 'LEFCEF'  'PSIITrapLake'  'PSIIAntenna' 'PSIIAntennatest'};
sp=allmodes;
return;
else
switch mode
    
    case 'PSI'
        vars={'PSI' };
    
    case 'LEF'
        vars={   'PSII' 'qE' 'PQ' 'cytb6f'    'PSI'  'LumenFlux' 'KeaFlux' 'ATPsynthase' 'Stroma' };
        
    case 'PSII'
        vars={   'PSII' 'qE' 'PQ' 'cytb6f' 'LumenFlux' 'KeaFlux'};
        
    case 'CEF'
        vars={   'CEF' 'PQ' 'cytb6f' 'PSI' 'LumenStromaFlux' 'Stroma'};
    
    case 'LEFCEF'
        vars={   'PSII' 'PQ' 'qE' 'CEF' 'cytb6f'  'Stroma'};
        
    case 'PSIITrapLake'
        vars={   'PSII' 'qE' 'PQ'   'cytb6f' 'PSI' 'MV'  'ATPsynthase' 'LumenFlux' 'KeaFlux' };
    
    case 'PSIIAntenna'
        vars={   'PSII_Antenna' 'PSII_RC' 'qE' 'PQ'   'cytb6f' 'PSI' 'MV'  'ATPsynthase' 'LumenFlux' 'KeaFlux' };
   
    case 'PSIIAntennatest'
        vars={   'PSII_Antenna' 'PSII_RC' 'qE'  'LumenFlux' 'KeaFlux' };
        
    otherwise
        error('mode does not exist');
end
end
%%

%% Specify Initial Conditions
zerolh=1e-14;
zeroq=1e-7;
lumenProtonsStart  =  zerolh;
stromaProtonsStart =  params.StromaProtonsStart;
pqstart=.001;
QAoxstart=1-zeroq;
PCrstart=.2;
NADPHstart=0.1;
ATPstart= 2;
%%
%% Describe Modules
% This section contains a descriptions of each module. Each module has the
% following fields:
%
% * |varnames| names of variables  in module
% * |init| initial values for each variable
% * |abstol| abstol tolerance values for each variable
% * |function| name of function that propagates this module
% * |inputs| inputs for the module (variables that do not themselves get modified)
%%


%% PSII
sp.varnames.PSII=    { 'PSIIChlEx'  'P680ex'   'P680plus'  'PheAnion'  ...
    'QAox'  'LumenProtons'};
sp.init.PSII        = [  zerolh   zerolh       zerolh      zerolh    ...
    QAoxstart    lumenProtonsStart ]  ;
sp.abstol.PSII     =[   1e-7    1e-7  1e-7    1e-7  1e-2 1e-6 ];
sp.function.PSII=@evolvePSII;
sp.inputs.PSII= {'LightIntensity'  'Zeaxanthin' 'Antheraxanthin' 'PsbSQ' ...
    'quenchmodel'  'LumenMg'         'LumenCl'       'LumenK'};



%% PSII

%25 boxes.
sp.varnames.PSII_Antenna=    { 'RC_a'     'CP47_a'   'CP29_a' 'CP24_a' ...
                               'LHCII_a1' 'LHCII_a2' 'LHCII_a3' 'LHCII_a4' 'LHCII_a5' 'LHCII_a6'  ...
                               'CP26_a'   'CP43_a'    ...
                               'RC_b'     'CP47_b'   'CP29_b' 'CP24_b' ...
                               'LHCII_b1' 'LHCII_b2' 'LHCII_b3' 'LHCII_b4' 'LHCII_b5' 'LHCII_b6'  ...
                               'CP26_b'   'CP43_b' };
                           
sp.init.PSII_Antenna        = [  zerolh *ones(size(sp.varnames.PSII_Antenna)) ]  ;


sp.abstol.PSII_Antenna     =[   1e-9   *ones(size(sp.varnames.PSII_Antenna)) ];
sp.function.PSII_Antenna=@evolvePSII_1;
sp.inputs.PSII_Antenna= {'LightIntensity'  'Zeaxanthin' 'Antheraxanthin' 'PsbSQ' ...
    'quenchmodel'  'LumenMg'         'LumenCl'       'LumenK' 'LumenProtons' 'QAox'};

%% PSII
sp.varnames.PSII_RC=    { 'RC_a' 'RC_b'     'P680plus'  'PheAnion'  ...
                          'QAox'  'LumenProtons'};
sp.init.PSII_RC        = [     zerolh zerolh       zerolh      zerolh    ...
                              QAoxstart    lumenProtonsStart ]  ;
sp.abstol.PSII_RC     = 1e-8 *[   1 1 1 1 1 1 ];
sp.function.PSII_RC   =   @evolvePSII_2;
sp.inputs.PSII_RC     =  { 'LumenMg'         'LumenCl'       'LumenK'};

%% Plastoquinone pool

sp.varnames.PQ    = {'QAox'  'QBneut'  'QBred1' 'QBred2'     ...
                     'PQ'    'PQH2' };
sp.init.PQ        = [QAoxstart    1-3*zeroq     zeroq   zeroq ...
                     params.QuinonePoolSize-1-pqstart  pqstart     ]  ;
sp.abstol.PQ       =[1e-6       1e-6      1e-6    1e-7  ...
                     1e-8       1e-7        ];
sp.function.PQ=@evolvePQ;
sp.inputs.PQ ={'LumenMg'         'LumenCl'       'LumenK' 'LumenProtons'};


%% Cytochrome b6f
sp.varnames.cytb6f={'PQ'      'PQH2'    'PCr'    'LumenProtons'         };
PQstart=params.QuinonePoolSize-1-pqstart ; %this variable is long
sp.init.cytb6f   = [ PQstart  pqstart   PCrstart   lumenProtonsStart     ];
sp.abstol.cytb6f   =[ 1e-8    1e-7     1e-8   1e-6          ];
sp.function.cytb6f = @evolvecytb6f;
sp.inputs.cytb6f ={};

%% PSI

sp.varnames.PSI={   'PCr'   'P700ox' 'P700r'  'Fdxr' 'Fdxox'  'TotalLEF' };
sp.init.PSI=[        PCrstart  zerolh 1-zerolh  zerolh 1-zerolh   zerolh ];
sp.abstol.PSI=[       1e-8  1e-8  1e-8    1e-8 1e-8 1e-5];
sp.function.PSI= @evolvePSI;
sp.inputs.PSI ={'LightIntensity'};


%% ATP Synthase
sp.varnames.ATPsynthase={       'LumenProtons'   'ATP' 'ActiveATPs' };
sp.init.ATPsynthase   = [    lumenProtonsStart         ATPstart  0.05 ];
sp.abstol.ATPsynthase =[                          1e-6     1e-5 1e-6];
sp.function.ATPsynthase=@evolveATPsynthase;
sp.inputs.ATPsynthase ={  'LumenMg'         'LumenCl'       'LumenK' 'Fdxr' };


%%  flux between lumen and stroma
sp.varnames.LumenFlux={ 'LumenMg'            'LumenCl'       'LumenK' };
sp.init.LumenFlux   = [  params.LumenMgStart  params.LumenClStart   params.LumenKStart     ];
sp.abstol.LumenFlux =[   1e-5                 1e-5             1e-5                       ];
sp.function.LumenFlux=@evolveLumen;
sp.inputs.LumenFlux ={    'LumenProtons' };

%% Kea
sp.varnames.KeaFlux={ 'LumenMg'            'LumenCl'       'LumenK' };
sp.init.KeaFlux   = [  params.LumenMgStart  params.LumenClStart   params.LumenKStart     ];
sp.abstol.KeaFlux =[   1e-5                 1e-5             1e-5                       ];
sp.function.KeaFlux=@evolveKea;
sp.inputs.KeaFlux ={    'LumenProtons' };



%% qE
sp.varnames.qE={  'Antheraxanthin' 'Zeaxanthin' 'PsbSQ'};
sp.init.qE         = [      zerolh           zerolh    zerolh]  ;
sp.abstol.qE     =[       1e-8                   1e-8   1e-8];
sp.function.qE=@evolveqE;
sp.inputs.qE={'LumenProtons'};

%% Methyl Viologen-mediate oxidation of Ferredoxin
sp.varnames.MV={ 'Fdxr' 'Fdxox' 'Thrdx'};
sp.init.MV         = [ zerolh 1-zerolh zerolh ]  ;
sp.abstol.MV     =[ 1e-6  1e-8 1e-8 ];
sp.function.MV=@evolveMV;
sp.inputs.MV={};
%%

%% Setup Simulation
sp.quenchmodel=quenchmodel;
sp.simvars=vars;
allvars=[];
allvarsinit=[];
allvarsabstol=[];

for k=1:length(vars)
    if length(sp.varnames.(vars{k}))~=length(sp.init.(vars{k}))
        error([ vars{k} 'initial conditions and variables not equal lengths'])
    end
    if length(sp.varnames.(vars{k}))~=length(sp.abstol.(vars{k}))
        error([ vars{k} 'initial conditions and variables not equal lengths'])
    end
    allvars=[allvars sp.varnames.(vars{k})];
    allvarsinit=[allvarsinit sp.init.(vars{k})];
    allvarsabstol=[allvarsabstol sp.abstol.(vars{k})];
end

%sorts names of variables alphabetically
[sp.varsforsim ind1 ind2]=unique(allvars);
sp.initvarsforsim=allvarsinit(ind1)';
sp.abstolforsim  =allvarsabstol(ind1)'';

%% Identify indices for each module

for k=1:length(vars)
    b=[];
    for j=1:length(sp.varnames.(vars{k}))
        a=strcmp( sp.varsforsim, sp.varnames.(vars{k}){j});
        
        [ f b(j)]=find(a);
    end
    sp.varindices.(vars{k})=getIndices(sp.varsforsim, sp.varnames.(vars{k}));
end



end






