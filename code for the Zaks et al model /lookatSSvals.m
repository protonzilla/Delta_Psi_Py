function lookatSSvals(svaryI)

tval=700;

colors='rgbcmykrgbcmykrgb';

plotss('ActiveVDE', 10)
plotss('ActivePsbS', 11)
plotss('pHLumen', 12)
plotss('Zeaxanthin', 13)
plotss('P680ex', 14)
plotss('QAox', 15)
plotss('QBneut', 16)
plotss('QBred1', 17)

plotss('PQ', 18)
plotss('PQH2', 19)



    function plotss(ssfield, fnum)
        
        for k=1:size(svaryI,1)
            for kk=1:size(svaryI,2)
                ss =getssvalsfromsim(svaryI{k,kk},tval);
                ssfieldtoplot(k,kk)=ss.(ssfield);
                intens=unique(svaryI{k,kk}.LightIntensity)
                act(k)=intens(3);
                
            end
            
        end
        
        figure(fnum)
        set(gca, 'fontsize', 22)
        plot(act, ssfieldtoplot, 'o-')
        grid off
        xlabel('Light Intensity ( \mu Mol photon/m^2 s)')
        title(ssfield)
        
        
        folder='ssvals/'
        print(['-f' num2str(fnum)], '-depsc', [folder 'ss'  ssfield 'T' num2str(tval-600)])
        
    end
end