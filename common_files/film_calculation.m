function [RR,TT,PP,error_film_calculation]=film_calculation(lambda,theta,thickness,...
         refractive_index,Layer,Length,Sweep_Variable,Timedebug,Line_suppress,User_selection)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  film_calculation.m                                               %%
%  Date: 2/21/2001                                                  %%
%  Version: 1.0                                                     %%
%  Authors:  Matthew K. Emsley                                      %%
%                                                                   %%
%  Updates:                                                         %%
%           v1.0 2/21/2001 - First Release                          %%
%                                                                   %%
%  Description:  film_calculation.m calculates the reflectivity,    %%
%                transmittance, and phase for a layered structure.  %%
%                LFOSR routines.  reads material string and layer   %%
%                thickness.                                         %%
%                                                                   %%
%  Inputs:  lambda == wavelength matrix- (:,1)matrix                %%
%           refractive_index  == indexes for each layer-(:,n)matrix %%
%           thickness == thickness for each layer- (:,n)matrix      %%
%           theta == theta matrix- (:,1)matrix                      %%
%           Layer == layer indentifier for layer sweep              %%
%           Sweep_Variable == lambda/theta/layer sweep (100/010/001)%%
%           Timedebug == show timing parameters (true/false)        %%
%           Line_suppress == surpress line output (true/false)      %%
%                                                                   %%
%  Outputs: RR == reflection data   ((N;3) matrix- variable,TM,TE)  %%
%           TT == transmission data ((N;3) matrix- variable,TM,TE)  %%
%           PP == phase data        ((N;3) matrix- variable,TM,TE)  %%
%           error_film_calculation==Error coding, 0=no error,1=error%%
%                                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check for proper number of input arguments
if nargin~=10||isempty(lambda)||isempty(theta)||isempty(thickness)||isempty(refractive_index)...
      ||isempty(Sweep_Variable)||isempty(Timedebug)||isempty(Line_suppress)||isempty(Layer)...
      ||Layer<1||isempty(Length)
   error('Incorrect number of input arguments or empty arguments.')
end
error_film_calculation=0; %initialize error code to false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% FUNCTION CALCULATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c1=clock;
if ~Line_suppress
   disp('Running Calculations.....')
end

%%%%%%%%%% Reflection Calculation %%%%%%%%%%%%%%%%%%%
[R_TE,T_TE,P_TE,error_TE]=ReflectionTE(lambda,refractive_index,thickness,theta,Length,User_selection);
if error_TE == 1 % Error control, 0 is no error
   disp('Error returned by ReflectionTE.m Routine: Program Haulted!!!')
   RR=NaN;
   TT=NaN;
   PP=NaN;
   error_film_calculation=1;
   return
end
temp=find(P_TE<0);
P_TE(temp)=P_TE(temp)+360;

c2=clock; %TE calculation complete

if Sweep_Variable==100 && theta==0 %for lambda sweep at theta 0 TM=TE
   R_TM=R_TE;
   T_TM=T_TE;
   P_TM=P_TE;
   error_TM=error_TE;
else
    [R_TM,T_TM,P_TM,error_TM]=ReflectionTM(lambda,refractive_index,thickness,theta,Length,User_selection);
end
if error_TM == 1 % Error control, 0 is no error
   disp('Error returned by ReflectionTM.m Routine: Program Haulted!!!')
   RR=NaN;
   TT=NaN;
   PP=NaN;
   error_film_calculation=1;
   return
end
temp=find(P_TM<0);
P_TM(temp)=P_TM(temp)+360;

c3=clock; %TM calculation complete

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% END FUNCTION CALCULATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
   RR=[thickness(:,Length)';R_TM';R_TE'];
   TT=[thickness(:,Length)';T_TM';T_TE'];
   PP=[thickness(:,Length)';P_TM';P_TE'];
   
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
      disp(' film_calculation.m Timing Parameters    ')
      disp('------------------------------------------')
      disp(['          TM Calculation = ',num2str(etime(c2,c1),'%-6.3f'),' seconds'])
      disp(['          TE Calculation = ',num2str(etime(c3,c2),'%-6.3f'),' seconds'])
      disp(['     Reflectivity Output = ',num2str(etime(c4,c3),'%-6.3f'),' seconds'])
      disp(' ')
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% END TIMING DEBUG OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

