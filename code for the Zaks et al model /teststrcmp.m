a.one=1;
a.two=2;
a.three=3;
a.four=5;


b.four=2;
b.one=6;
b.six=0;


f1=fields(a)
f2=fields(b)


for k=1:length(f2)
yesno=strcmp(f2(k), f1)
if ~any(yesno)
    
    error(['field ' f2{k} ' is not an existing parameter value'])
        
end

end