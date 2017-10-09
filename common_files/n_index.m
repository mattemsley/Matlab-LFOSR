function [n,error_n_index]=n_index(lambda,layer,warning_alert)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  n_index_new.m                                                    %%
%  Date: 02/13/2001                                                 %%
%  Version: 2.1                                                     %%
%  Authors:  Matthew K. Emsley                                      %%
%            John W. Graff                                          %%
%                                                                   %%
%  Updates:                                                         %%
%            v2.1  Update to handle strings for layers instead of   %%
%                  number assignment                                %%
%            v2.0  Update to matrix input for lambda values         %%
%            v1.0  First release                                    %%
%                                                                   %%
%  Description:  Refractive index function for various materials    %%
%                as a function of wavelength                        %%
%                Supported Materials can be found online            %%
%                                                                   %%
%  Input:       ALL POINTS IN NANOMETERS !!!!!!                     %%
%               lambda: input wavelength in nanometers (vector)     %%
%               layer: material ((X,1)matrix) of strings            %%
%                                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~(nargin==3||nargin==2)  %check that input has proper number of arguments
    error('incorrect number of input arguments');
end
if ~exist('warning_alert')
    warning_alert=1;
end

method='linear'; %Interpolation Method
error_n_index=0; %initialize error code to false
warning off backtrace %turn on warning messages without file and line number message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Error Control of Inputs %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check that lambda is number & > 0
if any(lambda<=0)||isempty(lambda)||~isnumeric(lambda)
    disp('Empty or Invalid Lambda Input: (Lambda must be greater then Zero)!!!!')
    error_n_index=1;
    n=NaN;
    return
end
%check that layer is a char string
if isempty(layer)||~ischar(layer)
    disp('Empty or Invalid Layer Input!!!!')
    error_n_index=1;
    n=NaN;
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%End of Input Error control %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Input Layer Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find how many layers present by number of rows
temp_row=size(layer,1);
temp_column=size(layer,2);

%find index parameters one layer at a time
for r=1:temp_row %Layer Material Processing
    %check if layer name has been check previously
    name_match=strmatch(layer(r,:),cellstr(layer(1:r-1,:)),'exact');
    
    if isempty(name_match)
        %if not then lookup data
        [n(:,r),error_n_material]=n_material(lambda,layer(r,:),method,warning_alert);
    else
        %if it has been checked the name_match is array of indicicies of
        % matches, so use first one
        n(:,r)=n(:,name_match(1));
        %set error to False since if string match was present then 
        % previous error must have been FALSE
        error_n_material=0;
    end
    
    if error_n_material==1 %check for error return
        disp('Error in n_index.m (n_material)!!!!')
        error_n_index=1;
        n=NaN;
        return
        
    end
    
end

warning on backtrace %reset warning messages back to default state
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% End Input Layer Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% End Material Index Calculations %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% N_MATERIAL SUBFUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [n,error_n_material]=n_material(lambda,layer,method,warning_alert)
error_n_material=0; %initialize error flag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% READ N DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%open N index layer file
[fid,message]=fopen(strcat(layer,'.n'));
%checks for unopened files (case sensitive on unix causes problems)
if fid==-1 %check for error on open
    disp('Invalid material name (check case) in (n_material)!!!!')
    error_n_material=1;
    n=NaN;
    return
end

temp_row=0;  %initialize row count
temp_header_row=0; %initialize row + header count
tempx=0; %initialize row vector

% Loop through data file until we get a -1 indicating EOF
while tempx~=-1 
    tempx=fgetl(fid);
    
    if ~isempty(tempx) & tempx~=-1  %if row is not empty count header and data row
        if ~isempty(str2num(tempx(1,1))) %do not string comments in data rows
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
    disp('Invalid material index file or non-existing file in (n_material)!!!!')
    n=NaN;
    error_n_material=1;
    status_c=fclose(fid); %status bit for structure file close
    if status_c==-1 %error closing file
        disp('File closing error in (n_material)!!!!')
        n=NaN;
        error_n_material=1; %file close error
    end
    return
end

frewind(fid); %start at beginning of file
for tempi=1:temp_header_row-temp_row %increment to first row after header
    tempx=fgetl(fid);
end

material_n=fscanf(fid,'%f,%f',[2 temp_row])';  %reads in structure
status=fclose(fid);
if status==-1 %check for error on open
    disp('File closing error in (n_material)!!!!')
    error_n_material=1;
    n=NaN;
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% END READ N DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% READ K DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fid,message]=fopen(strcat(layer,'.k'));
%checks for unopened files (case sensitive on unix causes problems)
if fid==-1 %check for error on open
    disp('Invalid material name (check case) in (n_material)!!!!')
    error_n_material=1;
    n=NaN;
    return
end

temp_row=0;  %initialize row count
temp_header_row=0; %initialize row + header count
tempx=0; %initialize row vector

% Loop through data file until we get a -1 indicating EOF
while tempx~=-1 
    tempx=fgetl(fid);
    
    if ~isempty(tempx) & tempx~=-1  %if row is not empty count header and data row
        if ~isempty(str2num(tempx(1,1))) %do not string comments in data rows
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
    disp('Invalid material index file or non-existing file in (n_material)!!!!')
    n=NaN;
    error_n_material=1;
    status_c=fclose(fid); %status bit for structure file close
    if status_c==-1 %error closing file
        disp('File closing error in (n_material)!!!!')
        n=NaN;
        error_n_material=1; %file close error
    end
    return
end

frewind(fid); %start at beginning of file
for tempi=1:temp_header_row-temp_row %increment to first row after header
    tempx=fgetl(fid);
end

material_k=fscanf(fid,'%f,%f',[2 temp_row])';  %reads in structure
status=fclose(fid);
if status==-1 %check for error on open
    disp('File closing error in (n_material)!!!!')
    error_n_material=1;
    n=NaN;
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% END READ K DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% INTERPOLATE N INDEX %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_min=min(material_n(:,1));  %find minimum wavelength value in data file
n_max=max(material_n(:,1));  %find maximum wavelength value in data file
nreal=zeros(length(lambda),1); %set up nreal part size to same as lambda

%interpolate index values
t_nreal=interp1(material_n(:,1),material_n(:,2),lambda,method);

temp=find(~isnan(t_nreal)); %find all interpolated values

%now need to extrapolate values for lambda values outside of data set
% extrapolation actually just down by finding closest values from data set
% if no values were interpolated then check if lambda values are above or
% below data set
if isempty(temp) 
    %for values above max in data set set all equal to max index value
    if min(lambda)>n_max 
        nreal=ones(length(lambda),1)*...
            interp1(material_n(:,1),material_n(:,2),n_max);
        if warning_alert
            warning(['N-Data not verified for ',upper(layer),' above ',num2str(n_max),' nm'])
        end
        %for values below min in data set set all equal to min index value
    elseif max(lambda)<n_min
        nreal=ones(length(lambda),1)*...
            interp1(material_n(:,1),material_n(:,2),n_min);
        if warning_alert
            warning(['N-Data not verified for ',upper(layer),' below ',num2str(n_min),' nm'])
        end
        
    end
    
else %if there are some interpolated values then set nreal to those values
    nreal(temp)=t_nreal(temp);
    
end

%if there are some non interpolated values outside the data set then 
% set those values to last known values in data set for above and below
% the data set values, this happens when the number of interpolated points
% is different the the number of lambda values requested
if ~isempty(temp)
    if min(temp)>1
        nreal(1:min(temp)-1)=interp1(material_n(:,1),material_n(:,2),n_min);
        if warning_alert
            warning(['N-Data not verified for ',upper(layer),' below ',num2str(n_min),' nm'])
        end
        
    end
    if max(temp)<length(lambda)
        nreal(max(temp)+1:length(lambda))=interp1(material_n(:,1),material_n(:,2),n_max);
        if warning_alert
            warning(['N-Data not verified for ',upper(layer),' above ',num2str(n_max),' nm'])
        end
        
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% END INTERPOLATE N INDEX %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% INTERPOLATE K INDEX %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k_min=min(material_k(:,1));  %find minimum wavelength value in data file
k_max=max(material_k(:,1));  %find maximum wavelength value in data file
kimag=zeros(length(lambda),1); %set up kimag part size to same as lambda

%interpolate index values
t_kimag=interp1(material_k(:,1),material_k(:,2),lambda,method);

temp=find(~isnan(t_kimag)); %find all interpolated values

%now need to extrapolate values for lambda values outside of data set
% extrapolation actually just down by finding closest values from data set
% if no values were interpolated then check if lambda values are above or
% below data set
if isempty(temp)
    %for values above max in data set set all equal to max index value
    if min(lambda)>k_max
        kimag=ones(length(lambda),1)*...
            interp1(material_k(:,1),material_k(:,2),k_max);
        if warning_alert
            warning(['K-Data not verified for ',upper(layer),' above ',num2str(k_max),' nm'])
        end
        
        
        %for values below min in data set set all equal to min index value
    elseif max(lambda)<k_min
        kimag=ones(length(lambda),1)*...
            interp1(material_k(:,1),material_k(:,2),k_min);
        if warning_alert
            warning(['K-Data not verified for ',upper(layer),' below ',num2str(k_min),' nm'])
        end
        
        
    end
    
else %if there are some interpolated values then set nreal to those values
    kimag(temp)=t_kimag(temp);
    
end

%if there are some non interpolated values outside the data set then 
% set those values to last known values in data set for above and below
% the data set values, this happens when the number of interpolated points
% is different the the number of lambda values requested
if ~isempty(temp)
    if min(temp)>1
        kimag(1:min(temp)-1)=interp1(material_k(:,1),material_k(:,2),k_min);
        if warning_alert
            warning(['K-Data not verified for ',upper(layer),' below ',num2str(k_min),' nm'])
        end
        
    end
    if max(temp)<length(lambda)
        kimag(max(temp)+1:length(lambda))=interp1(material_k(:,1),material_k(:,2),k_max);
        if warning_alert
            warning(['K-Data not verified for ',upper(layer),' above ',num2str(k_max),' nm'])
        end
        
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% END INTERPOLATE N INDEX %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%finally put together n and k data into complex refractive index format
i=sqrt(-1);
n=nreal-kimag.*i;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% END N_MATERIAL SUBFUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
