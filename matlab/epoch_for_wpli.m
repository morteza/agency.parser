% Calculate wPLI for all subjects - Feb 10, 2018
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------

% -------- Parameters ----------------------------
study = 'agency_wpli_all_chans';

rootDataDir = '/Users/morteza/Desktop/sift_data';
outputDir = [rootDataDir '/wpli/' study '/'];
preProcDir = [rootDataDir '/preproc/'];
erp_range = [-0.2 0.8];
erp_baseline = [-200 0];
subjects = {'nsh', 'aka', 'ach', 'akh', 'bah', 'fhe', 'mhe', 'mkh', 'nkh', 'rho', 'rsa', 'sa1', 'sa2', 'sfa', 'sja'};
%--------------------------------------------------

mkdir(outputDir);

disp(['Epoching for ' study ' study...']);

numOfSubjects = length(subjects);

eeglab;

for sIndex = 1:numOfSubjects
  subject = subjects{sIndex};

  disp(['Epoching for subject ' subject '...']);

  % Load dataset
  EEG = pop_loadset('filename',[subject '_preproc_ica_epochs.set'],'filepath',preProcDir);
  EEG = eeg_checkset(EEG);
  
  % Rerun ICA (binica) after removing noisy components
  %dataRank = rank(double(EEG.data'));
  %EEG = pop_runica(EEG, 'icatype', 'binica', 'extended', 1);
  %EEG = eeg_checkset(EEG, 'ica');

  %EEG = pop_editset(EEG, 'setname',  [subject '_preproc_ica']);
  %EEG = pop_saveset(EEG, 'filename', [subject '_preproc_ica.set'], 'filepath', preProcDir);
  
  % Explicit Extract epochs and rebase with the following parameters
  % (pre-baseline, and epochs -200ms to 800ms)
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
 
end

eeglab redraw;