% Agency ERP Generator Script - Oct 5, 2017
% Morteza Ansarinia <ansarinia@me.com>
% ------------------------------------------------

% -------- Parameters ----------------------------
study = 'erp_ica_pruned_4bins_chop';

%subject = input('Enter subject identifier: ','s');
rootDataDir = '/Users/morteza/Desktop/data';
erpDir = [rootDataDir '/misc/erp/studies/erp_ica__pruned_4bins/'];
preProcDir = [rootDataDir '/misc/preproc_pruned/'];
outputDir = [rootDataDir '/misc/erp/studies/erp_ica__pruned_4bins_chop/'];

subjects = {'nsh', 'aka', 'akh', 'fhe', 'mkh', 'rho', 'rsa', 'sa1', 'sfa', 'sja'};
%--------------------------------------------------

mkdir(outputDir);

disp(['Starting study: ' study '...']);

numOfSubjects = length(subjects)

cd(preProcDir);

eeglab;

for sIndex = 1:numOfSubjects
  subject = subjects{sIndex};

  disp(['Processing ' subject '...']);

  % Load ERPset
  [ERP ALLERP] = pop_loaderp('filename', [subject '_erp_erp_ica__pruned_4bins.erp'], 'filepath', erpDir);

  % new merged channels (ERP)
  ERP = pop_erpchanoperator( ERP, {  'nch1 = (ch1 + ch2) / 2 label Fz',  'nch2 = (ch3 + ch4 + ch5 + ch6 + ch7) / 5 label F', 'nch3 = (ch9 + ch10 + ch11) / 3 label C',  'nch4 = (ch14 + ch15 + ch16) / 3 label P'} , 'ErrorMsg', 'popup', 'KeepLocations',  1, 'Warning', 'on' );

  % save new ERPset
  ERP = pop_savemyerp(ERP, 'erpname', [subject '_' study], 'filename', [subject '_' study '.erp'], 'filepath', outputDir, 'Warning', 'on');


  eeglab redraw;
  erplab redraw;
end

% for time I forget to do so...
cd('/Users/morteza/workspace/agency.parser/matlab/')
