


act=[       100  ]';
durat =[600 4 300 4 300 600];
tval=1050;
params=getparamsfromfilename('params.txt');
simnow=1;
qtypes=[   0];
if simnow==1
    for k=1:length(qtypes)
        for kk=1:length(act)
            LightIntensities=[ 0.1   10000 act(kk) 10000 act(kk)   0.1 ];
            simtype='PSIIAntenna'
            tic
            svaryI{k,kk}=chloroplastSim(LightIntensities, durat, params, qtypes(k), simtype);
            svaryI{k,kk}.flashidx=zeros(size(LightIntensities));
            toc
        end
        
    end
end

for k=1:size(svaryI,1)
    for kk=1:size(svaryI,2)
        ss{k,kk} =getssvalsfromsim(svaryI{k,kk},tval)
        ssQA(k,kk)=ss{k,kk}.QAox;
        ssPQH2(k,kk)=ss{k,kk}.PQH2;
        sspH(k,kk)=ss{k,kk}.pHLumen;
        ssQ(k,kk)=ss{k,kk}.QuenchersXanthophyll+ss{k,kk}.QuenchersLutein;
        sspmf(k,kk)=ss{k,kk}.pmf;
        ssLEF(k,kk)=ss{k,kk}.TotalLEF;
        ATPactive(k,kk)=ss{k,kk}.ActiveATPs;
    end
    
end
colors='rgbcmykrgbcmykrgb'

plotnow=0
if plotnow==1
    
    figure(8)
    set(gca, 'Fontsize', 22)
    plot(act, 1-ssQA, 'o')
    title('reduced QA')
    grid off
    
    figure(9)
    set(gca, 'Fontsize', 22)
    plot(act, sspmf, 'o')
    grid off
    
    
    figure(10)
    set(gca, 'Fontsize', 22)
    plot(act, sspH, 'o')
    grid off
    
    figure(11)
    set(gca, 'Fontsize', 22)
    plot(act, ssQ, 'o')
    grid off
    
    figure(12)
    set(gca, 'Fontsize', 22)
    plot(act, ssLEF, 'o')
    grid off
    
    
    
    figure(13)
    set(gca, 'Fontsize', 22)
    plot(act, ATPactive, 'o')
    grid off
end
