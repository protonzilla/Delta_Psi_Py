%% evolveVars
%%
% evolves all the variables in the fields of input struct |x|.
% Gets called from <runChloroplastSim.html |runChloroplastSim|>
%%

function dx=evolveVars (currentValues, x, params,simparams, ...
    LightIntensity, quenchmodel )

%% Identify modules
% models are in fields of input struct x
%%
varsInSimulation=fields(x);
for k=1:length(varsInSimulation)
    %use function specified to propagate module j that is specified in
    %initialization file
    
    %%
    % Get inputs for function |simparams.function.(varsInSimulation{k})|
    % using function <getInputs.html |getInputs|>
    %%
    inputs.(varsInSimulation{k})=getInputs(currentValues,...
        varsInSimulation{k}, simparams, LightIntensity, quenchmodel);

        %%
    % Evaluate differential equation for module k using function contained
    % in the handle |simparams.function.(varsInSimulation{k})|
    %%
    dx.(varsInSimulation{k})=...
        simparams.function.(varsInSimulation{k})(x.(varsInSimulation{k}),...
        inputs.(varsInSimulation{k}), params);
end


  
end

%%
% currently, the possible modules are  
%
% * Photosystem II <evolvePSII.html>
% * qE <evolveqE.html>
% * Plastoquinone Pool <evolvePQ.html>
% * cytochrome b6f <evolvecytb6f.html>
% * Photosystem I <evolvePSI.html>
% * Lumen and Stroma Flux <evolveLumenStroma.html>
% * ATP Synthase <evolveATPSynthase.html>
% * Reduction of Ferredoxin in Stroma <evolveMV.html>

% 
%%  
