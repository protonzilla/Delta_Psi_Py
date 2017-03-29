function dx=evolveStroma(stromavars, inputs, params)


%sp.varnames.Stroma={ 'StromaProtons' 'NADPH' 'ATP' 'Fdxr' 'Thrdxr' 'ActiveCBEnzymes'};

NADPH          =  stromavars(1,:);
NADP           =  stromavars(2,:);
ATP            =  stromavars(3,:);
Fdxr           =  stromavars(4,:);
Fdxox         =  stromavars(5,:);
Thrdxr         =  stromavars(6,:);
Thrdxox         =  stromavars(7,:);
ActiveCBEnzymes=  stromavars(8,:);
Triose         = stromavars(9,:);

NADP=params.NADPperPSI-NADPH;
ADP=params.ATPperPSI-ATP;


InactiveCBEnzymes=1-ActiveCBEnzymes;
StromaProtons=inputs.LumenProtons/10;
StromaMg=inputs.LumenMg;
CBActiveF=CBActive(StromaProtons, StromaMg);

%rates(1,:)=params.kETFdxNADPH*Fdxr.*NADP./params.NADPperPSI; %electrons from ferredoxin to NADPH

rates(1,:)=params.kETFdxNADPH*Fdxr; %electrons from ferredoxin to NADPH

rates(2,:)=params.kETFdxThrdx*Fdxr.*Thrdxox; %electrons from ferredoxin to thioredoxin
rates(3,:)=params.kThrdxActivate.*InactiveCBEnzymes.*Thrdxr  ;
rates(4,:)=params.kEnzymesOxidize.*ActiveCBEnzymes;
%rates(5,:)=params.CBCyclerate.*CBActiveF...
 %   .*ActiveCBEnzymes.*(ATP./params.ATPperPSI).*(NADPH/params.NADPperPSI);

rates(5,:)=params.CBCyclerate.*CBActiveF...
    .*ActiveCBEnzymes.*(ATP./params.ATPperPSI);
rates(6,:)=params.kThrdxOxidize*Thrdxr;



rates=rates.*(rates>0);%rates should be nonnegative
dNADPH           =0.5*rates(1,:)-params.NADPHperTriose.*rates(5,:);
dNADP            =zeros(size(-dNADPH));
dATP             =-params.ATPperTriose*rates(5,:);
dFdxr           = -rates(1,:)-rates(2,:);
dFdxox          = -dFdxr;
dThrdxr          = rates(2,:)-rates(6,:);
dThrdxox       =-dThrdxr;
dActiveCBEnzymes = rates(3,:) -rates(4,:) ;
dTriose          = rates(5,:);


dx=[ dNADPH; dNADP; dATP; dFdxr; dFdxox; dThrdxr;dThrdxox; dActiveCBEnzymes;dTriose] ;

    function activity= CBActive(StromaProtons, StromaMg)
        activity = ones(size(StromaProtons));
        FracMg=abs(params.StromaMgStart-StromaMg)/params.StromaMgStart;
        pHStroma=params.pHStromaStart+StromaProtons/params.bufferCapacityStroma;
        h=10.^(pHStroma);
        a=10;
        %From Russians:
      %  out.ActiveCC=((a*exp(0.5*(3.16-(10^8)*h))+1)./(exp(0.5*(3.16-(10^8)*h))+1))/a;
       out.ActiveCC=1; 
        %out.ActiveCC=(2-pHEquilibriumProtonate(out.pHStroma, p.pKaCC, p.nCC));
        activity=out.ActiveCC.*FracMg;
        
    end
end