function wpli = wpli(EEG, lowFreq, highFreq)
  chans=size(EEG.data,1);
  
  %% WPLI
  EEG.data = double(EEG.data);
  d = mean(EEG.data,3);
  %CSD
  csd_broadband = csd_func(d(:,:,1), chans);
  
csd=csd_broadband(1,:,:,lowFreq:highFreq);
imaginaries = imag(csd);               % extract imaginary parts
sum(:,:,:)= mean(imaginaries,1);       % mean
sumW(:,:,:)= mean(abs(imaginaries),1); % normalize
raw_wpli = sum./sumW;                  % E(Im(X))/E(|Im(X)|)
wpli=nanmean(raw_wpli(:,:,lowFreq:highFreq),3);
wpli(isnan(wpli))=0;
colormap('hot')
imagesc(wpli)
colorbar
end

function csd = csd_func(data,chans)

  % This function receives data (m*n) and calculates CSD
  for i = 1:chans
    for m = 1:chans
      csd(1,i,m,:) = 2.*(fft(data(i,:)).*conj(fft(data(m,:))))./(size(data,2).^2);
    end
  end
end
