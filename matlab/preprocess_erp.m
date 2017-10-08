% Agency ERP Generator Script - Oct 5, 2017
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------

% -------- Parameters ----------------------------
study = 'erp_4bins';

erpBaseline = [-50 0]; %'pre', 'whole', etc
erpBaselineStr = '-50 0';
%subject = input('Enter subject identifier: ','s');
rootDataDir = '/Users/morteza/Desktop/data';
figuresOutputDir = [rootDataDir '/misc/figures/' study];
erpStorageDir = [rootDataDir '/misc/erp/studies/' study];
preProcStorageDir = [rootDataDir '/misc/preproc/studies/' study];
channelLocationFile = '/Users/morteza/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';

binListerFile = [rootDataDir '/misc/erp/binlister_4bins.txt'];

subjects = {'nsh', 'aka', 'ach', 'akh', 'bah', 'fhe', 'mhe', 'mkh', 'nkh', 'rho', 'rsa', 'sa1', 'sa2', 'sfa', 'sja'};
%--------------------------------------------------

mkdir(figuresOutputDir)
mkdir(erpStorageDir)
mkdir(preProcStorageDir)


numOfSubjects = length(subjects)

eeglab;

for sIndex = 1:numOfSubjects
  subject = subjects{sIndex};

  disp(['Processing ' subject '...']);
  cd([rootDataDir '/' subject '/']);

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

  % Rereference to average
  %EEG = pop_reref( EEG, 20);
  EEG = pop_reref( EEG, []);

  % Filter (2-30Hz)
  EEG = pop_eegfiltnew(EEG, [],2,1650,1,[],0);
  EEG = pop_eegfiltnew(EEG, [],30,110,0,[],0);
  EEG = eeg_checkset( EEG );

  % Import epochs
  EEG = pop_importevent( EEG, 'event',[rootDataDir '/' subject '/' subject '_erp_epochs.txt'],'fields',{'latency' 'type' 'etype' 'index'},'skipline',1,'timeunit',1,'optimalign','off');

  % Create basic EVENTLIST (ERPLAB)
  EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
  EEG = eeg_checkset( EEG );

  % Create bins using BINLISTER
  EEG  = pop_binlister( EEG , 'BDF', binListerFile, 'IndexEL',  1, 'SendEL2', 'Workspace&EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
  EEG = eeg_checkset( EEG );

  % Update EEG epoch labels
  EEG  = pop_overwritevent( EEG, 'binlabel');
  EEG = eeg_checkset( EEG );

  EEG = pop_editset(EEG, 'setname', [subject '_preproc']);

  % Extract epochs
  EEG = pop_epochbin(EEG ,[-200.0 800.0],  erpBaseline);
  EEG = pop_saveset( EEG, 'filename', [subject '_preproc.set'], 'filepath', preProcStorageDir);

  % ICA
  %[EEG.icaweights, EEG.icasphere] = binica(EEG.data, 'extended', 1);
  % %EEG.incaact = EEG.icaweights*EEG.icasphere*EEG.data;
  %EEG = eeg_checkset(EEG, 'ica');
  %EEG = pop_saveset( EEG, 'savemode','resave');

  % Artifact detection (Peak to peak, and blinks) for -100,500 interval
  EEG  = pop_artmwppth( EEG , 'Channel',  1:19, 'Flag', [ 1 2], 'Threshold',  150, 'Twindow', [-100 500], 'Windowsize',  200, 'Windowstep',  50 );
  EEG  = pop_artblink( EEG , 'Blinkwidth',  400, 'Channel',  1:19, 'Crosscov',  0.7, 'Flag', [ 1 3], 'Twindow', [ -100 500] );

  % Compute ERPs + new diff bins
  ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
  ERP = pop_binoperator( ERP, {  'bin5 = bin1 - bin4',  'bin6 = bin2 - bin4', 'bin7 = bin3 - bin4'});
  ERP = pop_savemyerp(ERP, 'erpname', [subject '_' study '_erp'], 'filename', [subject '_erp_' study '.erp'], 'filepath', erpStorageDir, 'Warning', 'on');

  % Plot ERP for Fz, Cz, and Pz
  ERP = pop_ploterps( ERP,  1:4,  5:5:15 , 'AutoYlim', 'on', 'Axsize', [0.05 0.08], 'BinNum', 'on', 'Blc', erpBaselineStr, 'Box', [4 1], 'ChLabel', 'on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'r-' , 'k-' , 'b-' , 'r:', 'k:' }, 'LineWidth', 1, 'Maximize', 'on', 'Style', 'Classic', 'Tag', ['FzCzPz_' subject '_' study], 'Transparency',  0, 'xscale', [ -100.0 600.0   -100:50:600 ], 'YDir', 'normal' );
  ERP = pop_exporterplabfigure( ERP , 'Filepath', figuresOutputDir, 'Format', 'pdf', 'Resolution',  300, 'SaveMode', 'auto', 'Tag', {'ERP_figure' ['FzCzPz_' subject '_' study] } );

  eeglab redraw;
  erplab redraw;
end

% for time I forget to do so...
cd('Users/morteza/workspace/agency.parser/matlab/')
