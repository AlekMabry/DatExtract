clear all
close all
clc

% Identify key strings to search for
sig_e = "E11";
sig_pe = "EP1";
sig_rf = "RF1";

allFilenames = dir('*.dat');
for i = 1
    
    filename = allFilenames(i).name; % Set file to read
    
    fprintf("Reading file %s.\n",filename);
    fid = fopen(filename,'rt');
    if fid == -1
        error('Author:Function:OpenFile', 'Cannot open file!');
    end
   
    fid = fopen('YourFile.txt','rt');
    
    % 0: Not Recording, 1: Recording E, 2: Recording EP, 3: Recording RF
    state = 0;
    while ~feof(fid)
        tline = fgetl(fid);
        line = convertCharsToStrings(tline);
        
        if state == 0
            % If currently not recording and a signature line is found,
            % create a very large matrix, jump to the line with the first
            % values, and update the state to start recording into the array
            if contains(datLine,sig_e)
                columns = 0;
                data_e = zeros(1000, 6);
                state = 1;  % Start Recording Strain
            end
            if contains(datLine,sig_pe)
                columns = 0;
                data_ep = zeros(1000, 6);
                state = 2;  % Start Recording Principal Strain
            end
            if contains(datLine,sig_rf)
                columns = 0;
                data_rf = zeros(1000, 6);
                state = 3;  % Start Recording Reaction Force
            end
        else
            % If the state is not zero, then check if the current line
            % is empty (to save the matrix), or save the current line
            % into the matrix
            if isempty(tline)
                % Clip and save the matrix
                switch(state)
                    case 1
                        data_e = data_e(1:columns, :);
                    case 2
                        data_ep = data_ep(1:columns, :);
                    case 3
                        data_rf = data_rf(1:columns, :);
                        save('test.mat');
                end
            else
                % Save the line into the matrix
                switch(state)
                    case 1
                        data_e(columns, :);
                    case 2
                        data_ep = data_ep(1:columns, :);
                    case 3
                        data_rf = data_rf(1:columns, :);
                        save('test.mat');
                end
                columns = columns + 1;
            end
        end
            
    end
  
    fclose(fid);
    
end
