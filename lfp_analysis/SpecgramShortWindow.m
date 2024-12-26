%% SpecgramFolderLoop for Spectrograms with window size 1 sec, 0.2 sec step and 0 to 12 Hz
% Change parentFolder in order to match the path where I have folders
% R01,R02,R03,etc.
% This script enters in each folder, then in each R00D00 subfolder,
% calculates the spectrogram and saves a "R00D00_specgram.mat" file in each
% subfolder

clc;
clear all;

% Define the parent folder containing the 'Rxx' folders
parentFolder = 'D:\Doctorado\Backup Ordenado';

% List all 'Rxx' folders in the parent folder
R_folders = dir(fullfile(parentFolder, 'R*'));

% Iterate through each 'Rxx' folder
for r = 1:length(R_folders)
    current_R_folder = fullfile(parentFolder, R_folders(r).name);
    disp(['Processing folder: ' current_R_folder]);
    
    % List all subfolders inside the 'Rxx' folder
    D_folders = dir(fullfile(current_R_folder, 'R*D*'));
    D_folders = D_folders([D_folders.isdir]);
    
    % Iterate through each 'RxDy' folder
    for d = 1:length(D_folders)

        current_D_folder = fullfile(current_R_folder, D_folders(d).name);
        disp(['Processing subfolder: ' current_D_folder]);
        
        % Change the current folder to the 'RxDy' subfolder
        cd(current_D_folder);
        [~,D,X] = fileparts(current_D_folder); name = D([1:6]);
        
        % Check if the .dat file exists
        file_path = strcat(name, '_lfp.dat');
        
        % Check if the sessioninfo.mat file exists
        sessioninfo_path = strcat(name, '_sessioninfo.mat');
        
        if exist(file_path, 'file') && exist(sessioninfo_path, 'file') == 2
            % The file exists, do something
            disp(['  File ' file_path ' exists. Performing action...']);
            load(strcat(name,'_sessioninfo.mat'), 'ch_total'); % N�mero de canales totales                        
         
            % BLA
            % Load data and do analysis on data
            load(strcat(name,'_sessioninfo.mat'), 'BLA_mainchannel'); ch = BLA_mainchannel; clear BLA_mainchannel; % Canal a levantar
            if ~isempty(ch)
                % BLA low-freq specgram
                % Cargamos un canal LFP del amplificador
                disp(['    Uploading BLA amplifier data...']);
                [amplifier_lfp] = LoadBinary(strcat(name,'_lfp.dat'), ch, ch_total);
                amplifier_lfp = amplifier_lfp * 0.195; % Convertir un canal de registro de bits a microvolts (uV).
                % Filtramos la se�al
                disp(['    Filtering BLA LFP signal...']);
                highpass = 0.1; lowpass = 300; % Frecuencias de corte del filtro. Corte pasabajos en nyquist frequency.
                data = amplifier_lfp; % Se�al que queremos filtrar
                samplePeriod = 1/1250; % Frecuencia de muestreo de la se�al subsampleada
                % Aplicamos un filtro pasa altos con corte en 0.1 Hz
                filtHPF = (2*highpass)/(1/samplePeriod);
                [b, a] = butter(4, filtHPF, 'high');
                data_hp = filtfilt(b, a, data);
                % Aplicamos un filtro pasa bajos con corte en 300 Hz
                filtLPF = (2*lowpass)/(1/samplePeriod);
                [b, a] = butter(4, filtLPF, 'low');
                data_hlp = filtfilt(b, a, data_hp); %se�al de mag de acel filtrada
                amplifier_lfp = data_hlp; % Guardamos la se�al filtrada como "amplifier_BLA_downsample_filt"
                clear data_hlp a b data filtHPF data_hp filtLPF highpass lowpass samplePeriod;% Borramos las variables que no me sirven m�s
                % Par�metros �ptimos para analizar frecuencias de 0 a 30 Hz.
                % Igualmente calculo hasta 150 para tener el espectro completo
                params.Fs = 1250; 
                params.err = [2 0.05]; 
                params.tapers = [3 5]; 
                params.pad = 2; 
                params.fpass = [0 12];
                movingwin = [1 0.2];
                disp(['    Analizing BLA low frequency multi-taper spectrogram...']);
                [S,t,f,Serr] = mtspecgramc(amplifier_lfp, movingwin, params);
                % Save the results to a .mat file
                % Guardamos solo las variables f,S,Serr,t
                filename = strcat(name,'_specgram_BLA_ShortWindow.mat');
                disp(['    Saving ' filename ' file into the Current Folder']);
                save(filename, 'f', 'S', 'Serr', 't','params','movingwin','-v7.3');
                disp(['    Done.']);
            end
            
            % PL
            % Load data and do analysis on data
            load(strcat(name,'_sessioninfo.mat'), 'PL_mainchannel'); ch = PL_mainchannel; clear PL_mainchannel; % Canal a levantar
            if ~isempty(ch)
                % PL low-freq specgram
                % Cargamos un canal LFP del amplificador
                disp(['    Uploading PL amplifier data...']);
                [amplifier_lfp] = LoadBinary(strcat(name,'_lfp.dat'), ch, ch_total);
                amplifier_lfp = amplifier_lfp * 0.195; % Convertir un canal de registro de bits a microvolts (uV).
                % Filtramos la se�al
                disp(['    Filtering PL LFP signal...']);
                highpass = 0.1; lowpass = 300; % Frecuencias de corte del filtro. Corte pasabajos en nyquist frequency.
                data = amplifier_lfp; % Se�al que queremos filtrar
                samplePeriod = 1/1250; % Frecuencia de muestreo de la se�al subsampleada
                % Aplicamos un filtro pasa altos con corte en 0.1 Hz
                filtHPF = (2*highpass)/(1/samplePeriod);
                [b, a] = butter(4, filtHPF, 'high');
                data_hp = filtfilt(b, a, data);
                % Aplicamos un filtro pasa bajos con corte en 300 Hz
                filtLPF = (2*lowpass)/(1/samplePeriod);
                [b, a] = butter(4, filtLPF, 'low');
                data_hlp = filtfilt(b, a, data_hp); %se�al de mag de acel filtrada
                amplifier_lfp = data_hlp; % Guardamos la se�al filtrada como "amplifier_PL_downsample_filt"
                clear data_hlp a b data filtHPF data_hp filtLPF highpass lowpass samplePeriod;% Borramos las variables que no me sirven m�s
                % Par�metros �ptimos para analizar frecuencias de 0 a 30 Hz.
                % Igualmente calculo hasta 150 para tener el espectro completo
                params.Fs = 1250; 
                params.err = [2 0.05]; 
                params.tapers = [3 5]; 
                params.pad = 2; 
                params.fpass = [0 12];
                movingwin = [1 0.2];
                disp(['    Analizing PL low frequency multi-taper spectrogram...']);
                [S,t,f,Serr] = mtspecgramc(amplifier_lfp, movingwin, params);
                % Save the results to a .mat file
                % Guardamos solo las variables f,S,Serr,t
                filename = strcat(name,'_specgram_PL_ShortWindow.mat');
                disp(['    Saving ' filename ' file into the Current Folder']);
                save(filename, 'f', 'S', 'Serr', 't','params','movingwin','-v7.3');
                disp(['    Done.']);
            end
            
            % IL
            % Load data and do analysis on data
            load(strcat(name,'_sessioninfo.mat'), 'IL_mainchannel'); ch = IL_mainchannel; clear IL_mainchannel; % Canal a levantar
            if ~isempty(ch)
                % IL low-freq specgram
                % Cargamos un canal LFP del amplificador
                disp(['    Uploading IL amplifier data...']);
                [amplifier_lfp] = LoadBinary(strcat(name,'_lfp.dat'), ch, ch_total);
                amplifier_lfp = amplifier_lfp * 0.195; % Convertir un canal de registro de bits a microvolts (uV).
                % Filtramos la se�al
                disp(['    Filtering IL LFP signal...']);
                highpass = 0.1; lowpass = 300; % Frecuencias de corte del filtro. Corte pasabajos en nyquist frequency.
                data = amplifier_lfp; % Se�al que queremos filtrar
                samplePeriod = 1/1250; % Frecuencia de muestreo de la se�al subsampleada
                % Aplicamos un filtro pasa altos con corte en 0.1 Hz
                filtHPF = (2*highpass)/(1/samplePeriod);
                [b, a] = butter(4, filtHPF, 'high');
                data_hp = filtfilt(b, a, data);
                % Aplicamos un filtro pasa bajos con corte en 300 Hz
                filtLPF = (2*lowpass)/(1/samplePeriod);
                [b, a] = butter(4, filtLPF, 'low');
                data_hlp = filtfilt(b, a, data_hp); %se�al de mag de acel filtrada
                amplifier_lfp = data_hlp; % Guardamos la se�al filtrada como "amplifier_IL_downsample_filt"
                clear data_hlp a b data filtHPF data_hp filtLPF highpass lowpass samplePeriod;% Borramos las variables que no me sirven m�s
                % Par�metros �ptimos para analizar frecuencias de 0 a 30 Hz.
                % Igualmente calculo hasta 150 para tener el espectro completo
                params.Fs = 1250; 
                params.err = [2 0.05]; 
                params.tapers = [3 5]; 
                params.pad = 2; 
                params.fpass = [0 12];
                movingwin = [1 0.2];
                disp(['    Analizing IL low frequency multi-taper spectrogram...']);
                [S,t,f,Serr] = mtspecgramc(amplifier_lfp, movingwin, params);
                % Save the results to a .mat file
                % Guardamos solo las variables f,S,Serr,t
                filename = strcat(name,'_specgram_IL_ShortWindow.mat');
                disp(['    Saving ' filename ' file into the Current Folder']);
                save(filename, 'f', 'S', 'Serr', 't','params','movingwin','-v7.3');
                disp(['    Done.']);
            end       
            
        else
            if exist(file_path, 'file') == 0;
                % The file does not exist, do nothing
                disp(['  File ' file_path ' does not exist.']);
            end
            if exist(sessioninfo_path, 'file') == 0;
                % The file does not exist, do nothing
                disp(['  File ' sessioninfo_path ' does not exist.']);
            end
            disp(['  Skipping action...']);
        end
        
        % Go back to the 'Rxx' folder
        cd(current_R_folder);
    end
end
disp('Done!');
cd(parentFolder);