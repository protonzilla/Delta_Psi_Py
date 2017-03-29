function pH=getpHFromProtonate(ProtonatedFraction, pKa, n)
Ka=10.^(-pKa);
H=((ProtonatedFraction*Ka^n)./(1-ProtonatedFraction)).^(1/n);
pH=-log10(H);