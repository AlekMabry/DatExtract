clear all
close all
clc

allFilenames = dir('*.dat');

% Identify key strings to search for
sig1 = "E11";
sig2 = "EP1";
sig3 = " MAXIMUM";
sig4 = "RF1";
sig5 = "   Abaqus 3DEXPERIENCE R2018x";
sig6 = "          THE ANALYSIS HAS BEEN COMPLETED";

for i = 2
    
    filename = allFilenames(i).name; % Set file to read

    step = 1;
    isReading = true;
    line = 0;
    
    fprintf("Reading file %s.\n",filename);
    fid = fopen(filename,'rt');
    
    readDat = false;
    
    while isReading == true %while structure and 3 are dummy parameters to produce enough output files to see if its working without going all the way
        
        datLine = convertCharsToStrings(fgetl(fid)); %adds next line of text from .dat to my_text
        
        while readDat == true
            datLine = convertCharsToStrings(fgetl(fid));
            if contains(datLine,sig3) && param == 1
                readDat = false;
                fclose(txtE);
            elseif contains(datLine,sig3) && param == 2
                readDat = false;
                fclose(txtEP);
            elseif contains(datLine,sig5) || contains(datLine,sig6)
                readDat = false;
                fclose(txtRF);
                step = step+1;
            elseif param == 1 
                fprintf(txtE, datLine + newline);
            elseif param == 2
                fprintf(txtEP, datLine + newline);
            elseif param == 3
                fprintf(txtRF, datLine + newline);
            elseif datLine == -1
                readDat = false;
                isReading = false;
            end
        end
    
        if contains(datLine,sig1)
            readDat = true;
            fprintf("Reading Strain Data")
            param = 1;
            txtE = fopen('c02LE.dat','w');
            datLine = convertCharsToStrings(fgetl(fid)); % Burns through the next two lines which contain no data
        elseif contains(datLine,sig2)
            readDat = true;
            fprintf("Reading Principal Strain Data")
            param = 2;
            txtEP = fopen('c02LEP.dat','w');
            datLine = convertCharsToStrings(fgetl(fid)); % Burns through the next two lines which contain no data     
        elseif contains(datLine,sig4)
            readDat = true;
            fprintf("Reading Reaction Force Data")
            param = 3;
            txtRF = fopen('c02LRF.dat','w');
            datLine = convertCharsToStrings(fgetl(fid));
            datLine = convertCharsToStrings(fgetl(fid));
            datLine = convertCharsToStrings(fgetl(fid));
            datLine = convertCharsToStrings(fgetl(fid)); % Burns through the next two lines which contain no data
        elseif str2double(datLine) == -1
            isReading = false;
        end
    end
    
    fclose(fid);
    
end
