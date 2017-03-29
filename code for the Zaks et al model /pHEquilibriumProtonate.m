 
    function HA=pHEquilibriumProtonate(pH, pKa, n)
        %pHEquilibrium returns an equilibrium percent concentration of a species that is protonated with association constant Ka and hill coefficient n. This value should alwasy be less than 1.
        Ka   =		10.^(-pKa);
        H=10.^(-pH);
        HA	=  ( H.^n)./(Ka.^n+H.^n);
    end
