function plotqEAll(sims, fnum)
if nargin==1
    fnum=figure
end
a=size(sims);
qindex=2;
taxis=sims{qindex,1}.timevalues
for k=1:a(2);
    [s q{k}]=getStaticVals(sims{qindex, k});
    
    totalquenchers(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.QuenchersAnth+q{k}.QuenchersZea,taxis);
psbs(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.ActivePsbS, taxis);
   vde(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.ActiveVDE, taxis);
   zea(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.Zea, taxis);
   anth(k,:)=interp1(sims{qindex,k}.timevalues, q{k}.Anth, taxis);
   pH(k,:)=interp1(sims{qindex,k}.timevalues, s.pHLumen, taxis);
    
    intensall=unique(sims{qindex,k}.LightIntensity);
    intens(k)=intensall(3);
end
taxistoplot=taxis-600
xlims=[00 1500];
figure(fnum)
set(gca, 'fontsize',22)
plot(taxistoplot, totalquenchers)
grid off
legend(num2str(intens'))
title('total quenchers')
xlim(xlims)

figure(fnum+1)
set(gca, 'fontsize',22)
plot(taxistoplot, psbs)
grid off
legend(num2str(intens'))
title('active PsbS')
xlim(xlims)

figure(fnum+2)
set(gca, 'fontsize',22)
plot(taxistoplot, zea+anth)
grid off
legend(num2str(intens'))
title('zea +anth')
xlim(xlims)


figure(fnum+3)
set(gca, 'fontsize',22)
plot(taxistoplot, pH)
grid off
legend(num2str(intens'))
title('pH')
xlim(xlims)