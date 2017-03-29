

%act=[  20 50 70 100 150 250 500 750 1000 1500 2000    ];

act=[100 500 1000]
ll=1;
folder='lumenpH/'
if simnow==1
        for kk=1:length(act)
       comparelumenpH(samplepam, ll, kk)
       figure(ll)
       
       title([num2str(act(kk)) '\mu Mol photons/m^2 s'])
       
       fname=[folder 'LumenpH'  'Act' num2str(act(kk)) ]
       print(['-f' num2str(ll)], '-depsc', fname)
       ll=ll+1
        end
        
end

