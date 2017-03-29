function dx=evolveCEF(CEFvars, inputs, params)



NADPH          =  CEFvars(1,:);
Fdxr           =  CEFvars(2,:);
PQH2           =  CEFvars(3,:);


NADP=params.NADPperPSI-NADPH;
Fdxo=1-Fdxr;
PQ=params.QuinonePoolSize-PQH2;



fracATP=inputs.ATP/params.ATPperPSI;
fracNADPH=NADPH/params.NADPperPSI;
CEFenhancement=((fracNADPH.^2./fracATP.^3)).^5;

rates(1,:)=params.kETFdxPQ*Fdxr.*0.5.*PQ; %electrons from ferredoxin to plastoquinone (pgr5 pathway)
rates(2,:)=params.kETNADPHPQ.*CEFenhancement.*NADPH.*PQ; %electrons from NADPH to plastoquinone   (crr pathway)


dNADPH         =-rates(2,:);
dFdxr          =-rates(1,:);
dPQH2          = 0.5*rates(1,:); %2 electrons per PQ molecule


dx=[ dNADPH ; dFdxr; dPQH2] ;

end