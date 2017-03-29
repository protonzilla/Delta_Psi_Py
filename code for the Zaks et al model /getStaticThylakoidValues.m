%% getStaticThylakoidValues
%%
function [out]=getStaticThylakoidValues(lumen,stroma,p)

out.pHLumen  =   getpH(lumen.Protons, p, 'Lumen');
if isinf(out.pHLumen)
    error('PH Lumen')
end
out.pHStroma =   getpH(stroma.Protons, p, 'Stroma'); %stroma.Protons should be negative because protons are taken out of stroma


out.FractionActiveCytochrome=1-pHEquilibriumProtonate(out.pHLumen, p.pKaC, p.nC);

%outgoing protons
%calculate parameters for pmf:

lumenAddedProtons=lumen.Protons;
stromaAddedProtons=stroma.Protons;

%% Calculate Charge
out.lumenCharge=(lumenAddedProtons+p.zCl*lumen.Cl+p.zK*lumen.K+p.zMg*lumen.Mg);
out.stromaCharge=(stromaAddedProtons+p.zCl*stroma.Cl+p.zK*stroma.K+p.zMg*stroma.Mg);
out.TotalChargeDifference=p.Fconst*p.lumenVolumePerArea*(out.lumenCharge-out.stromaCharge); %units in Coulombs per thylakoid area

%F is coulombs per mol of electrons


%% Calculate $\Delta \Psi, \Delta$ pH and _pmf_
%%
% 
out.deltapsi=out.TotalChargeDifference/p.MembraneCapacitance; %charge per area /Capacitance per area
out.deltapH=out.pHStroma-out.pHLumen;

%the log(10) is  approximately 2.3 and is necessary for converting pH,
%which in base10, to a voltage, which is determined by ratios of natural
%logs

out.pmf=out.deltapsi+log(10)*p.voltsperlog*out.deltapH;

%% Error Management

if sum(imag(out.pmf)./real(out.pmf))>1e-5
    disp('pmf is imaginary')
end
if real(out.pmf)>0.5
 %   disp('pmf is biger than 0.5 V')
end

%chemical potentials for ions: These values are unitless and become
%imaginary


%%%%%%%%%%%%%%%%%Delta mu has units of volts
%ions want to go towards lower chemical potential
out.deltamuCl     =    getdeltamu(out.deltapsi, p.zCl, lumen.Cl,    stroma.Cl) ;
out.deltamuMg     =    getdeltamu(out.deltapsi, p.zMg, lumen.Mg, stroma.Mg) ;
out.deltamuK      =    getdeltamu(out.deltapsi, p.zK, lumen.K,   stroma.K) ;


%% Calculate $\Delta \mu$
    function deltamu=getdeltamu(deltapsi, z,LumenConc, StromaConc)
        diffusionpotential=p.voltsperlog*  log(LumenConc/StromaConc);
        deltamu    = (  z *deltapsi     +   diffusionpotential ) ; %delta mu is in volts.
        if ~isfinite(deltamu) %potential shouldn't exceed 1 volt in physical system.
            %error('delta mu is not finite ')
        end
        
        if abs(deltamu)>=20 %potential shouldn't exceed 1 volt in physical system.
            %  error('deltamu is over 20 volt ')
        end
        if imag(deltamu)>=1e-13 %this will only happen if an ion concentration becomes negative, which is unphysical.
            %            error('deltamu is  complex ')
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end