function structure_modify(Handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  structure_modify.m                                               %%
%%  Date: 4/26/2001                                                  %%
%%  Version: 1.1                                                     %%
%%  Authors:  Matthew K. Emsley                                      %%
%%                                                                   %%
%%  Updates:                                                         %%
%%           v1.1 4/26/2001 - Simplify path and file name resolution %%
%%                using 'fullfile' and 'fileparts commands           %%
%%                                                                   %%
%%           v1.0 2/19/2001 - First Release                          %%
%%                                                                   %%
%%  Description:  structure_read.m reads the structure file for      %%
%%                LFOSR routines.  reads material string and layer   %%
%%                thickness.                                         %%
%%                                                                   %%
%%  Inputs:  f_location == path of structure file  (string)          %%
%%                                                                   %%
%%  Outputs: error_structure_read == Error coding, 0=no error,1=error%%
%%                                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin~=1|length(Handles)~=4 %check for proper number of input arguments
   error('Incorrect number of input arguments.')
end

error_structure_modify=0;  %set initial error flag to false

f_location=get(Handles(1),'UserData');
thickness=get(Handles(2),'UserData');
Layer_numbers_1=str2num(get(Handles(3),'String'));
Thick_ratio_1=get(Handles(4),'Value');

thickness_new=thickness;
thickness_new(:,Layer_numbers_1)=thickness(:,Layer_numbers_1).*Thick_ratio_1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% OPEN STRUCTURE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen(f_location,'r');  %open structure file
if fid==-1 %check for error on open
   disp('Invalid file location or non-existing file in structure_modify.m!!!!')
   error_structure_modify=1;
   return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% END OPEN STRUCTURE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% READ STRUCTURE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp_row=0;  %initialize row count
temp_header_row=0; %initialize row + header count
tempx=0; %initialize row vector

% Loop through data file until we get a -1 indicating EOF
while tempx~=-1 
   tempx=fgetl(fid);
   
   if ~isempty(tempx)  %if row is not empty count header and data row
      if ~strcmp(tempx(1,1),'%') %do not count comments in data rows
         temp_row=temp_row+1;
      end
      
   else %if row is empty stop counting as it has reached end of data
      tempx=-1;  %declare end of file
      temp_row=temp_row+1; %increment total rows+1
   
   end
   temp_header_row=temp_header_row+1; %total rows including header
   
end

temp_row = temp_row-1; %total number of data rows
temp_header_row = temp_header_row-1; %total number of data and header rows

if temp_row<=0 %checks number of rows with data, must be >0
   disp('Invalid structure file or non-existing file in structure_read.m!!!!')
   error_structure_modify=1;
   status_c=fclose(fid); %status bit for structure file close
   if status_c==-1 %error closing file
      disp('Filing closing error in structure_read.m!!!!')
      error_structure_modify=1; %file close error
   end
   return
end

frewind(fid); %start at beginning of file
for tempi=1:temp_header_row-temp_row %increment to first row after header
   tempx=fgetl(fid);
end

%now read material string and thickness value from structure file
for tempi = 1:temp_row %read from first to last data row
   name = fscanf(fid,'%s',1); % Filter out string at beginning of line
   num = fscanf(fid,'%f\n')'; % Read in numbers
   
   if isempty(num)==1|isempty(name)==1 %checks name or num for valid data
      disp('Invalid structure file in structure_read.m!!!!')
      error_structure_modify=1;
      status_c=fclose(fid); %status bit for structure file close
      if status_c==-1 %error closing file
         disp('Filing closing error in structure_read.m!!!!')
         error_structure_modify=1; %file close error
      end
      return
   end

   if tempi==1
      names = name; % Add 1st text string
      numbers = num; % Add 1st row
      
   else
      names = str2mat(names,name); % Add next string
      numbers = [numbers;num]; % Add additional rows
      
   end
   
end

status_c=fclose(fid); %status bit for structure file close
if status_c==-1 %error closing file
   disp('Filing closing error in structure_read.m!!!!')
   error_structure_modify=1; %file close error
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%user selection of file
[fname,pname]=uiputfile(strcat('*','.txt'),'Structure File Name'); 
%check for no file selected (i.e. canceled operation)
if isempty(fname)|fname==0 %test for error in filename
   testf=1; %filename error
else
   testf=0; %no filename error
end
if isempty(pname)|pname==0 %test for error in pathname
   testp=1; %pathname error
else
   testp=0; %no pathname error
end
   
if testf==1|testp==1 %no file selected
   %if no file selected return without error
   return
end

[path,name,extension] = fileparts(fullfile(pname,fname));

%
% build file name out of parts and type
%
f_location=fullfile(path,[name,'.txt']); %path and name of file

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


header(1,:)='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
header(2,:)='%%            Film Structure File              %%';
header(3,:)='%% Please refer to http://mosfet.bu.edu/LFOSR/ %%';
header(4,:)='%% for a list of available materials           %%';
header(5,:)='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';
header(6,:)='%%                Top to Bottom                %%';
header(7,:)='%%             Layer||Thickness (nm)           %%';
header(8,:)='%%          ALL POINTS IN NANOMETERS !!!       %%';
header(9,:)='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%';

for i=1:9
   fprintf(fid,'%s\n',header(i,:)); %prints start of header line
end

for i=1:length(thickness_new)
   fprintf(fid,'%s %f\n',names(i,:),thickness_new(i));
end


%close the file and check for error upon closing
status=fclose(fid);
if status==-1
   error('Unable to close file.');
end

%return successfully
disp('Data saved successfully')
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% END READ STRUCTURE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
