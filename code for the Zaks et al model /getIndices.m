function idxs=getIndices(allstrings, stringsToIndex)
idxs=[];


if ~iscell(stringsToIndex)
    stringsToIndex={stringsToIndex};
end
for j=1:length(stringsToIndex)
    a=strcmp( allstrings, stringsToIndex{j});
    [ f idxs(j)]=find(a);
end

end