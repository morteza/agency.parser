% Preprocess raw EEG data for SIFT connectivity analysis - Jan 24, 2018
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------

% -------- Parameters ----------------------------

filter_high = 30;
filter_low = 1.0;
rootDataDir = '/Users/morteza/Desktop/sift_data';
preProcDir = [rootDataDir '/preproc/'];
channelLocationFile = '/Users/morteza/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';
subjects = {'nsh', 'aka', 'ach', 'akh', 'bah', 'fhe', 'mhe', 'mkh', 'nkh', 'rho', 'rsa', 'sa1', 'sa2', 'sfa', 'sja'};
%--------------------------------------------------


disp('Preprocessing...');

numOfSubjects = length(subjects);

eeglab 'nogui';

for sIndex = 1:numOfSubjects
  subject = subjects{sIndex};

  disp(['Processing ' subject '...']);

  % To put ICA junks somewhere, change directory to the subject directory
  cd([rootDataDir '/ica']);

  % Open RAW data using FILEIO
  EEG = pop_fileio([rootDataDir '/raw/' subject '_raw.edf']);
  EEG.setname = subject;

  % Select channels (19 channels + AA)
  EEG = pop_select( EEG,'nochannel',{'LABEL'});

  % Rereference to AA (ch. 20)
  EEG = pop_reref(EEG, 20);
  % Rereference to average
  EEG = pop_reref(EEG, []);

  % Import events
  EEG = pop_importevent(EEG, 'event',[rootDataDir '/events/' subject '_epochs_correct_trials.txt'],'fields',{'latency' 'type' 'etype' 'index'},'skipline',1,'timeunit',1,'optimalign','off');
 
  % Load channel locations
  EEG=pop_chanedit(EEG, 'lookup', channelLocationFile);
  EEG = eeg_checkset(EEG);

  % Interpolate noisy electrodes (C4 is channel 11 and was noisy due to the problematic electrode)
  EEG = pop_interp(EEG, 11, 'spherical');
  EEG = eeg_checkset(EEG);

  % Remove line noise using CleanLine on all channels
  EEG = pop_cleanline(EEG, 'bandwidth', 2,'chanlist', [1:19], 'computepower', 0, 'linefreqs', [50 100 150 200 250],...
        'normSpectrum', 0, 'p', 0.01, 'pad', 2, 'plotfigures', 0, 'scanforlines', 1, 'sigtype', 'Channels', 'tau', 100,...
        'verb', 1, 'winsize', 4, 'winstep', 4);
    
  % Filters
  EEG = pop_eegfiltnew(EEG, [], filter_low, 1650, 1, [], 0);
  EEG = pop_eegfiltnew(EEG, [], filter_high, 110, 0, [], 0);
  EEG = eeg_checkset(EEG);

  % ICA (binica)
  %dataRank = rank(double(EEG.data'));
  [EEG.icaweights, EEG.icasphere] = binica(EEG.data, 'extended', 1);
  EEG.incaact = EEG.icaweights*EEG.icasphere*EEG.data;
  EEG = eeg_checkset(EEG, 'ica');

  % Extract epochs and rebase with the following parameters
  %   (baseline -100 to 0, and epochs -1000 to 2000 in millis)
  %TODO: manually run these commands after removing the blink ICA comp
  %EEG = pop_epoch(EEG, {'expl' 'free' 'impl'}, [-1  2], 'epochinfo', 'yes');
  %EEG = eeg_checkset(EEG);
  %EEG = pop_rmbase(EEG, [-100 0]);
  %EEG = eeg_checkset(EEG);
  
  % Save dataset
  EEG = pop_editset(EEG, 'setname',  [subject '_preproc_ica_epochs']);
  EEG = pop_saveset(EEG, 'filename', [subject '_preproc_ica_epochs.set'], 'filepath', preProcDir);
  eeglab redraw;
  
end

% for time I forget to do so...
cd(rootDataDir)
