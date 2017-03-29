function out=getTotalProtons(pH, space)
freeProtons=10^-pH;
npts=4000;
testprotons=logspace(-8 , 2, npts);
ntries=2;
for k=1:ntries
fractionFreeProtons=getFractionFreeProtons(testprotons, space);
testpH=-log10(testprotons.*fractionFreeProtons);
[minpH idx]=min(abs(testpH-pH));
testprotons=linspace(testprotons(idx-10), testprotons(idx+10), npts);
end
outpH=-log10(testprotons(idx).*fractionFreeProtons(idx));
out=testprotons(idx);
