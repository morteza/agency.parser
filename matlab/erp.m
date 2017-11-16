% Agency ERP Generator Script - Oct 5, 2017
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------

% -------- Parameters ----------------------------
study = 'erp_ica__pruned_4bins';

erpBaseline = [-50 0]; %'pre', 'whole', etc
erpBaselineStr = '-50 0';
%subject = input('Enter subject identifier: ','s');
rootDataDir = '/Users/morteza/Desktop/data';
figuresOutputDir = [rootDataDir '/misc/figures/' study];
erpStorageDir = [rootDataDir '/misc/erp/studies/' study];
preProcDir = [rootDataDir '/misc/preproc_pruned/'];
binListerFile = [rootDataDir '/misc/erp/binlister_4bins.txt'];

subjects = {'nsh', 'aka', 'ach', 'akh', 'bah', 'fhe', 'mhe', 'mkh', 'nkh', 'rho', 'rsa', 'sa1', 'sa2', 'sfa', 'sja'};
%--------------------------------------------------

mkdir(figuresOutputDir);
mkdir(erpStorageDir);

disp(['Starting study: ' study '...']);

numOfSubjects = length(subjects)

eeglab;

for sIndex = 1:numOfSubjects
  subject = subjects{sIndex};

  disp(['Processing ' subject '...']);

  % Load dataset
  EEG = pop_loadset('filename',[subject '_preproc_ica_pruned.set'],'filepath',preProcDir);


  % Create basic EVENTLIST (ERPLAB)
  EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
  EEG = eeg_checkset( EEG );

  % Create bins using BINLISTER
  EEG  = pop_binlister( EEG , 'BDF', binListerFile, 'IndexEL',  1, 'SendEL2', 'Workspace&EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
  EEG = eeg_checkset( EEG );

  % Update EEG epoch labels
  EEG  = pop_overwritevent( EEG, 'binlabel');
  EEG = eeg_checkset( EEG );

  % Extract epochs
  EEG = pop_epochbin(EEG ,[-200.0 800.0],  erpBaseline);
  EEG = eeg_checkset( EEG );

  % Artifact detection (Peak to peak, and blinks) for -100,500 interval
  EEG  = pop_artmwppth( EEG , 'Channel',  1:19, 'Flag', [ 1 2], 'Threshold',  150, 'Twindow', [-100 500], 'Windowsize',  200, 'Windowstep',  50 );
  %EEG  = pop_artblink( EEG , 'Blinkwidth',  400, 'Channel',  1:19, 'Crosscov',  0.7, 'Flag', [ 1 3], 'Twindow', [ -100 500] );

  % Compute ERPs + new diff bins
  ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
  ERP = pop_binoperator( ERP, {  'bin5 = bin1 - bin4',  'bin6 = bin2 - bin4', 'bin7 = bin3 - bin4'});
  ERP = pop_savemyerp(ERP, 'erpname', [subject '_' study '_erp'], 'filename', [subject '_erp_' study '.erp'], 'filepath', erpStorageDir, 'Warning', 'on');

  EEG = pop_saveset( EEG, 'savemode', 'resave');
  EEG = eeg_checkset( EEG );

  % Plot ERP for Fz, Cz, and Pz
  ERP = pop_ploterps( ERP,  1:4,  5:5:15 , 'AutoYlim', 'on', 'Axsize', [0.05 0.08], 'BinNum', 'on', 'Blc', erpBaselineStr, 'Box', [4 1], 'ChLabel', 'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'r-' , 'k-' , 'b-' , 'r:', 'k:' }, 'LineWidth', 1, 'Maximize', 'on', 'Style', 'Classic', 'Tag', ['FzCzPz_' subject '_' study], 'Transparency',  0, 'xscale', [ -200.0 800.0   -200:50:800 ], 'yscale', [ -5.0 5.0   -5:1:5 ], 'YDir', 'normal' );
  ERP = pop_exporterplabfigure( ERP , 'Filepath', figuresOutputDir, 'Format', 'pdf', 'Resolution',  300, 'SaveMode', 'auto', 'Tag', {'ERP_figure' ['FzCzPz_' subject '_' study] } );

  eeglab redraw;
  erplab redraw;
end

% for time I forget to do so...
cd('/Users/morteza/workspace/agency.parser/matlab/')
