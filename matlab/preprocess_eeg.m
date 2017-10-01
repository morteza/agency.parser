% Preprocess EEG/ERP data gathered by the agency experiment.
% EEGLAB, CleanLine plugin, and FILEIO plugin are required to run this
% script.

eeglab('nogui');

% Note: Before running the script please make sure data directory and
% eeglab root directory are both set correctly. Also make sure output
% directory to store datasets is created and accessible.


% set double precison (Can be set in EEGLAB options)
% pop_editoptions('option_single', 0);

% Note: relative path does not work for low level EDF reading
dataDir = '/Users/morteza/Desktop/data/';
outputDir = strcat(dataDir,'eeglab/preproc');
eeglabRoot = '/Users/morteza/Documents/MATLAB/eeglab14_1_1b/';

epoch = [-1 2]; % in seconds
epochBaseline = [-200 -100]; % in millis and we have some delays (100ms)!

%subjects = 'ach aka akh bah fhe mhe mkh nkh nsh rho rsa sa1 sa2 sfa sja';
%for subjectIndex = 1:15
subjects = 'nsh'; % testing single subject
for subjectIndex = 1:1 % testing single subject
    subject = subjects(subjectIndex*4-3:subjectIndex*4-1);
    subjectRawData = strcat(dataDir, subject, '/', subject, '_raw.edf');
    subjectProcData = strcat(dataDir, subject, '/', subject, '_proc.edf');
    subjectEpochFile = [dataDir '/misc/epochs/' subject '_eeg_epochs.txt'];
    subjDir = strcat(dataDir, subject);

    % Import data (using FILEIO EDF+ reader)
    EEG = pop_fileio(subjectRawData);
    EEG.setname = subject;
    
    % Down sample (not necessary, since we use 250Hz for now).
    % EEG = pop_resample(EEG, 250);
        
    % Remove channels that are not required (LABEL)
    EEG = pop_select( EEG,'nochannel',{'LABEL'});
   
    % Re-reference the data to AA channel (Channel 20)
    EEG = pop_reref(EEG, 20);
    EEG = eeg_checkset(EEG);
    
    % Import channel location (BEM 10-20)
    EEG = pop_chanedit(EEG, 'lookup',[eeglabRoot, '/plugins/dipfit2.3/standard_BEM/elec/standard_1020.elc'],'eval','chans = pop_chancenter( chans, [],[]);');

    % band-pass filtering (1-40Hz)
    EEG = pop_eegfiltnew(EEG, 0, 40);
    EEG = pop_eegfiltnew(EEG, 1, 0);
    EEG = eeg_checkset(EEG);
     
    % Remove line noises (cleanline) - 
    EEG = pop_cleanline(EEG, 'bandwidth', 2,'chanlist', [1:19], 'computepower', 0, 'linefreqs', [50 100 150 200 250],...
        'normSpectrum', 0, 'p', 0.01, 'pad', 2, 'plotfigures', 0, 'scanforlines', 1, 'sigtype', 'Channels', 'tau', 100,...
        'verb', 1, 'winsize', 4, 'winstep', 4);

    % Reject noisy channels and correct continuous data using ASR.
    % TODO backupEEG = EEG; % keep the old one for interpolation
    % TODO EEG = clean_rawdata(EEG, 5, -1, 0.85, 4, 20, 0.25);

    % Remove nosiy channels (eye-proofed!), and then Interpolate all the removed channels (C4 or No. 11 for now)
    %EEG = pop_select(EEG,'nochannel',{'C4'});
    EEG = pop_interp(EEG, 11, 'spherical'); % Interpolate C4 (Channel 11)
    
    % Import ERP event data into the dataset (<subject>_epochs.txt).
    EEG = pop_importevent( EEG, 'event', subjectEpochFile, 'fields',{'latency' 'grp' 'type' 'index'},'skipline',1,'timeunit',1,'optimalign','off');
    EEG = pop_epoch( EEG, {'start'}, epoch, 'newname', [subject '_epochs'], 'epochinfo', 'yes');
    EEG = eeg_checkset(EEG);
    EEG = pop_rmbase(EEG, epochBaseline);
    EEG = eeg_checkset(EEG);

    % ICA (rank is manually set to 18)
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'pca', 18);
    EEG = eeg_checkset(EEG, 'ica');

    % Remove components (review components and set channel numbers).
    % WARNING: Remove ICA components manually :-)
    %EEG = pop_subcomp( EEG, [1 2 3], 0);

    % Save the dataset
    EEG = pop_saveset(EEG, 'filename', strcat(subject, '_preproc'), 'filepath', outputDir);
    
   % This is to export data to R:
   %EEG = pop_loadset('filename',strcat(name,'.set'),'filepath',path);
   %grp1 = pop_selectevent( EEG, 'type',{'d_some'},'deleteevents','off','deleteepochs','on','invertepochs','off');
   %com = pop_export(d_some, strcat(path2,'d_some/','SI',num2str(i),'_processed_d_some.txt'), 'erp', 'on', 'transpose', 'on');
   %outfile = fopen(strcat(path2,'conditioncounts.txt'),'a');
   %fprintf(outfile, '%i %i %i %i %i\n',[i max([d_some.event.epoch]) max([i_some.event.epoch]) max([d_rest.event.epoch]) max([i_rest.event.epoch])]);
   %fclose(outfile);

end

