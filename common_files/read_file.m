function []=read_file(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  read_file.m                                                      %%
%%  Date: 3/29/2001                                                  %%
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
if (nargin < 1) %check that input has proper number of arguments
  error('Incorrect number of input arguments.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% SAVE DATA TO FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FigAxes = varargin{1};
if ~ishandle(FigAxes)
   error('First argument must be axes handle.');
end

Separator_Type = varargin{2}; %second argument is file type string
if ~ischar(Separator_Type)
  error('Second argument must be a string.');
end

%user selection of file
[fname,pname]=uigetfile('*.*','Data File Name'); 
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

%path and name of file plus Rich Text Extension
f_location=fullfile(pname,fname);

%open or create file with write permisson
fid=fopen(f_location,'r');
if fid==-1 %check for error on file creation
   error('Unable to create file.');
end

temp_row=0;  %initialize row count
temp_header_row=0; %initialize row + header count
tempx=0; %initialize row vector

% Loop through data file until we get a -1 indicating EOF
while tempx~=-1 
   tempx=fgetl(fid);
   if ~isempty(tempx) & tempx~=-1  % If row is not empty count header and data row
      if ~isempty(str2num(tempx(1,1))) %do not string comments in data rows
         temp_row=temp_row+1;
         [rows columns]=size(str2num(tempx));
         tempx=-1;  %declare end of file
      end
   end
   temp_header_row=temp_header_row+1; %total rows including header
   
end

%
% If 'rows' or 'columns' does not exist then the data file was corrupt or in 
%  invalid format and an error will be produced
%
if exist('rows','var') & exist('columns','var')
   temp_row = temp_row-1; %total number of data rows
   temp_header_row = temp_header_row-1; %total number of data and header rows
   
   frewind(fid); %start at beginning of file
   for tempi=1:temp_header_row-temp_row %increment to first row after header
      tempx=fgetl(fid);
   end
   
   switch Separator_Type
   case 'comma'
      %reads in structure
      data_set=fscanf(fid,strcat('%f',repmat(',%f',1,columns-1)),[columns inf])';
   case 'space'
      %reads in structure
      data_set=fscanf(fid,strcat('%f',repmat(' %f',1,columns-1)),[columns inf])';
   case 'tab'
      %reads in structure
      data_set=fscanf(fid,strcat('%f',repmat(' %f',1,columns-1)),[columns inf])';
   otherwise
      error('Unsupported separator type.')
   end   
   
   prompt = {'X Scale Factor:','Y Scale Factor:'};
   title  = 'Data Scale Factor';
   lines  = 1;
   def    = {'1','1'};
   answer = inputdlg(prompt,title,lines,def);
   answer = char(answer);
   
   %
   % If cancel is press then the plotting of the line is not performed
   %  and the routine returns without error
   %
   if ~isempty(answer)
      for i=1:2
         scale(i) = str2num(answer(i,:));
         if ischar(scale(i))|isempty(scale(i))
            error('Invalid entry, must be number.')
         end
      end
      
      %close the file and check for error upon closing
      status=fclose(fid);
      if status==-1
         error('Unable to close file.');
      end
      
      line(scale(1).*data_set(:,1),scale(2).*data_set(:,2),'Parent',FigAxes,...
         'LineWidth',3,'LineStyle','-','Color','k')
      handle_leg = legend(FigAxes,'TM Simulated','TE Simulated','Measured',0);
      set(handle_leg,'LineWidth',2)
      
   end
   
else
   error('Invalid or corrupt data file.')
   
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% END SAVE DATA TO FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
