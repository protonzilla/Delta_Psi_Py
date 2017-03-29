function comparemodeldata(s, sVaryI)
plotdeltaqEs(s.b, 10, 'r')
figure(10)
hold on
plotdeltaqEs(s.d, 10, 'm')
%m=getModeledvalues(sVaryI)
idx=[1 2]
%plot(m.taxis, m.totalquenchers(idx,:))
xlim([0 1000])




    function m=getModeledvalues(sims)
        a=size(sims);
        qindex=1;
        
        taxis=sims{qindex,1}.timevalues
        m.taxis=taxis-600;
        for k=1:a(2);
            [s q{k}]=getStaticVals(sims{qindex, k});
            
            m.totalquenchers(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.QuenchersAnth+q{k}.QuenchersZea,taxis);
            m.psbs(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.ActivePsbS, taxis);
            m.vde(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.ActiveVDE, taxis);
            m.zea(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.Zea, taxis);
            m.anth(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.Anth, taxis);
            m.pH(k,:)=interp1(sims{qindex,k}.timevalues, s.pHLumen, taxis);
            
            m.intensall=unique(sims{qindex,k}.LightIntensity);
            m.intens(k)=m.intensall(3);
        end
    end




    function plotdeltaqEs(f, fnum, plotstyle)
        qEZD=f.params.wt.npq-f.params.npq1.npq;
        qETotal=f.params.wt.npq-f.params.npq4.npq;
        qENPQ4NPQ1=f.params.npq1.npq-f.params.npq4.npq;
        figure(fnum)
        set(gca, 'fontsize', 22);
        xaxis=f.params.wt.pulsetimes;
        xaxis-xaxis(1);
        nidx=19;
        %plot(xaxis-xaxis(1), qEZD, plotstyle);
        hold on
        plot(xaxis-xaxis(1), qETotal, [plotstyle '-']);
        %plot(xaxis-xaxis(1), qENPQ4NPQ1, [plotstyle 'o-']);
        idxoff=20;
        
        %plot NPQ turn-off time
        %plot(xaxis(idxoff:idxoff+9)-xaxis(idxoff), max(qEZD)-qEZD(idxoff:idxoff+9),  'k.-');
        %legend('wt-npq1', 'wt-npq4', 'npq1-npq4')
        plot(f.params.wt.pulsetimes, zeros(size(f.params.wt.pulsetimes)), 'k');
        grid off
        title(f.basefilename)
        
    end
end