function []=save_file(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  save_file.m                                                      %%
%%  Date: 2/19/2001                                                  %%
%%  Version: 1.0                                                     %%
%%  Authors:  Matthew K. Emsley                                      %%
%%                                                                   %%
%%  Updates:                                                         %%
%%           v1.0 2/19/2001 - First Release                          %%
%%                                                                   %%
%%  Description:  save_file.m saves data to text file (.txt)         %%
%%                                                                   %%
%%  Inputs:  varargin == (data,file_type,variable,data string labels)%%
%%                        number of data colmns must be same as      %%
%%                        number of data string labels               %%
%%                        variable is the x-axis data label          %%
%%                        file_type is user generated file type label%%
%%                                                                   %%
%%  Outputs: []                                                      %%
%%                                                                   %%
%%                                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin < 3) %check that input has proper number of arguments
  error('Incorrect number of input arguments.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% SAVE DATA TO FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = varargin{1}; %first argument is data set matrix
if ~isnumeric(data)
  error('First argument must be a numeric set.');
end
file_type = varargin{2}; %second argument is file type string
if ~ischar(file_type)
  error('Second argument must be a string.');
end
variableString = varargin{3}; %third argument is X-variable header string
if ~ischar(variableString)
  error('Third argument must be a string.');
end
answerStrings = varargin(4:end); %all remain arguments are Y-data header strings

%m_data is number of Y-data sets plus X-variable
[m_data n_data]=size(data);
%n_answerStrings is number of answerStrings sets
[m_answerStrings n_answerStrings]=size(answerStrings);
%compare answer strings to data sets, need to be the same
if (m_data-1)~=n_answerStrings
   error('Number of Data sets doesn''t match number of variable strings.');
end

%
% Version control of _type.txt setting
%   on older versions the uiputfile command acts incorrectly and adds the ending twice
%
if versionnumber < 5.3
      file_type = '';
end

%user selection of file
[fname,pname]=uiputfile(strcat('*',file_type,'.txt'),'Data Output File Name'); 
%check for no file selected (i.e. canceled operation)
if fname==0 %test for error in filename
   testf=1; %filename error
else
   testf=0; %no filename error
end
if pname==0 %test for error in pathname
   testp=1; %pathname error
else
   testp=0; %no pathname error
end
   
if testf==1|testp==1 %no file selected
   %if no file selected return without error
   return
end

[path,name,extension] = fileparts(fullfile(pname,fname));

%if type was given find filname without type
if ~isempty(extension)
   %find starting index of type
   temp=findstr(lower(name),lower(file_type));
   if ~isempty(temp)
       name_notype=name(1:temp(1)-1); %build filname without type (index or type-1)
   else
       name_notype=fname;
   end
else
   name_notype=name; %if no type given then filename is filename without type
end

%path and name of file plus Rich Text Extension
f_location=fullfile(path,[name_notype,file_type,'.txt']); 

button='Overwrite'; %initialize button value if no duplicate exists

%
% need to check if files exists when file typed in by hand without
%  type extension, thereby bipassing operating system catch
%
if isempty(extension) & exist(f_location)>=1 %check if file already exists
   button = questdlg(strcat(f_location,' already exits.'),...
      'Data Output File Name','Overwrite','Cancel','No');
end

%
%if file does exist and the user does not want to overwrite the routine returns
%
if strcmp(button,'Overwrite')
   disp('Creating file')  % continues on to create file and overwrite
elseif strcmp(button,'Cancel')
   disp('Canceled file saving operation') %stops routine without saving
   return
end

%open or create file with write permisson
fid=fopen(f_location,'wt');
if fid==-1 %check for error on file creation
   error('Unable to create file.');
end

header='%'; %starting charcter of header line to allow easy reading in matlab
fprintf(fid,['%-1s%-11s'],header,variableString); %prints start of header line
%this routine adds column titles to output data one set at a time

for i=1:n_answerStrings
   fprintf(fid,[' %-21s'],answerStrings{i});
end
fprintf(fid,'\n'); %once column titles are complete enter new line request
%this prints the format data into columns
fprintf(fid,['%-12.8f',repmat(' %-21.16f',1,m_data-1),'\n'],data);

%close the file and check for error upon closing
status=fclose(fid);
if status==-1
   error('Unable to close file.');
end

%return successfully
disp('Data saved successfully')
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% END SAVE DATA TO FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
