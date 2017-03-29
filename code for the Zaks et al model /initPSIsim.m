function sp =initPSIsim(mode)
%sp stands for "simulation parameters"
%sp.varnames is a structure with the names of the variables in each modeule
%sp.init is the initial values for a given simulation
%sp.function is a function that evolves PSII
%sp.inputs is a structure of variablees from other modules that are not
%modified by the function

zerolh=1e-8;
zeroq=1e-4;
sp.varnames.PSII=    { 'LHCs'  'P680ex'  'P680broken' 'P680Repaired' 'P680plus'  'PheAnion'     'QAox'  'LumenProtons'};
sp.init.PSII        = [  zerolh   zerolh       zerolh   zerolh         zerolh      zerolh        1    0 ]  ;
sp.function.PSII=@evolvePSII;
sp.inputs.PSII= {'LightIntensity' 'LumenProtons' 'Zeaxanthin' 'Antheraxanthin' 'quenchmodel'};



sp.varnames.PQ    = {'QAox'  'QBneut'  'QBred1' 'QBred2' 'QBempty' 'PQH2' 'PQ'}
sp.init.PQ        = [1         zeroq     zeroq   zeroq    zeroq     zeroq  zeroq ]  ;
sp.function.PQ=@evolvePQ;
sp.inputs.PQ ={};

sp.varnames.cytb6f={'PQH2' 'PQ' 'PCr' 'LumenProtons'  'StromaProtons' };
sp.init.cytb6f   = [zeroq     0    0     0               0];
sp.function.cytb6f = @evolveCytb6f;
sp.inputs.cytb6f ={};


sp.varnames.PSI={ 'PCr' 'P700ex' 'P700r' 'FeS' 'Fdxr'};
sp.init.PSI=[         1    0     0        0     0 ];
sp.function.PSI=@evolvePSI;
sp.inputs.PSI ={'LightIntensity'};



sp.varnames.LumenStromaFlux={ 'StromaProtons' 'LumenProtons' 'StromaMg' 'LumenMg' 'StromaCl' 'LumenCl' 'StromaK' 'LumenK' 'ATP'}; %variables for flux between lumen and stroma
sp.init.LumenStromaFlux   = [0                     0             0        0         0            0          0       0        0];
sp.function.LumenStromaFlux=@evolveLumenStroma;
sp.inputs.LumenStromaFlux ={};


sp.varnames.Stroma={ 'StromaProtons' 'NADPH' 'ATP' 'Fdx' 'Thrdx' 'ActiveCBEnzymes'};
sp.init.Stroma   = [      0            0        0    0     0         0];
sp.function.Stroma=@evolveStroma;
sp.inputs.Stroma ={};


sp.varnames.CEF={'NADPH' 'Fdx' 'PQH2'};
sp.init.CEF   = [0       0       0];
sp.function.CEF=@evolveCEF;
sp.inputs.CEF ={};


sp.varnames.qE={  'Antheraxanthin' 'Zeaxanthin'}
sp.init.qE         = [      zerolh           zerolh   ]  ;
sp.function.qE=@evolveqE;
sp.inputs.qE={'LumenProtons'}
sp.quenchmodel=1;


switch mode
    
    case 'PSI'
        vars={'PSI' }
    case 'LEF'
        vars={'PSII' 'PQ' 'qE' 'cytb6f' 'PSI' 'LumenStromaFlux' 'Stroma'}
    case 'CEF'
        vars={'CEF' 'PQ' 'cytb6f' 'PSI' 'LumenStromaFlux' 'Stroma'}
    case 'LEFCEF'
        vars={'PSII' 'PQ' 'qE' 'CEF' 'cytb6f' 'PSI' 'LumenStromaFlux' 'Stroma'}
    otherwise
        error('mode does not exist');
end
sp.simvars=vars;
allvars=[];
allvarsinit=[];

for k=1:length(vars)
    if length(sp.varnames.(vars{k}))~=length(sp.init.(vars{k}))
        error([ vars{k} 'initial conditions and variables not equal lengths'])
    end
    allvars=[allvars sp.varnames.(vars{k})]
    allvarsinit=[allvarsinit sp.init.(vars{k})]
end

[sp.varsforsim ind1 ind2]=unique(allvars); %sorts names of variables aphabetically
sp.initvarsforsim=allvarsinit(ind1);

for k=1:length(vars)
    b=[];
    for j=1:length(sp.varnames.(vars{k}))     
        a=strcmp( sp.varsforsim, sp.varnames.(vars{k}){j});
        [ f b(j)]=find(a);
    end
    sp.varindices.(vars{k})=b;
end

%check to make sure all variables





