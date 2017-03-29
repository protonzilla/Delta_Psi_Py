function ssvars=getssvalsfromsim(simvarylight, tval)

if (size(simvarylight,1)==1)&&(length(size(simvarylight))==2)
    simvarylight=simvarylight';
end

[ b ll J ]=unique(simvarylight.timevalues);

tval=min(tval, max(b));
tindex     =      interp1(b, ll,tval, 'linear');

tindices=[floor(tindex) ceil(tindex)];
eqvals.tindex=tindex;
if (tindices(1)==tindices(2))
    weights=[1 0];
else
weights=[tindex-tindices(1) tindices(2)-tindex];
end




ssvarsVec=simvarylight.simulatedvalues(:,tindices(1))*weights(1)+simvarylight.simulatedvalues(:,tindices(2))*weights(2);
for k=1:length(simvarylight.simparams.varsforsim)
    ssvars.(simvarylight.simparams.varsforsim{k})=ssvarsVec(k);
end


%get static values
[s q] = getStaticVals(simvarylight);
sfields=fields(s);
qfields=fields(q);
for k=1:length(sfields)
    if ~(any(strfind( sfields{k},'stroma'))||any(strfind( sfields{k},'Stroma')))
        ssvars.(sfields{k})=mean(s.(sfields{k})(tindices));
    end
end
for k=1:length(qfields)
    ssvars.(qfields{k})=mean(q.(qfields{k})(tindices));
end


end