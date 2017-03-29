function sample=sampleSim
%% Sample Code for Running Model
%  Specify Actinic Light Intensity for simulation
act=[    1000  ]';
params=getparamsfromfilename('params.txt');
simnow=1;
%%

%%
% specify which quenching models to be evaluated. The different models are
% specified in the function <getStaticQuencherValues.html |getStaticQuencherValues|> 
%%
qtypes=[ 0 1 2 3 4 ];

if simnow==1
    for k=1:length(qtypes)
        for kk=1:length(act)
            simtype='test'
            tic
            [LightIntensities durat flashidx]=setupPAMIntensities(act(kk));
            sample{kk,k}=chloroplastSim(LightIntensities, durat, params, qtypes(k), simtype);
            sample{kk,k}.simparams.flashidx=flashidx;
            toc
        end
        
    end
end
