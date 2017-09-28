% Preprocess EEG/ERP data gathered by the agency experiment.
% EEGLAB, CleanLine plugin, and FILEIO plugin are required to run this
% script.

% Note: Before running the script please make sure data directory and
% eeglab root directory are both set correctly. Also make sure output
% directory to store datasets is created and accessible.


% set double precison (Can be set in EEGLAB options)
% pop_editoptions('option_single', 0);

% Note: relative path does not work for low level EDF reading
dataDir = '/Users/morteza/Desktop/data/';
outputDir = strcat(dataDir,'eeglab/preproc');
eeglabRoot = '/Users/morteza/Documents/MATLAB/eeglab14_1_1b/';

subjects = 'ach aka akh bah fhe mhe mkh nkh nsh rho rsa sa1 sa2 sfa sja';
for subjectIndex = 1:15
    subject = subjects(subjectIndex*4-3:subjectIndex*4-1);
    subjectRawData = strcat(dataDir, subject, '/', subject, '_raw.edf');
    subjectProcData = strcat(dataDir, subject, '/', subject, '_proc.edf');
    subjDir = strcat(dataDir, subject);

    % Import data (using FILEIO EDF+ reader)
    EEG = pop_fileio(subjectRawData);
    EEG.setname = subject;
    
    % Down sample (not necessary, since we use 250Hz for now).
    % EEG = pop_resample(EEG, 250);
    
    % High-pass filter (1Hz)
    EEG = pop_eegfiltnew(EEG, 1, 0);
    EEG = eeg_checkset( EEG );
    
    % Remove channels that are not required (LABEL)
    EEG = pop_select( EEG,'nochannel',{'LABEL'});

    % Import channel location (BEM 10-20)
    EEG = pop_chanedit(EEG, 'lookup',strcat(eeglabRoot, '/plugins/dipfit2.3/standard_BEM/elec/standard_1020.elc'),'eval','chans = pop_chancenter( chans, [],[]);');
    
    % Import ERP event data into the dataset (<subject>_epochs.txt).
    
    % Remove line noises (cleanline) - 
    EEG = pop_cleanline(EEG, 'bandwidth', 2,'chanlist', [1:19], 'computepower', 0, 'linefreqs', [50 100 150 200 250],...
        'normSpectrum', 0, 'p', 0.01, 'pad', 2, 'plotfigures', 0, 'scanforlines', 1, 'sigtype', 'Channels', 'tau', 100,...
        'verb', 1, 'winsize', 4, 'winstep', 4);
    
    % Reject bad channels and correct continuous data using ASR.
    backupEEG = EEG; % keep the old one for interpolation
    % EEG = clean_rawdata(EEG, 5, -1, 0.85, 4, 20, 0.25);
    
    % Remove nosiy C4
    EEG = pop_select(EEG,'nochannel',{'C4'});
    
    % Interpolate all the removed channels (C4 for now)
    EEG = pop_interp(EEG, backupEEG.chanlocs, 'spherical');
    
    % Re-reference the data
    % ICA
    % Estimate single equivalent current dipoles
    % Eestimate symmetrically constrained bilateral dipoles
    % Save the dataset
    EEG = pop_saveset(EEG, 'filename', strcat(subject, '_preproc'), 'filepath', outputDir);
end

