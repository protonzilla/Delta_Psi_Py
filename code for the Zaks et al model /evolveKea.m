%% evolveLumen
% Calculate diffusion of ions in and out of lumen in response to chemical
% potential gradient. Assume stromal concentration of ions is constant.
%%

function out=evolveLumen( lumenvars,inputs,params)

%sp.varnames.LumenStromaFlux={ 'StromaProtons' 'LumenProtons' 'StromaMg' 'LumenMg' 'StromaCl' 'LumenCl' 'StromaK' 'LumenK' 'ATP'}; %variables for flux between lumen and stroma

%% Load Variables

LumenMg        = lumenvars(1,:);
LumenCl        = lumenvars(2,:);
LumenK         = lumenvars(3,:);


%% Calculate Static Variables
lumen.Protons=inputs.LumenProtons;
lumen.Mg = LumenMg;
lumen.Cl=LumenCl;
lumen.K=LumenK;
stroma.Protons=params.StromaProtonsStart;
stroma.Cl=params.StromaClStart;
stroma.Mg=params.StromaMgStart;
stroma.K=params.StromaKStart;



s=getStaticThylakoidValues(lumen, stroma, params);

%% Calculate Rates

rates(1,:)=getflux(LumenMg,  params.StromaMgStart,  s.deltamuMg,s.deltapsi,  params.PMg, params.zMg);
rates(2,:)=getflux(LumenCl,  params.StromaClStart,  s.deltamuCl,s.deltapsi,  params.PCl, params.zCl);
rates(3,:)=getflux(LumenK,   params.StromaKStart,   s.deltamuK, s.deltapsi,  params.PCl, params.zK);


%% Calculate Differential Equatiosn
dLumenMg        =  fluxToConcentration(rates(1,:), 'lumen', params);
dLumenCl        =  fluxToConcentration(rates(2,:), 'lumen', params);
dLumenK         =  fluxToConcentration(rates(3,:), 'lumen', params);

out=[  dLumenMg;dLumenCl; dLumenK];

%% Model For ion Flux
% 
%%

    function FluxLumen=getflux(LumenConc, StromaConc, deltamu,deltapsi, permeability, z)
        
        %provided units: Molar, Molar, Volts, cm/z, none
        %units:    flux out: moles ions/cm^2=moles ion/liter * cm/second *
        %Volts/volts
        %I liter=1000cm^3 so if LumenConc is in
        %moles/liter*1liter/1000cm^3=1e-3moles/cm^3
        flowout=[deltamu]>[0 ];
        %flowout=flows(1)*flows(2); %deltamu and z have the same sign;
        literspercc=1e-3;
        FluxOut=  LumenConc .* literspercc .* permeability    .*          deltamu /params.voltsperlog;
        FluxIn  =  StromaConc .*  literspercc .* permeability  .*        deltamu/params.voltsperlog;
        %
        fluxtype='lin';
        switch fluxtype
            case 'gh'
%                Goldman-Hodgkin-Katz equation
                f=exp(z*deltapsi/params.voltsperlog)
                if (f-1)<1e-10*ones(size(f))
                    FluxLumen=0;
                else
                    
                    FluxLumen=z/params.voltsperlog * permeability *deltapsi.* (StromaConc-LumenConc.*f)./(1-f);
                end
            case 'lin'
                FluxLumen=-(LumenConc.*flowout +StromaConc.*(1-flowout))  .*literspercc.*permeability .* deltamu./params.voltsperlog;
                
        end
    end
end





