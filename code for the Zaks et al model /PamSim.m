%% PamSim
%%

%%
% actinic light input values
%%

act=[    100  500 1000  ]';
%act=500
%%
% Load Parameters
%%
params=getparamsfromfilename('params.txt');
simnow=1;
qtypes=[  0  1   ];
ll=1;
if simnow==1
    for k=1:length(qtypes)
        for kk=1:length(act)
            simtype='test'
            tic
            %%
            % Load light  inputs for PAM experiment using
            % <setupPAMIntensities.html |setupPAMIntensities|>
            %%
            [LightIntensities durat flashidx]=setupPAMIntensities(act(kk));
            
            %%
            % Run Simulation using
            %<chloroplastSim.html |chloroplastSim|>
            %%
            samplepam{kk,k}=chloroplastSim(LightIntensities, durat, params, qtypes(k), simtype);
            samplepam{kk,k}.simparams.flashidx=flashidx;
            toc
            %%
            % Plot results of simulation
            %%
            npq{k,kk}=plotNPQ(samplepam{kk,k}, ll*2, 'k')
            figure(ll)
            title(act(kk))
            ll=ll+1;
        end
        
    end
end
