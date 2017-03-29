
clear npq
clear npq1 npq2 npq3 npq4 deltaPAM npqtime
for k=1:size(samplepam, 1)
    for kk=1:size(samplepam,2)
        npq{k,kk}=calcNPQfromsim(samplepam{k,kk})
    end
    
end

for k=1:1;%size(npq,2)
    
%    deltaPAM(:,k)=npq{2,k}.qEpulse-npq{1,k}.qEpulse;
    npqtime=npq{1,1}.pulsetime;
    npq1(:,k)=npq{1,k}.qEpulse;
    npq2(:,k)=npq{2,k}.qEpulse;
     npq3(:,k)=npq{3,k}.qEpulse;
%          npq4(:,k)=npq{4,k}.qEpulse;
    
end
figure(24)
set(gca, 'fontsize', 22)
plot(npqtime, npq1,'o-',npqtime, npq2, '.-', npqtime, npq3, 'o-')%, npqtime, npq4, 'o-') 
hold on
%plot(npqtime, npq2, '.-', npqtime, npq3, '.-', npqtime, npq4, '.-')
hold on
grid off
