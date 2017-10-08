% Agency ERP Generator Script - Oct 5, 2017
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------

% -------- Parameters ----------------------------

filter_high = 30;
filter_low = 2;
rootDataDir = '/Users/morteza/Desktop/data';
preProcDir = [rootDataDir '/misc/preproc/'];
channelLocationFile = '/Users/morteza/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';
subjects = {'nsh', 'aka', 'ach', 'akh', 'bah', 'fhe', 'mhe', 'mkh', 'nkh', 'rho', 'rsa', 'sa1', 'sa2', 'sfa', 'sja'};
%--------------------------------------------------

disp('Preprocessing...');

numOfSubjects = length(subjects);

eeglab;

for sIndex = 1:numOfSubjects
  subject = subjects{sIndex};

  disp(['Processing ' subject '...']);

  % To put ICA junks somewhere, change directory to the subject directory
  cd([rootDataDir '/' subject]);

  % Open RAW data using FILEIO
  EEG = pop_fileio([rootDataDir '/' subject '/' subject '_raw.edf']);

  % Select data (19 channels)
  EEG = pop_select( EEG,'nochannel',{'LABEL','AA'});

  % Load channel locations
  EEG=pop_chanedit(EEG, 'lookup',channelLocationFile);
  EEG = eeg_checkset( EEG );

  % Interpolate noisy electrods
  EEG = pop_interp(EEG, [11], 'spherical'); % C4
  EEG = eeg_checkset( EEG );

  % Rereference to average (AA=20)
  %EEG = pop_reref( EEG, 20);
  EEG = pop_reref( EEG, []);

  % Filter
  EEG = pop_eegfiltnew(EEG, [], filter_high,110,0,[],0);
  EEG = pop_eegfiltnew(EEG, [], filter_low,1650,1,[],0);
  EEG = eeg_checkset( EEG );

  % Import epochs
  EEG = pop_importevent( EEG, 'event',[rootDataDir '/' subject '/' subject '_erp_epochs.txt'],'fields',{'latency' 'type' 'etype' 'index'},'skipline',1,'timeunit',1,'optimalign','off');

  % ICA (runica)
  EEG = pop_runica(EEG, 'icatype', 'runica', 'extended', 1);
  EEG = eeg_checkset(EEG, 'ica');

  % Save dataset
  EEG = pop_editset(EEG, 'setname', [subject '_preproc_ica']);
  EEG = pop_saveset( EEG, 'filename', [subject '_preproc_ica.set'], 'filepath', preProcDir);
  eeglab redraw;
end

% for time I forget to do so...
cd('/Users/morteza/workspace/agency.parser/matlab/')
