function [RR_filtered]=spectral_filter_old(RR)
RR=RR';
RR_filtered=RR;

%filter_length=input('Enter filter length -> ');
filter_length=7;

RR_fft_tm=fft(RR(:,2));
RR_fft_te=fft(RR(:,3));

temp_var_tm=zeros(1,length(RR_fft_tm));
temp_var_tm(1:filter_length)=RR_fft_tm(1:filter_length);
temp_var_tm(length(RR_fft_tm)-filter_length:end)=RR_fft_tm(length(RR_fft_tm)-filter_length:end);

temp_var_te=zeros(1,length(RR_fft_te));
temp_var_te(1:filter_length)=RR_fft_te(1:filter_length);
temp_var_te(length(RR_fft_te)-filter_length:end)=RR_fft_te(length(RR_fft_te)-filter_length:end);

RR_filtered(:,2)=abs(ifft(temp_var_tm))';
RR_filtered(:,3)=abs(ifft(temp_var_te))';

RR_filtered=RR_filtered';

return
