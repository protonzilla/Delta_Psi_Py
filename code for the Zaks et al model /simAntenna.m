%% simAntenna
%%

%%
% actinic light input values
%%

act=[    0  ]';
%act=500
%%
% Load Parameters
%%
params=getparamsfromfilename('params.txt');
simnow=1;
qtypes=[  0     ];
ll=1;
if simnow==1
    for k=1:length(qtypes)
        for kk=1:length(act)
            simtype='PSIIAntenna';
            tic
            %%
            LightIntensities =[1 1500  1 ];
            durat           = [10 30  10];
            flashidx        =[ 0 0 0];
            
            %%
            % Run Simulation using
            %<chloroplastSim.html |chloroplastSim|>
            %%
            sampleantenna{kk,k}=chloroplastSim(LightIntensities, durat, params, qtypes(k), simtype);
            sampleantenna{kk,k}.simparams.flashidx=flashidx;
            toc
            %%
            % Plot results of simulation
            %%
            npq{k,kk}=plotNPQ(sampleantenna{kk,k}, ll*2, 'k')
            figure(ll)
            title(act(kk))
            ll=ll+1;
        end
        
    end
end
