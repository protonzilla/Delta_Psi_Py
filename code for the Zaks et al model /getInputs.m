function inputs= getInputs(currentValues,thisVarSection,simparams, LightIntensity, quenchmodel)
        
        neededvalues=simparams.inputs.(thisVarSection);
        if length(neededvalues)>0
            for j=1:length(neededvalues)
                if strcmp(neededvalues{j}, 'LightIntensity')
                    inputs.LightIntensity=LightIntensity;
                else if strcmp(neededvalues{j}, 'quenchmodel')
                        inputs.quenchmodel=quenchmodel;
                    else
                        idx=find(strcmp(simparams.varsforsim, simparams.inputs.(thisVarSection){j}));
                        if length(idx)==0
                            error(['did not find inputs for ' simparams.inputs.(thisVarSection){j}])
                        end
                        inputs.(neededvalues{j})=currentValues(idx,:);
                    end
                end
            end
        else inputs={};
        end
end