% Preprocess raw EEG data for SIFT connectivity analysis - Jan 24, 2018
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------

% -------- Parameters ----------------------------

filter_high = 30;
filter_low = 1.0;
rootDataDir = '/Users/morteza/Desktop/sift_data';
preProcDir = [rootDataDir '/preproc/'];
channelLocationFile = '/Users/morteza/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';
%subjects = {'nsh', 'aka', 'ach', 'akh', 'bah', 'fhe', 'mhe', 'mkh', 'nkh', 'rho', 'rsa', 'sa1', 'sa2', 'sfa', 'sja'};
subjects = {'nsh'};

%--------------------------------------------------


disp('Preprocessing...');

numOfSubjects = length(subjects);

eeglab;

for sIndex = 1:numOfSubjects
  subject = subjects{sIndex};

  disp(['Processing ' subject '...']);

  % To put ICA junks somewhere, change directory to the subject directory
  cd([rootDataDir '/ica']);

  % Open RAW data using FILEIO
  EEG = pop_fileio([rootDataDir '/raw/' subject '_raw.edf']);

  % Select data (19 channels)
  EEG = pop_select( EEG,'nochannel',{'AA'});

  % Load channel locations
  EEG=pop_chanedit(EEG, 'lookup',channelLocationFile);
  EEG = eeg_checkset(EEG);

  % Interpolate noisy electrodes (C4)
  EEG = pop_interp(EEG, [11], 'spherical'); % C4
  EEG = eeg_checkset(EEG);

  % Rereference to average (AA=20)
  EEG = pop_reref( EEG, 20);
  EEG = pop_reref(EEG, []);

  % Filter
  EEG = pop_eegfiltnew(EEG, [], filter_high,110 ,0,[],0);
  EEG = pop_eegfiltnew(EEG, [], filter_low ,8250,1,[],0);
  EEG = eeg_checkset( EEG );

  % Import epochs
  EEG = pop_importevent( EEG, 'event',[rootDataDir '/events/' subject '_erp_epochs.txt'],'fields',{'latency' 'type' 'etype' 'index'},'skipline',1,'timeunit',1,'optimalign','off');

  % ICA (binica)
  [EEG.icaweights, EEG.icasphere] = binica(EEG.data, 'extended', 1);
  EEG.incaact = EEG.icaweights*EEG.icasphere*EEG.data;
  %EEG = eeg_checkset(EEG, 'ica');

  % Save dataset
  EEG = pop_editset(EEG, 'setname',  [subject '_preproc_ica']);
  EEG = pop_saveset(EEG, 'filename', [subject '_preproc_ica.set'], 'filepath', preProcDir);
  eeglab redraw;
end

% for time I forget to do so...
cd(rootDataDir)
