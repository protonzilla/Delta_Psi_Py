


act=[       1000  ]';
durat =[600 .5 100  100 .5 100 .5 100 .5 100 .5 100 .5 1  600];
tval=1050;
params=getparamsfromfilename('params.txt');
simnow=1;
satint=15000
qtypes=[   0];
if simnow==1
    for k=1:length(qtypes)
        for kk=1:length(act)
            LightIntensities=[ 0.1 satint   0.1  act(kk) satint act(kk) satint act(kk) satint act(kk) satint act(kk) satint act(kk) 0.1 ];         
            simtype='PSIIAntenna'
            tic 
            svaryI{k,kk}=chloroplastSim(LightIntensities, durat, params, qtypes(k), simtype);
            svaryI{k,kk}.flashidx=zeros(size(LightIntensities));
            toc
        end
        
    end
end
