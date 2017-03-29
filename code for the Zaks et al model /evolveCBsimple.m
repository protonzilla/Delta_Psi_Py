function dx=evolveCBsimple(cbsimplevars, inputs, params)


%sp.varnames.Stroma={ 'StromaProtons' 'NADPH' 'ATP' 'Fdxr' 'Thrdxr' 'ActiveCBEnzymes'};
ATP            =  cbsimplevars(1,:);
Fdxr           =  cbsimplevars(2,:);
Thrdxr         =  cbsimplevars(3,:);
ActiveCBEnzymes=  cbsimplevars(4,:);

ADP=params.ATPperPSI-ATP;
Fdxox=1-Fdxr;
Thrdxo=1-Thrdxr;
InactiveCBEnzymes=1-ActiveCBEnzymes;


rates(2,:)=params.kETFdxThrdx*Fdxr.*Thrdxo; %electrons from ferredoxin to thioredoxin
rates(3,:)=params.kThrdxActivate.*InactiveCBEnzymes.*Thrdxr  ;
rates(4,:)=params.kEnzymesOxidize.*ActiveCBEnzymes;
rates(5,:)=params.CBCyclerate    .*ActiveCBEnzymes.*(ATP/params.ATPperTriose);

rates(6,:)=params.kThrdxOxidize*Thrdxr;

rates=rates.*(rates>0);%rates should be nonnegative
%dStromaProtons   =-rates(1,:)+2*params.NADPHperTriose.*rates(5,:); %2 protons per NADPH means 1 proton per ferredoxin; 1 proton released into lumen per 2 NADPH molecules used inc arbon metabolism (blankenship . 184)
dATP             =-params.ATPperTriose*rates(5,:);
dFdxr           = -rates(1,:)-rates(2,:);
dThrdxr          = rates(2,:)-rates(6,:);
dActiveCBEnzymes = rates(3,:) -rates(4,:) ;


dx=[  dATP; dFdxr; dThrdxr; dActiveCBEnzymes;] ;

end