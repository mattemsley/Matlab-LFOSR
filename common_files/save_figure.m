function []=save_figure(handle,type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  save_figure.m                                                    %%
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
%%  Description:  save_figure.m saves figure to jpeg or eps image    %%
%%                figure defined by handle.                          %%
%%                                                                   %%
%%  Inputs:  handle == handle of figure window  (integer)            %%
%%           type == type of image to be saved (.jpeg,.eps,.ep2,.png)%%
%%                                                                   %%
%%  Outputs: []                                                      %%
%%                                                                   %%
%%  Supporting Files:  exportfig.m - converts plot to jpeg, eps, etc.%%
%%                                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin~=2 %check for proper number of input arguments
   error('Incorrect number of input arguments.')
end

%
% This changes the display and save value to 'jpg' from 'jpeg' which 
%  is used by the exportfig routine
%
if strcmp(type,'jpeg')
    type_file='jpg';
else
    type_file=type;
end

if ~isempty(findstr(type,'.')) & length(type>1)
    search_string=type;
    type_file=type(max(findstr(type,'.'))+1:end);
    if strcmp(type_file,'jpg')
        type='jpeg';
    else
        type=type_file;
    end
else
    search_string=strcat('*.',type_file);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% SAVE FIGURE TO IMAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%user selection of file
[fname,pname]=uiputfile(search_string,'Data Output File Name'); 
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

%
% build file name out of parts and type
%
f_location=fullfile(path,[name,'.',type_file]); %path and name of file

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

%run exportfig routine which converts figure into image file
exportfig(handle,f_location,'Format',type);

%return successfully
disp('Figure saved successfully');
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% END SAVE FIGURE TO IMAGE %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
