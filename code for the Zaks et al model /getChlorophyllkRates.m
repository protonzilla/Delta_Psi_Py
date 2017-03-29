%% getChlorophyllkRates
%%
% called from <calcNPQfromsim.html |calcNPQfromsim|>
%%


function k=getChlorophyllkRates(sim)

findex=find(strncmp('PSII', sim.simparams.simvars, 4));
if length(findex)>1
    findex=[find(strncmp('PSII_Antenna', sim.simparams.simvars, 7))];
    
end
if length(findex)>1
    error('more than 1  component  with name PSII')
end

fname=sim.simparams.simvars{findex};
LHvars=sim.simulatedvalues(sim.simparams.varindices.(fname),:);


LHinputs=getInputs( sim.simulatedvalues ,fname,sim.simparams, ...
    sim.LightIntensity,  sim.simparams.quenchmodel);
%%
%<getInputs.html |getInputs|>
%%

%%
%Determine which function determines the rates within PSII. The default is
%to set |func| to be <evolvePSII.html |evolvePSII|>.
%%
func=sim.simparams.function.(fname);


%set QA=1;
LHvarsRCC        = LHvars;
LHvarsRCC(5,:)   = ones(size(LHvars(5,:)));
switch nargout(func)
    case 2
        [foo lhrates]=func(LHvars,LHinputs , sim.params);
        [foo lhratesRCC] = func(LHvarsRCC,LHinputs , sim.params);
        if isfield(lhrates, 'rates')
            k=setrates(lhrates);
            
            
        else if isfield(lhrates, 'Q')
                k.Q=setrates(lhrates.Q);
                k.NQ=setrates(lhrates.NQ);
                
                k.fluorescenceyield=k.Q.fluorescenceyield.*lhrates.Q.Qfrac ...
                    +k.NQ.fluorescenceyield.*(1-lhrates.Q.Qfrac);
                
            else
                error('we the people are confused')
            end
        end
        
    case 1
     
        k=setratesAntenna(LHvars);
end

%Energy transfer to open and closed RCs


%% Set Rates for chlorophyll de-excitation
% This requires looking at rates in <evolvePSII.html |evolvePSII|>
% Use this when the model for chlorophyll fluorescence involves a bulk
% aggregation of Chlorophylls
%%
    function k=setrates(lhrates)
        
        k.kF     = lhrates.rates(3,:);
        k.kPC    = lhrates.rates(7,:);
        k.kPCRCC = lhratesRCC.rates(7,:);
        k.kC     = lhrates.rates(5,:)+k.kF+lhrates.rates(4,:);
        k.kqE    = lhrates.rates(2,:);
        
        
        
        k.allrates    = k.kC+k.kPC+k.kqE;
        k.allratesRCC = k.kC+k.kPCRCC+k.kqE; %Reaction Centers Closed
        
        
        k.fluorescenceyield    = ( k.kF.*ones(size(k.allrates))./k.allrates );
        k.fluorescenceyieldRCC = ( k.kF.*ones(size(k.allratesRCC))./k.allratesRCC );
        
        k.qE        =  k.kqE./k.kC;
        k.phinpq    =  k.kqE./k.allrates;
        k.maxqE     =  max(k.qE) ;
    end


    function k=setratesAntenna(lhinputs)
        
      
        k.kF=sum(sim.params.kF*lhinputs, 1);
        k.ChlEx=sum(lhinputs, 1);
        %         k.kPC=lhrates.rates(7,:);
        %         k.kPCRCC=lhratesRCC.rates(7,:)
        %         k.kC=lhrates.rates(5,:)+k.kF+lhrates.rates(4,:);
        %         k.kqE=lhrates.rates(2,:);
        %
        
        
        %         k.allrates    = k.kC+k.kPC+k.kqE;
        %         k.allratesRCC = k.kC+k.kPCRCC+k.kqE; %Reaction Centers Closed
        %
        shiftidx=0;
        fl_yield_denominator      =[sim.LightIntensity(end)*ones(1,shiftidx) sim.LightIntensity(1:end-shiftidx) ]  *sim.params.crosssection;
        k.fluorescenceyield       = ( k.kF./fl_yield_denominator);
        k.fluorescenceyield       = k.fluorescenceyield.*(k.fluorescenceyield<1);
        k.fluorescenceyieldRCC    = 1;
        
        %         k.fluorescenceyield    = ( k.kF.*ones(size(k.allrates))   ./k.allrates );
        %         k.fluorescenceyieldRCC = ( k.kF.*ones(size(k.allratesRCC))./k.allratesRCC );
        %
        %         k.qE        =  k.kqE./k.kC;
        %         k.phinpq    =  k.kqE./k.allrates;
        %         k.maxqE     =  max(k.qE) ;
    end




end