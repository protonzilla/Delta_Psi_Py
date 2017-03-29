%% calcNPQfromsim
%%
% Calculates NPQ-related values.
%%
function a=calcNPQfromsim(sim)


flashindex=sim.flashidx;
sim.k=getChlorophyllkRates(sim);

%%
% <getChlorophyllkRates.html |getChlorophyllkRates|>
%%
a.fluorescenceyield=sim.k.fluorescenceyield;
if isfield(sim.k, 'fluorescenceyieldRCC')
a.fluorescenceyieldRCC=sim.k.fluorescenceyieldRCC;
else
    a.fluorescenceyieldRCC=1; % fake data
end
%a.fluorescenceyieldnoflashes=a.fluorescenceyield;
%Fmindex=sim.sectionstart(flashindex(1)):sim.sectionstart(flashindex(1)) ...
% +sim.sectionlength(flashindex(1))-1;

npointsInFlash=100;%number of points within a saturating flash that are considered
npointsFlashEnd=00;
if any(flashindex)
    flashidxend=sim.sectionstart(flashindex)+sim.sectionlength(flashindex)-npointsFlashEnd;
    flashidxstart=flashidxend-npointsInFlash;
    flashidxrange=[flashidxstart; flashidxend];


a.pulsetime=(sim.timevalues(flashidxstart));
a.Fmprime=max(a.fluorescenceyield(flashidxrange));
a.Fm=a.Fmprime(1);
a.qEpulse=(a.Fm-a.Fmprime)./a.Fmprime; %qE/NPQ at each pulse.
else
    a.pulsetime=sim.timevalues;
    a.Fmprime=sim.k.fluorescenceyieldRCC;
    a.Fm=max(sim.k.fluorescenceyieldRCC);
    a.qEpulse=(a.Fm-a.Fmprime)./a.Fmprime; %qE/NPQ at each pulse.
end

