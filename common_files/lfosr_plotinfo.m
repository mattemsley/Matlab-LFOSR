function []=lfosr_plotinfo(Handles,LambdaorEnergy_Variable,Plot_Choice)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  lfosr_plotinfo.m                                                 %
%  Date: 2/27/2001                                                  %
%  Version: 1.0                                                     %
%  Authors:  Matthew K. Emsley                                      %
%            Rachel L. Kaplan                                       %
%                                                                   %
%  Updates:                                                         %
%           v1.0 2/27/2001 - First Release                          %
%                                                                   %
%  Description:  film_output.m creates figures for plotting with    %
%                tools for data manipulation                        %
%                                                                   %
%  Inputs:  handle_fca_h == axes handle for plotting                %
%           FVersion_h == handle for file version ID                %
%           Angle_h == handle for Incident Angle value              %
%           Wavelength_h == handle for Incident Wavelength value    %
%           Layer_h == handle for sweep Thickness No. value         %
%           Start_h == handle for y-axis start value                %
%           Stop_h == handle for y-axis stop value                  %
%           Variable_h == handle for x-variable data                %
%           TM_h == handle for TM result data                       %
%           TE_h == handle for TE result data                       %
%           LambdaorEnergy_Variable == string flag for L or E       %
%           Plot_Choice == string for R,T, or P plotting            %
%           Sweep_Variable == indentifies sweep variable            %
%                                                                   %
%  Outputs: []                                                      %
%                                                                   %
%  Supporting Files:  none                                          %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check for proper number of input arguments
if nargin~=3||length(Handles)~=11
    error('Incorrect number of input arguments.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% PLOTTING AND PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        1        2              3     4          5      6
%Data_h=[FVersion,Sweep_Variable,Angle,Wavelength,Length,Thickness...
%     handle_fca,Variable_h,Answer_TM_h,Answer_TE_h];
%     7          8          9           10

Version           = Handles{1};
Sweep_Variable    = Handles{2};
Angle             = Handles{3};
Wavelength        = Handles{4};
Length            = Handles{5};
Percentage_Length = Handles{6};
Thickness         = Handles{7};
handle_fca        = Handles{8};
Variable          = get(Handles{9},'Userdata');
TM                = get(Handles{10},'Userdata');
TE                = get(Handles{11},'Userdata');

if Percentage_Length
    %Variable=Variable./Thickness;
end

X_min=Variable(1);
X_max=Variable(length(Variable));

switch lower(Plot_Choice)
    case 'responsivity'
        h          =6.62617e-34;        %Planck constant [J.s]
        q          =1.60218e-19;        %Elementary charge [C]
        c          =2.998e8*1e9;        %Speed of Light in Vacuum [nm/s]

        switch Sweep_Variable
            case 100
                TM=TM.*(q/h/c).*Variable;
                TE=TE.*(q/h/c).*Variable;
            case 010
                TM=TM.*(q/h/c).*Wavelength;
                TE=TE.*(q/h/c).*Wavelength;
            case 001
                TM=TM.*(q/h/c).*Wavelength;
                TE=TE.*(q/h/c).*Wavelength;
        end

        %'LFOSR QECalc v',num2str(Version)]},
        TitleString_lambda=['Incident Angle = ',...
            num2str(Angle),'\circ - Active Layer = ',num2str(Thickness),' nm'];
        TitleString_theta =['Incident Wavelength = ',...
            num2str(Wavelength),'nm - Active Layer = ',num2str(Thickness),' nm'];
        TitleString_length=['Incident Angle = ',...
            num2str(Angle),'\circ',' - Incident Wavelength = ',num2str(Wavelength),'nm'];
        YlabelString='Responsivity (A/W)';
        Y_min=0;
        Y_max=ceil(10*max(max(TM),max(TE)))/10;
        Y_tick=0:Y_max/5:Y_max;

    case 'efficiency'
        TitleString_lambda=['Incident Angle = ',...
            num2str(Angle),'\circ - Active Layer = ',num2str(Thickness),' nm'];
        TitleString_theta =['Incident Wavelength = ',...
            num2str(Wavelength),'nm - Active Layer = ',num2str(Thickness),' nm'];
        TitleString_length=['Incident Angle = ',...
            num2str(Angle),'\circ',' - Incident Wavelength = ',num2str(Wavelength),'nm'];
        YlabelString='Quantum Efficiency';
        Y_min=-0.05;
        Y_max=1.05;
        Y_tick=0:0.2:1;

    case 'solar'
        TitleString_lambda=['Incident Angle = ',...
            num2str(Angle),'\circ - Active Layer = ',num2str(Thickness),' nm'];
        TitleString_theta =['Incident Wavelength = ',...
            num2str(Wavelength),'nm - Active Layer = ',num2str(Thickness),' nm'];
        TitleString_length=['Incident Angle = ',...
            num2str(Angle),'\circ',' - Incident Wavelength = ',num2str(Wavelength),'nm'];
        YlabelString='Solar Irradiance Absorbed (A/m^2/nm)';
        Y_min=0;
        Y_max=ceil(10*max(max(TM),max(TE)))/10;
        Y_tick=0:Y_max/5:Y_max;
        
        %'LFOSR FilmCalc v',num2str(Version),
    case 'reflectance'
        TitleString_lambda=['Incident Angle = ',...
            num2str(Angle),'\circ'];
        TitleString_theta=['Incident Wavelength = ',...
            num2str(Wavelength),'nm'];
        TitleString_length=['Incident Angle = ',...
            num2str(Angle),'\circ',' - Incident Wavelength = ',num2str(Wavelength),'nm'];
        YlabelString='Reflectance';
        Y_min=-0.05;
        Y_max=1.05;
        Y_tick=0:0.2:1;

    case 'transmittance'
        TitleString_lambda=['Incident Angle = ',...
            num2str(Angle),'\circ'];
        TitleString_theta=['Incident Wavelength = ',...
            num2str(Wavelength),'nm'];
        TitleString_length=['Incident Angle = ',...
            num2str(Angle),'\circ',' - Incident Wavelength = ',num2str(Wavelength),'nm'];
        YlabelString='Transmittance';
        Y_min=-0.05;
        Y_max=1.05;
        Y_tick=0:0.2:1;

    case 'phase'
        TitleString_lambda=['Incident Angle = ',...
            num2str(Angle),'\circ'];
        TitleString_theta=['Incident Wavelength = ',...
            num2str(Wavelength),'nm'];
        TitleString_length=['Incident Angle = ',...
            num2str(Angle),'\circ',' - Incident Wavelength = ',num2str(Wavelength),'nm'];
        YlabelString='Phase';
        Y_min=-5;
        Y_max=365;
        Y_tick=0:45:360;

    otherwise
        error('Unsupported plot choice.')
end

switch Sweep_Variable
    case 100 % Lambda sweep
        TitleString=TitleString_lambda;

        switch lower(LambdaorEnergy_Variable)
            case 'wavelength'
                XlabelString='\lambda (nm)';
                X_tick=[];
                
                if X_min>2000
                    Variable=Variable./1000;
                    X_min=X_min/1000;
                    X_max=X_max/1000;
                    %X_tick=X_min/1000:(X_max/1000-X_min/1000)/3:X_max/1000;
                    
                    XlabelString='\lambda (\mum)';
                end

            case 'energy'
                XlabelString='Energy (eV)';
                Variable=1239.838034./Variable;

                temp_start=X_min;
                temp_stop=X_max;

                X_min=1239.838034/temp_stop;
                X_max=1239.838034/temp_start;
                X_tick=[];
            otherwise
                error('Unsupported X variable.')
        end

    case 010 % Theta sweep
        TitleString=TitleString_theta;
        XlabelString='\theta (Degrees)';
        X_tick=X_min:(X_max-X_min)/3:X_max;

    case 001 % Thickness sweep
        TitleString=TitleString_length;
        %   if Percentage_Length
        %       XlabelString=['Layer ',num2str(Length),' Thickness (nm)'];
        %       X_min=X_min/Thickness;
        %       X_max=X_max/Thickness;
        %       X_tick=[X_min:(X_max-X_min)/4:X_max];
        %   else
        XlabelString=['Layer ',num2str(Length),' Thickness (nm)'];
        X_tick=X_min:(X_max-X_min)/4:X_max;
        %   end
    otherwise
        error('Unsupported sweep variable.')

end

lfosr_plot(Variable,TM,TE,handle_fca,TitleString,XlabelString,YlabelString,...
    X_min,X_max,X_tick,Y_min,Y_max,Y_tick)

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% END PLOTTING AND PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function lfosr_plot(Variable,TM,TE,handle_fca,TitleString,XlabelString,YlabelString,...
    Start,Stop,X_tick,Y_min,Y_max,Y_tick)

[StartFigTextColor,StartFigBackColor,OutputFigTextColor,OutputFigBackColor,...
    ButtonTextColor,ButtonBackColor,EditTextColor,EditBackColor,...
    FrameTextColor,FrameBackColor,FontName,FontUnits,FontWeight,FontAngle,...
    TitleTextFontSize,HeaderTextFontSize,BodyTextFontSize,Body2TextFontSize,...
    SmallTextFontSize,ButtonFontSize,SmallButtonFontSize,...
    StartFigWidth,StartFigHt,OutputFigWidth,OutputFigHt]=lfosr_fontscolors;

if versionnumber<5.3
    cla
end

handle_sim = plot(Variable,TM,Variable,TE,'LineWidth',3,'Parent',handle_fca);
handle_leg = legend(handle_fca,'TM','TE','location','best');
set(handle_leg,'LineWidth',2)
set(handle_sim(1),'Color',[0 0 1],'LineStyle','-.')
set(handle_sim(2),'Color',[0 .5 0],'LineStyle',':')
set(handle_fca,'title',text(...
    'FontName',FontName,...
    'FontUnits',FontUnits,...
    'FontSize',BodyTextFontSize, ...
    'FontWeight',FontWeight,...
    'FontAngle',FontAngle,...
    'Color',OutputFigTextColor,...
    'String',TitleString))
set(handle_fca,'xlabel',text(...
    'FontName',FontName,...
    'FontUnits',FontUnits,...
    'FontSize',BodyTextFontSize, ...
    'FontWeight',FontWeight,...
    'FontAngle',FontAngle,...
    'Color',OutputFigTextColor,...
    'String',XlabelString))
set(handle_fca,'ylabel',text(...
    'FontName',FontName,...
    'FontUnits',FontUnits,...
    'FontSize',BodyTextFontSize, ...
    'FontWeight',FontWeight,...
    'FontAngle',FontAngle,...
    'Color',OutputFigTextColor,...
    'String',YlabelString))
set(handle_fca,...
    'FontName',FontName,...
    'FontUnits',FontUnits,...
    'FontSize',BodyTextFontSize, ...
    'FontWeight',FontWeight,...
    'FontAngle',FontAngle,...
    'XColor',OutputFigTextColor,...
    'YColor',OutputFigTextColor)

axis([Start Stop Y_min Y_max])

if ~isempty(Y_tick)
    set(handle_fca,'YTick',Y_tick)
end

if ~isempty(X_tick)
    set(handle_fca,'XTick',X_tick)
end

set(handle_fca,'LineWidth',2.0)

%
% Set user data to line handles for later use
%  TM = 1, TE = 2
%
set(handle_fca,'Userdata',handle_sim)

%
% Turn on grid
%
set(handle_fca,'XGrid','on','YGrid','on','gridlinestyle',':')