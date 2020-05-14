%gera path sem .git
function newlist = gerapath(path)
list    = genpath(path);
folders = strsplit(list, pathsep);
folders(contains(folders, '.git')) = []; %remove git
newlist = sprintf('%s:', folders{:});
end