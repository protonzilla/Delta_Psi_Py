%% setupPAMIntensities
% This function |setupPAMIntensities| sets up a series of light intensities
% and durations to simulate the PAM fluorescence experiment. The output
% variabls are
% * |LightIntensities| specifies the light intensity inputs
% * |durat| specifiees the duration of each light intensity
% * |flashidx| specifies whether a given segment is a saturating flash
%%

function [LightIntensities durat flashidx]=setupPAMIntensities(act, Isat, flashlength)

Imeasure=.001;
if nargin<2
    
    Isat=7000;
end
if nargin<3
    
   flashlength=0.5;
end


%% Set up durations of light pulses
PAMintens=[act  Isat act ];
PAMdurat28=[28  flashlength 2-flashlength]; %30 seconds
PAMdurat58=[58  flashlength 2-flashlength]; % one minute
PAMdurat15=[13.0  flashlength 2-flashlength]; % 15 seconds
PAMdurat7=[7.0  flashlength 2-flashlength];  % 7 seconds
offintens=[Imeasure Isat Imeasure];  %intensities
offintensnosat=[Imeasure Isat Imeasure]; % I think this variable is redundant.
%%
%
%%
fidx=[0 1 0];
simtype=1

%% Set Up Simulation
switch simtype
    case 1
        LightIntensities=[offintens Imeasure Isat    ...
            catPam(PAMintens,23)  catPam(offintensnosat,15) ];
        durat =          [PAMdurat58   60    flashlength  catPam(PAMdurat7, 2) ...
            catPam(PAMdurat15, 10) catPam(PAMdurat28, 4)  catPam(PAMdurat58, 7) ...
            catPam(PAMdurat7, 2) catPam(PAMdurat28, 3) catPam(PAMdurat58, 10) ];
        
        flashyesno  =      [fidx      0      1  catPam(fidx, 30)];
    case 2
        error('this case doesnt work right now')
        
        LightIntensities=[offintens Imeasure Isat    ...
            catPam(PAMintens,13)  catPam(offintensnosat,10) ];
        
        durat =          [PAMdurat58   60    flashlength  catPam(PAMdurat7, 2) ...
            catPam(PAMdurat15, 2) catPam(PAMdurat28, 4)  catPam(PAMdurat58, 3) ...
            catPam(PAMdurat7, 2) catPam(PAMdurat28, 3) catPam(PAMdurat58, 5) ];
        
        flashyesno  =      [fidx      0      1  catPam(fidx, 23)];
end
%%
% flashidx is a vector specifying whether a given segment is a flash or
% not. It is important later, in functions such as <calcNPQfromsim.html
% |calcNPQfromsim|> to specify which segments correspond to saturating
% flahes as in PAM experiments
%%
flashidx=find(flashyesno);

end
%% Concatenate vector
function out= catPam(vin, nreps)
out=[];
for k=1:nreps
    out= [out vin];
end
end

