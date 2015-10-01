function [x_position_TE,lambda_position_TE,magnitude_E_TE,thickness_total,error_propagation_calculation]=propagation_calculation(lambda,theta,thickness,...
         refractive_index,incremental_distance,Sweep_Variable,Timedebug,Line_suppress)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  propagation_calculation.m                                        %
%  Date: 2/21/2001                                                  %
%  Version: 1.0                                                     %
%  Authors:  Matthew K. Emsley                                      %
%                                                                   %
%  Updates:                                                         %
%           v1.0 8/04/2003 - First Release                          %
%                                                                   %
%  Description:  propagation_calculation.m calculates the E field.  %
%                                                                   %
%  Inputs:  lambda == wavelength matrix- (:,1)matrix                %
%           refractive_index  == indexes for each layer-(:,n)matrix %
%           thickness == thickness for each layer- (:,n)matrix      %
%           theta == theta matrix- (:,1)matrix                      %
%           Layer == layer indentifier for layer sweep              %
%           Sweep_Variable == lambda/theta/layer sweep (100/010/001)%
%           Timedebug == show timing parameters (true/false)        %
%           Line_suppress == surpress line output (true/false)      %
%                                                                   %
%  Outputs: RR == reflection data   ((N;3) matrix- variable,TM,TE)  %
%           TT == transmission data ((N;3) matrix- variable,TM,TE)  %
%           PP == phase data        ((N;3) matrix- variable,TM,TE)  %
%           error_film_calculation==Error coding, 0=no error,1=error%
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check for proper number of input arguments
if nargin~=8||isempty(lambda)||isempty(theta)||isempty(thickness)||isempty(refractive_index)...
      ||isempty(Sweep_Variable)||isempty(Timedebug)||isempty(Line_suppress)||isempty(incremental_distance)...
      ||incremental_distance<0
   error('Incorrect number of input arguments or empty arguments.')
end
error_propagation_calculation=0; %initialize error code to false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% FUNCTION CALCULATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c1=clock;
if ~Line_suppress
   disp('Running Calculations.....')
end

%%%%%%%%%% Reflection Calculation %%%%%%%%%%%%%%%%%%%
[x_position_TE,lambda_position_TE,magnitude_E_TE,thickness_total,error_TE]=PropagationTE(lambda,refractive_index,thickness,incremental_distance,theta);
if error_TE == 1 % Error control, 0 is no error
   disp('Error returned by ReflectionTE.m Routine: Program Haulted!!!')
   x_position_TE=NaN;lambda_position_TE=NaN;magnitude_E_TE=NaN;
   error_propagation_calculation=1;
   return
end

c2=clock; %TE calculation complete

if Sweep_Variable==100 && theta==0 %for lambda sweep at theta 0 TM=TE
   x_position_TM=x_position_TE;lambda_position_TM=lambda_position_TE;magnitude_E_TM=magnitude_E_TE;
   error_TM=error_TE;
else
    [x_position_TM,lambda_position_TM,magnitude_E_TM,error_TM]=PropagationTM(lambda,refractive_index,thickness,incremental_distance,theta);
end
if error_TM == 1 % Error control, 0 is no error
   disp('Error returned by ReflectionTM.m Routine: Program Haulted!!!')
   x_position_TM=NaN;lambda_position_TM=NaN;magnitude_E_TM=NaN;
   error_propagation_calculation=1;
   return
end

c3=clock; %TM calculation complete

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% END FUNCTION CALCULATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
    switch Sweep_Variable
        case 100 %Lambda sweep
            RR=[lambda';R_TM';R_TE'];
            TT=[lambda';T_TM';T_TE'];
            PP=[lambda';P_TM';P_TE'];
            
        case 010 %theta sweep
            RR=[theta';R_TM';R_TE'];
            TT=[theta';T_TM';T_TE'];
            PP=[theta';P_TM';P_TE'];
            
        case 001 %thickness sweep
            RR=[thickness(:,Layer)';R_TM';R_TE'];
            TT=[thickness(:,Layer)';T_TM';T_TE'];
            PP=[thickness(:,Layer)';P_TM';P_TE'];
            
        otherwise
            error('Unsupported sweep variable.')
            
    end
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
      disp('  film_calculation.m Timing Parameters    ')
      disp('------------------------------------------')
      disp(['          TM Calculation = ',num2str(etime(c2,c1),'%-6.3f'),' seconds'])
      disp(['          TE Calculation = ',num2str(etime(c3,c2),'%-6.3f'),' seconds'])
      disp(['      Propagation Output = ',num2str(etime(c4,c3),'%-6.3f'),' seconds'])
      disp(' ')
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% END TIMING DEBUG OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

