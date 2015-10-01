function [QE,error_detector_calculation]=detector_calculation(lambda,theta,thickness,...
         refractive_index,active_layer,Length,Sweep_Variable,Timedebug,Line_suppress)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  film_calculation.m                                               %
%  Date: 2/21/2001                                                  %
%  Version: 1.0                                                     %
%  Authors:  Matthew K. Emsley                                      %
%                                                                   %
%  Updates:                                                         %
%           v1.0 2/21/2001 - First Release                          %
%                                                                   %
%  Description:  film_calculation.m calculates the reflectivity,    %
%                transmittance, and phase for a layered structure.  %
%                LFOSR routines.  reads material string and layer   %
%                thickness.                                         %
%                                                                   %
%  Inputs:  lambda == wavelength matrix- (:,1)matrix                %
%           refractive_index  == indexes for each layer-(:,n)matrix %
%           thickness == thickness for each layer- (:,n)matrix      %
%           theta == theta matrix- (:,1)matrix                      %
%           Sweep_Variable == lambda/theta/layer sweep (100/010/001)%
%           Timedebug == show timing parameters (true/false)        %
%           Line_suppress == surpress line output (true/false)      %
%                                                                   %
%  Outputs: RR == reflection data   ((N;3) matrix- variable,TM,TE)  %
%           TT == transmission data ((N;3) matrix- variable,TM,TE)  %
%           PP == phase data        ((N;3) matrix- variable,TM,TE)  %
%           error_detector_calculation==Error coding, 0=no error,   %
%           1=error                                                 %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check for proper number of input arguments
if nargin~=9||isempty(lambda)||isempty(theta)||isempty(thickness)||isempty(refractive_index)...
      ||isempty(Sweep_Variable)||isempty(Timedebug)||isempty(Line_suppress)||isempty(active_layer)
   error('Incorrect number of input arguments or empty arguments.')
end
error_detector_calculation=0; %initialize error code to false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% FUNCTION CALCULATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c1=clock;
if ~Line_suppress
   disp('Running Calculations.....')
end

%%%%%%%%% RCE Quantum Efficiency Calculation %%%%%%%%%%%
[QE_TM,error_3_TM]=...
   QuantumEffTM(lambda,refractive_index,thickness,theta,active_layer);
if error_3_TM % Error control from subroutines
   disp('Error returned by QuantumEffTM.m Routine: Program Haulted!!!')
   QE=NaN;Thickness=NaN;
   error_detector_calculation=1;
   return
end

c2=clock; %TM calculation complete

if Sweep_Variable==100 && theta==0 %for lambda sweep at theta 0 TM=TE
   QE_TE=QE_TM;error_4_TE=error_3_TM;
else
   [QE_TE,error_4_TE]=...
      QuantumEffTE(lambda,refractive_index,thickness,theta,active_layer);
end
if error_4_TE % Error control from subroutines
   disp('Error returned by QuantumEffTE.m Routine: Program Haulted!!!')
   QE=NaN;Thickness=NaN;
   error_detector_calculation=1;
   return
end

c3=clock; %TE calculation complete

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% END FUNCTION CALCULATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch Sweep_Variable
case 100 %Lambda sweep
   QE=[lambda';QE_TM';QE_TE'];
      
case 010 %Theta sweep
   QE=[theta';QE_TM';QE_TE'];
   
case 001 %Active Layer Length sweep
   QE=[thickness(:,Length)';QE_TM';QE_TE'];
   
otherwise
   error('Unsupported sweep variable.')
   
end

c4=clock; %reflectivity calculation complete
if ~Line_suppress
   disp('   < Calculations complete      >')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% END PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%TIMING DEBUG OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~Line_suppress
   if Timedebug==1
      disp(' ')
      disp(' detector_calculation.m Timing Parameters ')
      disp('------------------------------------------')
      disp(['          TM Calculation = ',num2str(etime(c2,c1),'%-6.3f'),' seconds'])
      disp(['          TE Calculation = ',num2str(etime(c3,c2),'%-6.3f'),' seconds'])
      disp(['     Quantum Eff. Output = ',num2str(etime(c4,c3),'%-6.3f'),' seconds'])
      disp(' ')
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% END TIMING DEBUG OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

