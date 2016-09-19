function [lambda,refractive_index,thickness,theta,...
      error_lfosr_input]=lfosr_input(FVersion,Start,Stop,Points,...
   Angle,Wavelength,Layer,Length,Percentage_Length,Path,Sweep_Variable,Timedebug,User_selection,n_index_warning_alert,Line_suppress)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  lfosr_input.m                                                    %
%  Date: 03/13/2001                                                 %
%  Version: 3.20                                                    %
%  Authors:  Matthew K. Emsley                                      %
%            John W. Graff                                          %
%                                                                   %
%  Description:  lfosr_input.m takes gui input parameters and       %
%                creates lambda, theta, thickness, and refactive    %
%                index matrices for running film_calculation.m or   %
%                detector_calculation.m                             %
%                                                                   %
%  Updates:                                                         %
%            v3.20 03/13/2001  Massive simplifiation of error       %
%            control as well as variable assigment.  Reduced total  %
%            number of variable reassigments to optimize code. Also %
%            removal of bulk of code to seperate routine so that    %
%            this routine only returns variables for further        %
%            processing.  This update renders most past update info %
%            obsolete as they refer to removed code functionality.  %
%                                                                   %
%            v3.13 02/13/2001  Update to structure reading for      %
%            compatibility with strings as materials instead of     %
%            numbers                                                %
%                                                                   %
%            v3.12 02/06/2001  Added option for plotting versus     %
%            energy.                                                %
%                                                                   %
%            v3.11 06/15/2000  Addition of layer sweep to program   %
%            now you can sweep single layer thickenss               %
%                                                                   %
%            v3.1 05/18/2000  Update to gui structure, program      %
%            now runs as independent gui and frees the matlab       %
%            window                                                 %
%                                                                   %
%            v3.0 04/22/2000  Massive update to ReflectionTM,       %
%            ReflectionTE,n_index routines allowing matrix input    %
%            for theta and lambda individually                      %
%                                                                   %
%            v2.0 11/30/1999                                        %
%            Modified Structure File and opening routine so         %
%            anything after '<-- Top -->' is scanned                %
%                                                                   %
%            v1.0 4/19/1999                                         %
%            Original version                                       %
%                                                                   %
%  Inputs:                                                          %
%        FVersion == program version                                %
%        Start == variable start (scaler)                           %
%        Stop  == variable stop (scaler)                            %
%        Points == data points (scaler)                             %
%        Angle == angle variable(scalar)                            %
%        Wavelength == lambda variable(scalar)                      %
%        Layer == layer indentification variable(integer)           %
%        Path == structure file path (string)                       %
%        Sweep_Variable == lambda/theta/layer sweep (100/010/001)   %
%        Timedebug == timing parameters (true/false)                %
%                                                                   %
%  Outputs:                                                         %
%        lambda == column array of lambda values                    %
%        refractive_index == matrix of N indx data for each layer   %
%        thickness  == matrix of thickness for each layer           %
%        theta == column array of theta values                      %
%        error_lfosr_input == error flag 0 false, 1 true            %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin~=15
   error('Incorrect number of input arguments or empty arguments.')
end

if isempty(Path)
   disp('No structure file selected!!!!')
   lambda=NaN;
   refractive_index=NaN;
   thickness=NaN;
   theta=NaN;
   error_lfosr_input=1;
   return
elseif isempty(Points)||Points<1
   disp('You have entered an invalid number of data points.')
   lambda=NaN;
   refractive_index=NaN;
   thickness=NaN;
   theta=NaN;
   error_lfosr_input=1;
   return
end

error_lfosr_input=0;  %initialize error flag
min_wavelength=8;
Points=Points-1; %correction of 1 extra data point being calculated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% DATA INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c1=clock; % Start routine timer

if ~Line_suppress
    disp('Processing Inputs.....')
end

%
% Structure File Reading
%   Reads structure file into layer row vector and
%   thickness column vector
[layer,thickness,error_structure_read]=structure_read(Path);
if error_structure_read  % Checks error codes, 0 is no error
   disp('structure_read.m error returned.')
   lambda=NaN;
   refractive_index=NaN;
   thickness=NaN;
   theta=NaN;
   error_lfosr_input=1;
   return
end

c2=clock; % End of structure file reading

%
% Sweep Variables
%
x=(1:Points+1)'; % Column vector of x datapoints

%
% Set up lambda, theta, and thickness variables for 
%  different sweep conditions. Also validate initial conditions
%
switch Sweep_Variable
case 100 % Lambda sweep
   if isempty(Start)||Start<min_wavelength % Must be great then min_wavelength
      disp(['You have entered an invalid starting wavelength, not valid below ',num2str(min_wavelength),'.'])
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   elseif isempty(Stop)||Stop<=Start % Must be greater then Start
      disp('You have entered an invalid ending wavelength.')
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   elseif isempty(Angle)||Angle<0||Angle>90 % Must be between 0 and 90 degrees
      disp('You have entered an invalid angle: Must be 0<=THETA<=90.')
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   end
   
   if Points==0
       lambda=Start; % Wavelength vector in nm
   else
       lambda=(x-1).*(Stop-Start)./Points+Start; % Wavelength vector in nm
   end
   theta=Angle; % Incident angle in degrees
   
case 010 % Theta sweep
   if isempty(Start)||Start<0||Start>90 % Must be between 0 and 90 degrees 
      disp('You have entered an invalid starting angle.')
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   elseif isempty(Stop)||Stop<=Start||Stop>90 % Must be greater then Start and < 90
      disp('You have entered an invalid ending angle.')
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   elseif isempty(Wavelength)||Wavelength<=min_wavelength % Must be greater then min_wavelength
      disp(['You have entered an invalid starting wavelength, not valid below ',num2str(min_wavelength),'.'])
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   end
   
   lambda=Wavelength; % Wavelength in nm
   theta=(x-1).*(Stop-Start)./Points+Start; % Incident angle vector in degrees

case 001 % Layer thickness sweep
   if isempty(Start)||Start<0 % Must be equal or greater then zero
      disp('You have entered an invalid starting length!!!')
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   elseif isempty(Stop)||Stop<=Start % Must be greater then start
      disp('You have entered an invalid ending length!!!')
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   elseif isempty(Angle)||Angle<0||Angle>90 % Must be between 0 and 90 degrees 
      disp('You have entered an invalid angle: Must be 0<=THETA<=90!!!')
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   elseif isempty(Wavelength)||Wavelength<=min_wavelength % Must be great then min_wavelength
      disp(['You have entered an invalid starting wavelength, not valid below ',num2str(min_wavelength),'.'])
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   elseif isempty(Layer)||Layer<=1 % ||rem(Layer/round(Layer))~=0 %||Layer>length(Layer) % Must be interger > 1
      disp('You have entered an invalid Layer Number: Must be integer greater then 1!!!')
      lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
      error_lfosr_input=1;
      return
   end
   
   %
   % Set up thickness matrix of with POINTS rows for each layer
   %
   thickness=repmat(thickness,length(x),1);
   
   %
   % Now make LAYER vary from STOP to START along the POINTS rows
   %
   if Percentage_Length
       thickness(:,Length)=((x-1).*(Stop-Start)./Points+Start).*thickness(:,Length);
   else
       if strcmpi(User_selection,'biosensor')
           thickness(:,Length)=(x-1).*(Stop-Start)./Points+Start;
           thickness(:,Length+1)=thickness(end:-1:1,Length)-thickness(1,Length);
       elseif strcmpi(User_selection,'peakqeff')
           length_quanta=Wavelength./(2.*abs(n_index(Wavelength,layer(Length,:),n_index_warning_alert)));
           thickness(:,Length)=(x-1).*ceil((ceil(Stop/length_quanta)-ceil(Start/length_quanta))/Points).*length_quanta+ceil(Start/length_quanta)*length_quanta;
       else
           thickness(:,Length)=(x-1).*(Stop-Start)./Points+Start;
       end
   end
   lambda=Wavelength; % Wavelength in nm
   theta=Angle; % Incident angle vector in degrees
   
otherwise
   error('Unsupported sweep variable.')

end

c3=clock; %Variable assignment complete

%
% Layer Processing
%  Find refractive index for each layer at each wavelength
%

[refractive_index,error_n_index]=n_index(lambda,layer,n_index_warning_alert);
if error_n_index>=1  %checks error codes, 0 is no error
   disp('n_index.m error returned!!!!')
   lambda=NaN;refractive_index=NaN;thickness=NaN;theta=NaN;
   error_lfosr_input=1;
   return
end

c4=clock; %Refractive index data compiled
if ~Line_suppress
    disp('   < Input Processing Complete  >')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% END DATA INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%TIMING DEBUG OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Timedebug==1
   disp(' ')
   disp(' lfosr_input.m Timing Parameters          ')
   disp('------------------------------------------')
   disp(['  Structure file reading = ',num2str(etime(c2,c1),'%-6.3f'),' seconds'])
   disp(['     Variable assignment = ',num2str(etime(c3,c2),'%-6.3f'),' seconds'])
   disp([' Refractive index lookup = ',num2str(etime(c4,c3),'%-6.3f'),' seconds'])
   disp(' ')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% END TIMING DEBUG OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% END PROGRAM  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
