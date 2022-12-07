fileID = fopen('input.txt','r');

commands = strings;
global currentpath
currentpath = "";
global files
files = dictionary;

% Read all commands
tline = fgetl(fileID);
while ischar(tline)
    commands(end+1) = tline;
    tline = fgetl(fileID);
end
fclose(fileID);

% Execute all commands
for c = 1 : length(commands)
    command = commands(c);
    if startsWith(command, "$ cd ..")
        cdBack();
    elseif startsWith(command, "$ cd /")
        cdHome();
    elseif startsWith(command, "$ cd ")
        toDirectory = extractAfter(command, 5);
        changeDirectory(toDirectory);
    elseif regexp(command,"[0-9]+")
        parts = regexp(command, " ", "split");
        addFile(parts(2), parts(1))
    end
end

% Calculate sizes of all paths
foldersizes = dictionary("/", 0);
filesizes = values(files);
filenames = keys(files);
for f = 1 : length(filenames)
    size = filesizes(f);
    path = filenames(f);
    
    indvfolders = regexp(path, "/", "split");
    indvfolders = indvfolders(1:end-1);
    folder = "";
    % Add size to current folder and all parent folders
    for d = 1 : length(indvfolders)
        folder = append(folder, "/", indvfolders(d));
        if isKey(foldersizes, folder)
            foldersizes(folder) = foldersizes(folder) + size;
        else
            foldersizes(folder) = size;
        end
    end
end

% Finally, calculate all puzzle solutions
total100k = 0;
totalUsed = foldersizes("/");
smallestDeletion = 70000000;
sizes = values(foldersizes);
for s = 1 : length(sizes)
    if sizes(s) <= 100000
        total100k = total100k + sizes(s);
    end
    if 70000000 - totalUsed + sizes(s) >= 30000000 && sizes(s) < smallestDeletion
        smallestDeletion = sizes(s);
    end
end

% Finally, display the solution
disp("Solution 1: " + total100k);
disp("Solution 2: " + smallestDeletion);

% Adds a file at the current path
function addFile(fileName, fileSize)
    global currentpath;
    global files
    path = append(strjoin(currentpath, '/'), "/", fileName);
    files(path) = str2double(fileSize);
end

% Adds a directory at the current path
function changeDirectory(dirName)
    global currentpath;
    currentpath(end+1)=dirName;
end

% Goes back one level in current path
function cdBack()
    global currentpath;
    currentpath(end)=[];
end

% Goes back to home
function cdHome()
    global currentpath;
    currentpath = "";
end