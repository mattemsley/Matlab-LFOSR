function index_file_modify(Handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  index_file_modify.m                                              %%
%%  Date: 06/09/2002                                                 %%
%%  Version: 1.1                                                     %%
%%  Authors:  Matthew K. Emsley                                      %%
%%                                                                   %%
%%  Updates:                                                         %%
%%           v1.0 06/09/2002 - First Release                         %%
%%                                                                   %%
%%  Description:  index_file_modify.m reads the index data file for  %%
%%                LFOSR routines and creates the user modified       %%
%%                settings                                           %%
%%                                                                   %%
%%  Inputs:  f_location == path of structure file  (string)          %%
%%                                                                   %%
%%  Outputs: error_structure_read == Error coding, 0=no error,1=error%%
%%                                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin~=1|length(Handles)~=6 %check for proper number of input arguments
   error('Incorrect number of input arguments.')
end

error_index_file_modify=0;  %set initial error flag to false

f_location       = get(Handles(1),'UserData');
refractive_index = get(Handles(2),'UserData');
Layer_numbers_2  = str2num(get(Handles(3),'String'));
Slider_2         = get(Handles(4),'Value');
n_change         = get(Handles(5),'Value');
k_change         = get(Handles(6),'Value');

refractive_index_new=refractive_index;
if n_change & k_change
    refractive_index_new(:,Layer_numbers_2)=refractive_index(:,Layer_numbers_2).*Slider_2;
elseif n_change
    refractive_index_new(:,Layer_numbers_2)=real(refractive_index(:,Layer_numbers_2)).*Slider_2+...
        imag(refractive_index(:,Layer_numbers_2)); 
elseif k_change
    refractive_index_new(:,Layer_numbers_2)=real(refractive_index(:,Layer_numbers_2))+...
        imag(refractive_index(:,Layer_numbers_2)).*Slider_2; 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%user selection of file
[fname,pname]=uiputfile('*.nnn; *.kkk','Structure File Name'); 
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
