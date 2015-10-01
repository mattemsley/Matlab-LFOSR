function []=lfosr_plotinfo_userselect(User_selection,Handles,Answer_Matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  lfosr_plotinfo_userselect.m                                      %%
%%  Date: 6/20/2001                                                  %%
%%  Version: 1.0                                                     %%
%%  Authors:  Matthew K. Emsley                                      %%
%%                                                                   %%
%%  Updates:                                                         %%
%%           v1.0 6/20/2001 - First Release                          %%
%%                                                                   %%
%%  Description:  film_output.m creates figures for plotting with    %%
%%                tools for data manipulation                        %%
%%                                                                   %%
%%  Inputs:  handle_fca_h == axes handle for plotting                %%
%%           FVersion_h == handle for file version ID                %%
%%           Angle_h == handle for Incident Angle value              %%
%%           Wavelength_h == handle for Incident Wavelength value    %%
%%           Layer_h == handle for sweep Thickness No. value         %%
%%           Start_h == handle for y-axis start value                %%
%%           Stop_h == handle for y-axis stop value                  %%
%%           Variable_h == handle for x-variable data                %%
%%           TM_h == handle for TM result data                       %%
%%           TE_h == handle for TE result data                       %%
%%           LambdaorEnergy_Variable == string flag for L or E       %%
%%           Plot_Choice == string for R,T, or P plotting            %%
%%           Sweep_Variable == indentifies sweep variable            %%
%%                                                                   %%
%%  Outputs: []                                                      %%
%%                                                                   %%
%%  Supporting Files:  none                                          %%
%%                                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check for proper number of input arguments
if nargin~=3|length(Handles)~=7
   error('Incorrect number of input arguments.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% PLOTTING AND PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
Version        = Handles(1);
Sweep_Variable = Handles(2);
Angle          = Handles(3);
Wavelength     = Handles(4);
Layer          = Handles(5);
Thickness      = Handles(6);
handle_fca     = Handles(7);
Variable       = Answer_Matrix(1,:);
TM             = Answer_Matrix(2,:);
TE             = Answer_Matrix(3,:);
   
X_min=Variable(1);
X_max=Variable(length(Variable));

switch lower(User_selection)
case 'power'
   TitleString_lambda=['LFOSR FilmCalc v',num2str(Version),' - Incident Angle = ',...
         num2str(Angle),'\circ'];
   TitleString_theta=['LFOSR FilmCalc v',num2str(Version),' - Incident Wavelength = ',...
         num2str(Wavelength),'nm'];
   TitleString_length=['LFOSR FilmCalc v',num2str(Version),' - Incident Angle = ',...
         num2str(Angle),'\circ',' - Incident Wavelength = ',num2str(Wavelength),'nm'];
   YlabelString='Power';
   Y_min=floor(10*min(min(TM),min(TE)))/10;
   Y_max=ceil(10*max(max(TM),max(TE)))/10;
   Y_tick=[];
   
otherwise
   error('Unsupported user section.')
   
end

switch Sweep_Variable
case 100 % Lambda sweep
   TitleString=TitleString_lambda;
   XlabelString='\lambda (nm)';
   X_tick=[];
      
case 010 % Theta sweep
   TitleString=TitleString_theta;
   XlabelString='\theta (Degrees)';
   X_tick=[X_min:(X_max-X_min)/3:X_max];
   
case 001 % Thickness sweep
   TitleString=TitleString_length;
   XlabelString=['Layer ',num2str(Layer),' Thickness (nm)'];
   X_tick=[X_min:(X_max-X_min)/4:X_max];
   
otherwise
   error('Unsupported sweep variable.')
   
end

lfosr_plot(Variable,TM,TE,handle_fca,TitleString,XlabelString,YlabelString,...
   X_min,X_max,X_tick,Y_min,Y_max,Y_tick)

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% END PLOTTING AND PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
