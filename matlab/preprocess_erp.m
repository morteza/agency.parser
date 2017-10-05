% Agency ERP Generator Script - Oct 5, 2017
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------
clear all;
subject = 'nsh';
disp(['Processing ' subject '...'])
rootDataDir = '/Users/morteza/Desktop/data';
channelLocationFile = '/Users/morteza/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';
binListerFile = [rootDataDir '/misc/erp/binlister.txt'];
cd([rootDataDir '/' subject '/']);
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; % ('no-gui');
EEG = pop_fileio([rootDataDir '/' subject '/' subject '_raw.edf']);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',subject,'gui','off');
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'nochannel',{'LABEL'});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',subject,'overwrite','on','gui','off');
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, 20);
EEG=pop_chanedit(EEG, 'lookup',channelLocationFile);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'savemode','resave');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_eegfiltnew(EEG, [],0.5,1650,1,[],1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[subject '_filt'],'savenew',[subject '_filt'],'overwrite','on','gui','off');
EEG = pop_eegfiltnew(EEG, [],20,110,0,[],1);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[subject '_filt'],'overwrite','on','gui','off');
EEG = eeg_checkset( EEG );
EEG = pop_interp(EEG, [11], 'spherical'); % C4
EEG = eeg_checkset( EEG );
EEG = pop_importevent( EEG, 'event',[rootDataDir '/' subject '/' subject '_erp_epochs.txt'],'fields',{'latency' 'type' 'etype' 'index'},'skipline',1,'timeunit',1,'optimalign','off');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'savemode','resave');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[subject '_filt_elist'],'overwrite','on','gui','off');
EEG = eeg_checkset( EEG );
EEG  = pop_binlister( EEG , 'BDF', binListerFile, 'IndexEL',  1, 'SendEL2', 'Workspace&EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG  = pop_overwritevent( EEG, 'binlabel');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[subject '_filt_elist_bins'],'overwrite','on','gui','off');
EEG = eeg_checkset( EEG );
EEG = pop_epochbin( EEG , [-200.0  800.0],  'pre');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[subject '_filt_elist_bins_be'],'overwrite','on','gui','off');

[EEG.icaweights, EEG.icasphere] = binica(EEG.data, 'extended', 1);
EEG.incaact = EEG.icaweights*EEG.icasphere*EEG.data;
EEG = eeg_checkset(EEG, 'ica');
EEG = pop_saveset( EEG, 'savemode','resave');

EEG  = pop_artmwppth( EEG , 'Channel',  1:19, 'Flag', [ 1 2], 'Threshold',  150, 'Twindow', [ -100 500], 'Windowsize',  200, 'Windowstep',  50 );
EEG  = pop_artblink( EEG , 'Blinkwidth',  300, 'Channel',  1:19, 'Crosscov',  0.7, 'Flag', [ 1 3], 'Twindow', [ -100 696] );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',[subject '_filt_elist_bins_be_ar_blink'],'overwrite','on','gui','off');

ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );
ERP = pop_savemyerp(ERP, 'erpname', [subject '_erp'], 'filename', [subject '_erp.erp'], 'filepath', [rootDataDir '/' subject], 'Warning', 'on');

% Plot ERP for Fz, Cz, and Pz
ERP = pop_ploterps( ERP,  1:3,  5:5:15 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'pre', 'Box', [ 3 1], 'ChLabel','on', 'FontSizeChan',  10, 'FontSizeLeg',  12, 'FontSizeTicks',  10, 'LegPos', 'bottom', 'Linespec', {'k-' , 'r-' , 'b-' }, 'LineWidth',  1,'Maximize', 'on', 'Position', [ 93.7143 15.0714 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',  0, 'xscale',[ -300.0 800.0   -200:200:800 ], 'YDir', 'normal' );

eeglab redraw;
