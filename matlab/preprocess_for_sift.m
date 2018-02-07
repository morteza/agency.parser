% Preprocess raw EEG data for SIFT connectivity analysis - Jan 24, 2018
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------

% -------- Parameters ----------------------------
erp_range = [-0.2 1];
erp_baseline = [-200 0];
filter_high = 45;
filter_low = 0.5;
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

  % Import events
  EEG = pop_importevent(EEG, 'event',[rootDataDir '/events/' subject '_epochs_correct_trials.txt'],'fields',{'latency' 'type' 'etype' 'index'},'skipline',1,'timeunit',1,'optimalign','off');
 
  % Load channel locations
  EEG=pop_chanedit(EEG, 'lookup', channelLocationFile);
  EEG = eeg_checkset(EEG);

  % Rereference to AA (ch. 20)
  EEG = pop_reref(EEG, 20);
  % Rereference to average
  EEG = pop_reref(EEG, []);

  % Interpolate noisy electrodes (C4 is channel 11 and was noisy due to the problematic electrode)
  EEG = pop_interp(EEG, 11, 'spherical');
  % ERPLAB: EEG = pop_erplabInterpolateElectrodes( EEG , 'displayEEG',  1, 'ignoreChannels', '[]', 'interpolationMethod', 'spherical', 'replaceChannels',...
  EEG = eeg_checkset(EEG);

  % Remove line noise using CleanLine on all channels
  EEG = pop_cleanline(EEG, 'bandwidth', 2,'chanlist', [1:19], 'computepower', 0, 'linefreqs', [50 100 150 200 250],...
        'normSpectrum', 0, 'p', 0.01, 'pad', 2, 'plotfigures', 0, 'scanforlines', 1, 'sigtype', 'Channels', 'tau', 100,...
        'verb', 1, 'winsize', 4, 'winstep', 4);
    
  % Filters
  EEG = pop_eegfiltnew(EEG, [], filter_low, [], 1, [], 0);
  % EEG = pop_eegfiltnew(EEG, [], filter_high, [], 0, [], 0);
  EEG = eeg_checkset(EEG);

  % Polynominal detrend
  %EEG = pop_polydetrend(EEG , 'Channels',  1:19, 'Method', 'spline', 'Windowsize',  5000, 'Windowstep', 2500);

  % ICA (binica)
  %dataRank = rank(double(EEG.data'));
  EEG = binica(EEG.data, 'icatype', 'binica', 'extended', 1);
  EEG = eeg_checkset(EEG, 'ica');

  % Save the main dataset
  EEG = pop_editset(EEG, 'setname',  [subject '_preproc_ica_epochs']);
  EEG = pop_saveset(EEG, 'filename', [subject '_preproc_ica_epochs.set'], 'filepath', preProcDir);
 
  % Explicit Extract epochs and rebase with the following parameters
  % (pre-baseline, and epochs -200ms to 1000ms)
  EEG_expl = pop_epoch(EEG, {'expl'}, erp_range, 'epochinfo', 'yes');
  EEG_expl = eeg_checkset(EEG_expl);
  EEG_expl = pop_rmbase(EEG_expl, erp_baseline);
  EEG_expl = eeg_checkset(EEG_expl);
  EEG_expl = pop_editset(EEG_expl, 'setname',  [subject '_preproc_ica_expl']);
  EEG_expl = pop_saveset(EEG_expl, 'filename', [subject '_preproc_ica_expl.set'], 'filepath', preProcDir);

  % Implicit
  EEG_impl = pop_epoch(EEG, {'impl'}, erp_range, 'epochinfo', 'yes');
  EEG_impl = eeg_checkset(EEG_impl);
  EEG_impl = pop_rmbase(EEG_impl, erp_baseline);
  EEG_impl = eeg_checkset(EEG_impl);
  EEG_impl = pop_editset(EEG_impl, 'setname',  [subject '_preproc_ica_impl']);
  EEG_impl = pop_saveset(EEG_impl, 'filename', [subject '_preproc_ica_impl.set'], 'filepath', preProcDir);
  
  % Free
  EEG_free = pop_epoch(EEG, {'free'}, erp_range, 'epochinfo', 'yes');
  EEG_free = eeg_checkset(EEG_free);
  EEG_free = pop_rmbase(EEG_free, erp_baseline);
  EEG_free = eeg_checkset(EEG_free);
  EEG_free = pop_editset(EEG_free, 'setname',  [subject '_preproc_ica_free']);
  EEG_free = pop_saveset(EEG_free, 'filename', [subject '_preproc_ica_free.set'], 'filepath', preProcDir);
 
  eeglab redraw;
  
  % Reject ICA components using ADJUST extension
  %cd(preProcDir);
  %pop_ADJUST_interface([subject '_preproc_ica_epochs.set']);
  %EEG = eeg_checkset(EEG);
  
  % Remove rejected components
  %EEG = pop_subcomp(EEG, [%comps%], 0);
  %EEG = eeg_checkset(EEG);
  
end

% for time I forget to do so...
cd(rootDataDir)
