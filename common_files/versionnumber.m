function [version_num]=versionnumber()

%
% Version Number
%
version_text=version;

periodlocations=findstr(version_text,'.');

if length(periodlocations)>=2
    version_num=version_text(1:periodlocations(2)-1);
else
    version_num=version_text;
end

version_num=str2double(version_num);
if isnan(version_num)
    error('unsupported version number in versionnumber.m!')
end
return

