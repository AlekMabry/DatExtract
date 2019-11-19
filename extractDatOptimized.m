clear all
close all
clc

% Identify key strings to search for
sig_e = "E11";
sig_pe = "EP1";
sig_rf = "RF1";

% Output directory
outputDir = '/results/';

allFilenames = dir('*.dat');
for i = 2
    
    filename = allFilenames(i).name; % Set file to read
    [filePath,name,ext] = fileparts(allFilenames(i).name);
    outputFile = [pwd,outputDir,name,'.mat'];
    
    fprintf("Reading file %s.\n",filename);
    fid = fopen(filename,'r');
    if fid == -1
        error('Author:Function:OpenFile', 'Cannot open file!');
    end
    
    % 0: Not Recording, 1: Recording E, 2: Recording EP, 3: Recording RF
    state = 0;
    while ~feof(fid)
        tline = fgetl(fid);
        line = convertCharsToStrings(tline);
        
        if state == 0
            % If currently not recording and a signature line is found,
            % create a very large matrix, jump to the line with the first
            % values, and update the state to start recording into the array
            if contains(line,sig_e)
                columns = 1;
                E = zeros(1000000, 6);
                state = 1;  % Start Recording Strain
                fgetl(fid); % Burn empty lines
                fgetl(fid);
            elseif contains(line,sig_pe)
                columns = 1;
                EP = zeros(1000000, 3);
                state = 2;  % Start Recording Principal Strain
                fgetl(fid) % Burn empty lines
                fgetl(fid);
            elseif contains(line,sig_rf)
                columns = 1;
                RF = zeros(1000000, 3);
                state = 3;  % Start Recording Reaction Force
                for a = 1:12
                    fgetl(fid) % Burn empty lines
                end
            end
        else
            % If the state is not zero, then check if the current line
            % is empty (to save the matrix), or save the current line
            % into the matrix
            if isempty(tline)
                % Clip and save the matrix
                switch(state)
                    case 1
                        E = E(1:columns-1, :);
                        state = 0;
                        save(outputFile, 'E');
                        clear E;
                    case 2
                        EP = EP(1:columns-1, :);
                        state = 0;
                        save(outputFile, 'EP', '-append');
                        clear EP;
                    case 3
                        RF = RF(1:columns-1, :);
                        state = 0;
                        save(outputFile, 'RF', '-append');
                        clear RF;
                end
            else
                % Save the line into the matrix
                switch(state)
                    case 1
                        temp = cell2mat(textscan(line,'%f'));
                        E(columns, :) = temp(2:7); 
                    case 2
                        temp = cell2mat(textscan(line,'%f'));
                        EP(columns, :) = temp(2:4);
                    case 3
                        temp = cell2mat(textscan(line,'%f'));
                        RF(columns, :) = temp(2:4);
                end
                columns = columns + 1;
            end
        end
            
    end
  
    fclose(fid);
    
end
