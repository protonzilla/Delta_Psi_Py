
act=[ 10 60 100 160 250 300 500 750 1000 1500 2000]'
durat =[600  300   30];
tval=790;
params=getparamsfromfilename('params.txt');
simnow=0;
qtypes=[ 0 1  ];
if simnow==1
    for k=1:length(qtypes)
        for kk=1:length(act)
            LightIntensities=[ 0.001   act(kk)   0.001 ];
            
            simtype='LEF'
            tic
            simQ{k,kk}=chloroplastSim(LightIntensities, durat, params, qtypes(k), simtype);
            toc
        end
        
    end
end

for k=1:size(simQ,1)
    for kk=1:size(simQ,2)
        ss{k,kk} =getssvalsfromsim(simQ{k,kk},tval)
        ssQA(k,kk)=ss{k,kk}.QAox;
    end
    
end
colors='rgbcmykrgbcmykrgb'
for j=1:3;%length(act)
    plotNPQ(simQ{1,j}, 9, colors(j))
    figure(9)
    hold on
    grid off
end

figure(8)
set(gca, 'Fontsize', 22)
grid off
plot(act, 1-ssQA, 'o')

