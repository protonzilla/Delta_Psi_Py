function comparelumenpH(svaryI, fnum, kk)
[s1 q1]=getStaticVals(svaryI{1,kk});
%[s2 q2]=getStaticVals(svaryI{2,kk});
figure(fnum)
set(gca, 'fontsize', 22)
hold on
plot(svaryI{1,kk}.timevalues/60,s1.pHLumen, svaryI{2,kk}.timevalues/60,s2.pHLumen) 
grid off
ylim([4.5 7.5])