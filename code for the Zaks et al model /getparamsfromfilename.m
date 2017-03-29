function [params paramUnits]=getparamsfromfilename(paramfilename)
%this function searches for the value in paramfilename that matches the
%variable name paramname
fid=fopen(paramfilename);
scanstring='%s%s%s';
[paramstrings count]=textscan(fid, scanstring,'CommentStyle', '%');
%may want to put in error checking to make sure that the parameters are
%read correctly
for j=1:length(paramstrings{2})
params.(paramstrings{1}{j})=str2num(paramstrings{2}{j,:});
paramUnits.(paramstrings{1}{j})=(paramstrings{3}{j,:});
end
 params.voltsperlog= params.Rconst*params.Tconst/params.Fconst;
 paramUnits.voltsperlog= 'Volts per Log';
fclose(fid);