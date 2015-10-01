function [names,numbers,error_structure_read]=structure_read(f_location)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  structure_read.m                                                 %%
%%  Date: 2/19/2001                                                  %%
%%  Version: 1.0                                                     %%
%%  Authors:  Matthew K. Emsley                                      %%
%%                                                                   %%
%%  Updates:                                                         %%
%%           v1.0 2/19/2001 - First Release                          %%
%%                                                                   %%
%%  Description:  structure_read.m reads the structure file for      %%
%%                LFOSR routines.  reads material string and layer   %%
%%                thickness.                                         %%
%%                                                                   %%
%%  Inputs:  f_location == path of structure file  (string)          %%
%%                                                                   %%
%%  Outputs: names == layer material names ((N;1)string matrix)      %%
%%           numbers == layer material thickness ((N;1)matrix)       %%
%%           error_structure_read == Error coding, 0=no error,1=error%%
%%                                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin~=1 %check for proper number of input arguments
   error('Incorrect number of input arguments.')
end

error_structure_read=0;  %set initial error flag to false

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% OPEN STRUCTURE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen(f_location,'r');  %open structure file
if fid==-1 %check for error on open
   disp('Invalid file location or non-existing file in structure_read.m!!!!')
   names=NaN;
   numbers=NaN;
   error_structure_read=1;
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
   names=NaN;
   numbers=NaN;
   error_structure_read=1;
   status_c=fclose(fid); %status bit for structure file close
   if status_c==-1 %error closing file
      disp('Filing closing error in structure_read.m!!!!')
      names=NaN;
      numbers=NaN;
      error_structure_read=1; %file close error
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
      names=NaN;
      numbers=NaN;
      error_structure_read=1;
      status_c=fclose(fid); %status bit for structure file close
      if status_c==-1 %error closing file
         disp('Filing closing error in structure_read.m!!!!')
         names=NaN;
         numbers=NaN;
         error_structure_read=1; %file close error
      end
      return
   end

   if tempi==1
      names = name; % Add 1st text string
      numbers = num; % Add 1st row
      
   else
      names = str2mat(names,name); % Add next string
      numbers = [numbers,num]; % Add additional rows
      
   end
   
end

status_c=fclose(fid); %status bit for structure file close
if status_c==-1 %error closing file
   disp('Filing closing error in structure_read.m!!!!')
   names=NaN;
   numbers=NaN;
   error_structure_read=1; %file close error
   return
end
      
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% END READ STRUCTURE FILE %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
