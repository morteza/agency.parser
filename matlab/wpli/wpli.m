function wpli = wpli(EEG, lowFreq, highFreq, outputImageFile)
  chans=size(EEG.data,1);
  
  ch_labels = {};
  for c = 1:19
    ch_labels = [ch_labels EEG.chanlocs(c).labels];
  end
  
  data = mean(double(EEG.data),3);
  csd_broadband = csd_func(data(:,:,1), chans);
  
csd = csd_broadband(1,:,:,1:100);
imaginaries = imag(csd);               % extract imaginary parts
sum(:,:,:)= mean(imaginaries,1);       % mean
sumW(:,:,:)= mean(abs(imaginaries),1); % normalize
raw_wpli = sum./sumW;                  % E(Im(X))/E(|Im(X)|)
wpli=nanmean(raw_wpli(:,:,lowFreq:highFreq),3);
wpli(isnan(wpli))=0;
img = imagesc(wpli);
colormap('hot')
caxis([-1.0 1.0])
set(gca, 'XTick', 1:chans, 'XTickLabel', ch_labels)
set(gca, 'YTick', 1:chans, 'YTickLabel', ch_labels)
colorbar
saveas(img, outputImageFile, 'jpg');
end

function csd = csd_func(data,chans)

  % This function receives data (i*m) and calculates CSD
  for i = 1:chans
    for m = 1:chans
      csd(1,i,m,:) = 2.*(fft(data(i,:)).*conj(fft(data(m,:))))./(size(data,2).^2);
    end
  end
end
