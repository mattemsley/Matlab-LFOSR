function []=lfosr_output_userselect(CallBack_h,FVersion,path_data,lambda_data,...
   theta_data,thickness_data,refractive_index_data,Answer_Matrix,Layer,...
   Sweep_Variable,Slider_Bar,Timedebug,User_selection)

if nargin~=13 %check for proper number of input arguments
   error('Incorrect number of input arguments.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% PLOTTING AND PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c1=clock;
disp('Processing Outputs.....')

Who_Called=get(CallBack_h,'Tag');
switch lower(Who_Called)
case 'film'
   Figure_title='Film';
case 'detector'
   Figure_title='QE';
otherwise
   error('Unsupported program call.')
end

dataPos=[0 0 1 1];

[StartFigTextColor,StartFigBackColor,OutputFigTextColor,OutputFigBackColor,...
      ButtonTextColor,ButtonBackColor,EditTextColor,EditBackColor,...
      FrameTextColor,FrameBackColor,FontName,FontUnits,FontWeight,FontAngle,...
      TitleTextFontSize,HeaderTextFontSize,BodyTextFontSize,Body2TextFontSize,...
      SmallTextFontSize,ButtonFontSize,SmallButtonFontSize,...
      StartFigWidth,StartFigHt,OutputFigWidth,OutputFigHt]=lfosr_fontscolors;

handle_fcf=figure('Color',OutputFigBackColor, ...
   'Name',['LFOSR ',Figure_title,'Calc v',num2str(FVersion)],'NumberTitle','off',...
   'WindowStyle','modal');
handle_fca=axes('Parent',handle_fcf);

switch Sweep_Variable
case 100 %Lambda sweep
   Angle=theta_data;
   Wavelength=NaN;
   
   Variable_Type='''Lambda''';
      
case 010 %theta sweep
   Angle=NaN;
   Wavelength=lambda_data;
   
   Variable_Type='''Theta''';
      
case 001 %thickness sweep
   Angle=theta_data;
   Wavelength=lambda_data;
   
   Variable_Type='''A_Thickness''';
   
   
otherwise
   error('Unsupported sweep variable.')
   
end


handle_m = uimenu(handle_fcf,'Label','Workspace');
uimenu(handle_m,'Label',['Save ',User_selection,' Data'],'UserData',Answer_Matrix,...
   'Callback',...
   strcat('save_file(get(gcbo,''Userdata''),''_ref'',',Variable_Type,',''TM'',''TE'')'));
uimenu(handle_m,'Label','Load Comma Separated Data','UserData',handle_fca,'Callback',...
   'read_file(get(gcbo,''Userdata''),''comma'')');
uimenu(handle_m,'Label','Load Space Separated Data','UserData',handle_fca,'Callback',...
   'read_file(get(gcbo,''Userdata''),''space'')');
uimenu(handle_m,'Label','Load Tab Separated Data','UserData',handle_fca,'Callback',...
   'read_file(get(gcbo,''Userdata''),''tab'')');

if versionnumber>=5.3
   uimenu(handle_m,'Label','Save Figure to Postscript',...
      'UserData',handle_fcf,'Callback','save_figure(get(gcbo,''Userdata''),''eps'')');
   uimenu(handle_m,'Label','Save Figure to JPEG',...
      'UserData',handle_fcf,'Callback','save_figure(get(gcbo,''Userdata''),''jpeg'')');
end


Handles=[FVersion,Sweep_Variable,Angle,Wavelength,...
      Layer,thickness_data(Layer),handle_fca];

lfosr_plotinfo_userselect(User_selection,Handles,Answer_Matrix)

set(handle_fcf,'WindowStyle','normal')

c2=clock;
disp('   < Output Processing Complete >')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% END PLOTTING AND PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%TIMING DEBUG OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Timedebug==1
   disp(' ')
   disp(' lfosr_output_userselect.m Timing Parameters ')
   disp('---------------------------------------------')
   disp(['            Output files = ',num2str(etime(c2,c1),'%-6.3f'),' seconds'])
   disp(' ')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% END TIMING DEBUG OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% END PROGRAM  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
