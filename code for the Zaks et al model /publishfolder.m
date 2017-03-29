a=dir;

for k=1:length(a)
    ismfile=regexp(a(k).name, '\<.*(\.m)\>')
    disp(a(k).name)
    if ismfile
        publish(a(k).name, struct('format', 'html', 'evalCode', false));


    end
end