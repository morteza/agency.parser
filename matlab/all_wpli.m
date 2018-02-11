% Calculate wPLI for all subjects - Feb 10, 2018
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------

% -------- Parameters ----------------------------
study = 'agency_wpli_all_chans';

rootDataDir = '/Users/morteza/Desktop/sift_data';
figuresOutputDir = [rootDataDir '/figures/' study '/'];
outputDir = [rootDataDir '/wpli/' study '/'];
preProcDir = [rootDataDir '/preproc/'];
highFreq = 45;
lowFreq = 1;

subjects = {'nsh', 'aka', 'ach', 'akh', 'bah', 'fhe', 'mhe', 'mkh', 'nkh', 'rho', 'rsa', 'sa1', 'sa2', 'sfa', 'sja'};
%--------------------------------------------------

mkdir(figuresOutputDir);
mkdir(outputDir);

disp(['Computing wPLIs for ' study ' study...']);

numOfSubjects = length(subjects);

eeglab;

for sIndex = 1:numOfSubjects
  subject = subjects{sIndex};

  disp(['Calcularing wPLI for ' subject '...']);

  % Load dataset
  EEG = pop_loadset('filename',[subject '_preproc_ica_expl.set'],'filepath',preProcDir);
  EEG = eeg_checkset(EEG);
  exp_pli = wpli(EEG, lowFreq, highFreq, [figuresOutputDir subject '_expl']);
  dlmwrite([outputDir subject '_expl.csv'], exp_pli);
  
  EEG = pop_loadset('filename',[subject '_preproc_ica_impl.set'],'filepath',preProcDir);
  imp_pli = wpli(EEG, lowFreq, highFreq, [figuresOutputDir subject '_impl']);
  dlmwrite([outputDir subject '_impl.csv'], imp_pli);

  EEG = pop_loadset('filename',[subject '_preproc_ica_free.set'],'filepath',preProcDir);
  fre_pli = wpli(EEG, lowFreq, highFreq, [figuresOutputDir subject '_free']);
  dlmwrite([outputDir subject '_free.csv'], fre_pli);

end

eeglab redraw;