function []=lfosr_adjust(Call_h,handle_fca,Handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  lfosr_adjust.m                                                   %
%  Date: 6/28/2001                                                  %
%  Version: 1.0                                                     %
%  Authors:  Matthew K. Emsley                                      %
%                                                                   %
%  Updates:                                                         %
%           v1.1 6/28/2001 - Fix to Layer number input.  Pressing   %
%                enter multiple times when Stick Layers is selected %
%                caused the same layer to be continually multiplied %
%                                                                   %
%           v1.0 2/27/2001 - First Release                          %
%                                                                   %
%  Description:  film_adjust.m takes slider bar data and verifies   %
%                slider bar values then adjusts orginal structure   %
%                thicknesses and replots the calculated R,T, or P   %
%                on the callback figure                             %
%                                                                   %
%  Inputs:  Call_h == handle of callback object                     %
%           handle_fca == axes handle for plotting                  %
%           Slider_1_min_h == handle for slider 1 min data          %
%           Slider_1_max_h == handle for slider 1 max data          %
%           Slider_1_value_h == handle for slider 1 edit input data %
%           Slider_1_h == handle for slider 1 data                  %
%           Layer_numbers_1_h == handle for slider 1 layer data     %
%           Slider_2_min_h == handle for slider 2 min data          %
%           Slider_2_max_h == handle for slider 2 max data          %
%           Slider_2_value_h == handle for slider 2 edit input data %
%           Slider_2_h == handle for slider 2 data                  %
%           Layer_numbers_2_h == handle for slider 2 layer data     %
%           lambda_h == handle for original lambda array data       %
%           theta_h == handle for orginal theta array data          %
%           thickness_h == handle for for orgininal thickness data  %
%           refractive_index_h == handle for orig N matrix data     %
%           Sweep_Variable == indentifies sweep variable            %
%                                                                   %
%  Outputs: []                                                      %
%                                                                   %
%  Supporting Files:  film_calculation.m - used to recalc R,T,P     %
%                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin~=3||length(Handles)~=36 %check for proper number of input arguments
    error('Incorrect number of input arguments.')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% ADJUST PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[StartFigTextColor,StartFigBackColor,OutputFigTextColor,OutputFigBackColor,...
    ButtonTextColor,ButtonBackColor,EditTextColor,EditBackColor,...
    FrameTextColor,FrameBackColor,FontName,FontUnits,FontWeight,FontAngle,...
    TitleTextFontSize,HeaderTextFontSize,BodyTextFontSize,Body2TextFontSize,...
    SmallTextFontSize,ButtonFontSize,SmallButtonFontSize,...
    StartFigWidth,StartFigHt,OutputFigWidth,OutputFigHt]=lfosr_fontscolors;

Line_suppress=1;
Timedebug=0;

Slider_1_min_h=Handles(1);
Slider_1_max_h=Handles(2);
Slider_1_value_h=Handles(3);
Slider_1_h=Handles(4);
Layer_numbers_1_h=Handles(5);
Slider_2_min_h=Handles(6);
Slider_2_max_h=Handles(7);
Slider_2_value_h=Handles(8);
Slider_2_h=Handles(9);
Layer_numbers_2_h=Handles(10);
Slider_3_min_h=Handles(11);
Slider_3_max_h=Handles(12);
Slider_3_value_h=Handles(13);
Slider_3_h=Handles(14);
Sticky_1_h=Handles(15);
Display_1_h=Handles(16);
Sticky_2_h=Handles(17);
Display_2_h=Handles(18);
lambda_h=Handles(19);
theta_h=Handles(20);
thickness_h=Handles(21);
n_change_h=Handles(22);
k_change_h=Handles(23);
refractive_index_h=Handles(24);
Sweep_Variable=Handles(25);
FVersion=Handles(26);
Layer_numbers_1_previous_h=Handles(27);
Layer_numbers_2_previous_h=Handles(28);
thickness_data_original_h=Handles(29);
refractive_index_original_h=Handles(30);
Reset_h=Handles(31);
Reset_index_h=Handles(32);
CallBack_h=Handles(33);
Layer=Handles(34);
Length=Handles(35);
User_selection=get(Handles(36),'Userdata');

switch Sweep_Variable
    case 100
        Minval_3=0;
        Maxval_3=90;
        
    case 010
        Minval_3=get(lambda_h,'Userdata')-50;
        Maxval_3=get(lambda_h,'Userdata')+50;
        
    case 001
        Minval_3=0;
        Maxval_3=90;
        
    otherwise
        error('Unsupported sweep variable.')
        
end

call_value=(([Slider_1_h,Slider_1_value_h,Slider_1_max_h,Slider_1_min_h,Layer_numbers_1_h,...
    Slider_2_h,Slider_2_value_h,Slider_2_max_h,Slider_2_min_h,Layer_numbers_2_h,...
    Slider_3_h,Slider_3_value_h,Slider_3_max_h,Slider_3_min_h,Reset_h,Reset_index_h]-Call_h)==0);

call_value=1*10^(find(call_value==1)-1);

Min_1=str2double(get(Slider_1_min_h,'String'));
Max_1=str2double(get(Slider_1_max_h,'String'));

Min_2=str2double(get(Slider_2_min_h,'String'));
Max_2=str2double(get(Slider_2_max_h,'String'));

Min_3=str2double(get(Slider_3_min_h,'String'));
Max_3=str2double(get(Slider_3_max_h,'String'));

switch call_value
    case 1e0  %Slider call back
        Slider_1=get(Slider_1_h,'Value');
        set(Slider_1_value_h,'String',Slider_1)
        
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e1  %Slider Edit call back
        Slider_1=str2double(get(Slider_1_value_h,'String'));
        if Slider_1>Max_1
            set(Slider_1_h,'Value',Max_1)
            set(Slider_1_value_h,'String',Max_1)
            Slider_1=Max_1;
        elseif Slider_1<Min_1
            set(Slider_1_h,'Value',Min_1)
            set(Slider_1_value_h,'String',Min_1)
            Slider_1=Min_1;
        else
            set(Slider_1_h,'Value',Slider_1)
        end
        
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e2  %Slider Max call back
        if Max_1<=0
            set(Slider_1_min_h,'String',0)
            set(Slider_1_max_h,'String',1)
        elseif Max_1<=Min_1
            if Max_1-1<0
                set(Slider_1_min_h,'String',0)
                set(Slider_1_max_h,'String',Max_1)
            else
                set(Slider_1_min_h,'String',Max_1-1)
            end
        end
        set(Slider_1_h,'Min',str2double(get(Slider_1_min_h,'String')))
        set(Slider_1_h,'Max',str2double(get(Slider_1_max_h,'String')))
        
        Min_1=str2double(get(Slider_1_min_h,'String'));
        Max_1=str2double(get(Slider_1_max_h,'String'));
        
        Slider_1=get(Slider_1_h,'Value');
        if Slider_1>Max_1
            set(Slider_1_h,'Value',Max_1)
            set(Slider_1_value_h,'String',Max_1)
            Slider_1=Max_1;
        elseif Slider_1<Min_1
            set(Slider_1_h,'Value',Min_1)
            set(Slider_1_value_h,'String',Min_1)
            Slider_1=Min_1;
        else
            set(Slider_1_value_h,'String',Slider_1)
        end
        
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e3  %Slider Min call back
        if Max_1<=Min_1
            set(Slider_1_max_h,'String',Min_1+Max_1)
        elseif Min_1<0
            set(Slider_1_min_h,'String',0)
        end
        set(Slider_1_h,'Min',str2double(get(Slider_1_min_h,'String')))
        set(Slider_1_h,'Max',str2double(get(Slider_1_max_h,'String')))
        
        Min_1=str2double(get(Slider_1_min_h,'String'));
        Max_1=str2double(get(Slider_1_max_h,'String'));
        
        Slider_1=get(Slider_1_h,'Value');
        if Slider_1>Max_1
            set(Slider_1_h,'Value',Max_1)
            set(Slider_1_value_h,'String',Max_1)
            Slider_1=Max_1;
        elseif Slider_1<Min_1
            set(Slider_1_h,'Value',Min_1)
            set(Slider_1_value_h,'String',Min_1)
            Slider_1=Min_1;
        else
            set(Slider_1_value_h,'String',Slider_1)
        end
        
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e4  %Layer number call back
        Slider_1=get(Slider_1_h,'Value');
        
        Layer_numbers_1_previous=get(Layer_numbers_1_previous_h,'UserData');
        
        %
        % This check is performed so that in the event that someone presses
        %  enter multiple times without changing the layer number, when Sticky
        %  Layers is selected, the thickness will not be continually multiplied
        %
        if get(Sticky_1_h,'Value')||get(Sticky_2_h,'Value')
            if Layer_numbers_1_previous~=str2double(get(Layer_numbers_1_h,'String'))
                thickness=get(thickness_h,'Userdata');
                thickness_new=thickness;
                thickness_new(:,Layer_numbers_1_previous)=thickness_new(:,Layer_numbers_1_previous).*Slider_1;
                
                if get(Sticky_1_h,'Value')
                    set(thickness_h,'Userdata',thickness_new)
                end
                set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
            end
        end
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e5 %Slider 2 call back
        Slider_2=get(Slider_2_h,'Value');
        set(Slider_2_value_h,'String',Slider_2)
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e6 %Slider 2 Edit call back
        Slider_2=str2double(get(Slider_2_value_h,'String'));
        if Slider_2>Max_2
            set(Slider_2_h,'Value',Max_2)
            set(Slider_2_value_h,'String',Max_2)
            Slider_2=Max_2;
        elseif Slider_2<Min_2
            set(Slider_2_h,'Value',Min_2)
            set(Slider_2_value_h,'String',Min_2)
            Slider_2=Min_2;
        else
            set(Slider_2_h,'Value',Slider_2)
        end
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e7 %Slider 2 Max call back
        if Max_2<=0
            set(Slider_2_min_h,'String',0)
            set(Slider_2_max_h,'String',1)
        elseif Max_2<=Min_2
            if Max_2-1<0
                set(Slider_2_min_h,'String',0)
                set(Slider_2_max_h,'String',Max_2)
            else
                set(Slider_2_min_h,'String',Max_2-1)
            end
        end
        set(Slider_2_h,'Min',str2double(get(Slider_2_min_h,'String')))
        set(Slider_2_h,'Max',str2double(get(Slider_2_max_h,'String')))
        
        Min_2=str2double(get(Slider_2_min_h,'String'));
        Max_2=str2double(get(Slider_2_max_h,'String'));
        
        Slider_2=get(Slider_2_h,'Value');
        if Slider_2>Max_2
            set(Slider_2_h,'Value',Max_2)
            set(Slider_2_value_h,'String',Max_2)
            Slider_2=Max_2;
        elseif Slider_2<Min_2
            set(Slider_2_h,'Value',Min_2)
            set(Slider_2_value_h,'String',Min_2)
            Slider_2=Min_2;
        else
            set(Slider_2_value_h,'String',Slider_2)
        end
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e8 %Slider 2 Min call back
        if Max_2<=Min_2
            set(Slider_2_max_h,'String',Min_2+Max_2)
        elseif Min_2<0
            set(Slider_2_min_h,'String',0)
        end
        set(Slider_2_h,'Min',str2double(get(Slider_2_min_h,'String')))
        set(Slider_2_h,'Max',str2double(get(Slider_2_max_h,'String')))
        
        Min_2=str2double(get(Slider_2_min_h,'String'));
        Max_2=str2double(get(Slider_2_max_h,'String'));
        
        Slider_2=get(Slider_2_h,'Value');
        if Slider_2>Max_2
            set(Slider_2_h,'Value',Max_2)
            set(Slider_2_value_h,'String',Max_2)
            Slider_2=Max_2;
        elseif Slider_2<Min_2
            set(Slider_2_h,'Value',Min_2)
            set(Slider_2_value_h,'String',Min_2)
            Slider_2=Min_2;
        else
            set(Slider_2_value_h,'String',Slider_2)
        end
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e9 %Slider 2 Layers call back
        Slider_2=get(Slider_2_h,'Value');
        
        Layer_numbers_2_previous=get(Layer_numbers_2_previous_h,'UserData');
        
        %
        % This check is performed so that in the event that someone presses
        %  enter multiple times without changing the layer number, when Sticky
        %  Layers is selected, the thickness will not be continually multiplied
        %
        if Layer_numbers_2_previous~=str2double(get(Layer_numbers_2_h,'String'))
            refractive_index=get(refractive_index_h,'Userdata');
            refractive_index_new=refractive_index;
            refractive_index_new(:,Layer_numbers_2_previous)=...
                refractive_index_new(:,Layer_numbers_2_previous).*Slider_2;
            
            if get(Sticky_2_h,'Value')
                set(refractive_index_h,'Userdata',refractive_index_new)
            end
            set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        end
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
        
    case 1e10  %Slider 3 call back
        Slider_3=get(Slider_3_h,'Value');
        set(Slider_3_value_h,'String',Slider_3)
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        
    case 1e11  %Slider 3 Edit call back
        Slider_3=str2double(get(Slider_3_value_h,'String'));
        if Slider_3>Max_3
            set(Slider_3_h,'Value',Max_3)
            set(Slider_3_value_h,'String',Max_3)
            Slider_3=Max_3;
        elseif Slider_3<Min_3
            set(Slider_3_h,'Value',Min_3)
            set(Slider_3_value_h,'String',Min_3)
            Slider_3=Min_3;
        else
            set(Slider_3_h,'Value',Slider_3)
        end
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        
    case 1e12  %Slider 3 Max call back
        if Max_3<Minval_3
            set(Slider_3_min_h,'String',Minval_3)
            set(Slider_3_max_h,'String',Maxval_3)
        elseif Max_3<=Min_3
            set(Slider_3_min_h,'String',Minval_3)
            set(Slider_3_max_h,'String',Max_3)
        elseif Max_3>Maxval_3
            set(Slider_3_max_h,'String',Maxval_3)
        end
        set(Slider_3_h,'Min',str2double(get(Slider_3_min_h,'String')))
        set(Slider_3_h,'Max',str2double(get(Slider_3_max_h,'String')))
        
        Min_3=str2double(get(Slider_3_min_h,'String'));
        Max_3=str2double(get(Slider_3_max_h,'String'));
        
        Slider_3=get(Slider_3_h,'Value');
        if Slider_3>Max_3
            set(Slider_3_h,'Value',Max_3)
            set(Slider_3_value_h,'String',Max_3)
            Slider_3=Max_3;
        elseif Slider_3<Min_3
            set(Slider_3_h,'Value',Min_3)
            set(Slider_3_value_h,'String',Min_3)
            Slider_3=Min_3;
        else
            set(Slider_3_value_h,'String',Slider_3)
        end
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        
    case 1e13  %Slider 3 Min call back
        if Min_3>Maxval_3
            set(Slider_3_min_h,'String',Minval_3)
            set(Slider_3_max_h,'String',Maxval_3)
        elseif Min_3>=Max_3
            set(Slider_3_min_h,'String',Min_3)
            set(Slider_3_max_h,'String',Maxval_3)
        elseif Min_3<Minval_3
            set(Slider_3_min_h,'String',Minval_3)
        end
        set(Slider_3_h,'Min',str2double(get(Slider_3_min_h,'String')))
        set(Slider_3_h,'Max',str2double(get(Slider_3_max_h,'String')))
        
        Min_3=str2double(get(Slider_3_min_h,'String'));
        Max_3=str2double(get(Slider_3_max_h,'String'));
        
        Slider_3=get(Slider_3_h,'Value');
        if Slider_3>Max_3
            set(Slider_3_h,'Value',Max_3)
            set(Slider_3_value_h,'String',Max_3)
            Slider_3=Max_3;
        elseif Slider_3<Min_3
            set(Slider_3_h,'Value',Min_3)
            set(Slider_3_value_h,'String',Min_3)
            Slider_3=Min_3;
        else
            set(Slider_3_value_h,'String',Slider_3)
        end
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        
    case 1e14 %Reset Thickness
        set(thickness_h,'Userdata',get(thickness_data_original_h,'UserData'))
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    case 1e15 %Reset Index
        set(refractive_index_h,'Userdata',get(refractive_index_original_h,'UserData'))
        
        Slider_1=get(Slider_1_h,'Value');
        set(Layer_numbers_1_previous_h,'UserData',str2double(get(Layer_numbers_1_h,'String')))
        Slider_2=get(Slider_2_h,'Value');
        set(Layer_numbers_2_previous_h,'UserData',str2double(get(Layer_numbers_2_h,'String')))
        Slider_3=get(Slider_3_h,'Value');
        
    otherwise
        error('Unsupported call value.')
        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% ADJUST PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Layer_numbers_1  =str2num(get(Layer_numbers_1_h,'String'));
Layer_numbers_2  =str2num(get(Layer_numbers_2_h,'String'));
thickness        =get(thickness_h,'Userdata');
refractive_index =get(refractive_index_h,'Userdata');
Display_1        =get(Display_1_h,'Value');
n_change         =get(n_change_h,'Value');
k_change         =get(k_change_h,'Value');

switch Sweep_Variable
    case 100
        lambda           =get(lambda_h,'Userdata');
        theta            =Slider_3;
        
    case 010
        lambda           =Slider_3;
        theta            =get(theta_h,'Userdata');
        
    case 001
        lambda           =get(lambda_h,'Userdata');
        theta            =Slider_3;
        
    otherwise
        error('Unsupported sweep variable.')
        
end

[temp_rows temp_layers]=size(thickness);
if any(Layer_numbers_1>temp_layers)||any(Layer_numbers_1-round(Layer_numbers_1))
    %    error('Invalid layer 1 number.')
end

if any(Layer_numbers_2>temp_layers)||any(Layer_numbers_2-round(Layer_numbers_2))
    error('Invalid layer 2 number.')
end

if strcmpi(User_selection,'biosensor')
    thickness_new=thickness;
    thickness_new(:,Layer_numbers_1)=thickness_new(:,Layer_numbers_1).*Slider_1;
    thickness_new(:,Layer_numbers_1+1)=thickness(:,Layer_numbers_1)-thickness_new(:,Layer_numbers_1);
else
    thickness_new=thickness;
    thickness_new(:,Layer_numbers_1)=thickness_new(:,Layer_numbers_1).*Slider_1;
end

refractive_index_new=refractive_index;
if n_change && k_change
    refractive_index_new(:,Layer_numbers_2)=refractive_index(:,Layer_numbers_2).*Slider_2;
elseif n_change
    refractive_index_new(:,Layer_numbers_2)=real(refractive_index(:,Layer_numbers_2)).*Slider_2+...
        i.*imag(refractive_index(:,Layer_numbers_2));
elseif k_change
    refractive_index_new(:,Layer_numbers_2)=real(refractive_index(:,Layer_numbers_2))+...
        i.*imag(refractive_index(:,Layer_numbers_2)).*Slider_2;
end

if Display_1
    for temp_i=1:length(Layer_numbers_1)
        disp(['Layer ',num2str(Layer_numbers_1(temp_i)),' Thickness = ',...
            num2str(thickness_new(1,Layer_numbers_1(temp_i))),' nm'])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% ADJUST PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Choice_Y=get(get(handle_fca,'YLabel'),'String');
Choice_X=get(get(handle_fca,'XLabel'),'String');

handle_sim=get(handle_fca,'Userdata');

Who_Called=get(CallBack_h,'Tag');
switch lower(Who_Called)
    case 'film'
        if strcmpi(User_selection,'specphoto')
            [RR,TT,PP,error_film_calculation] = spectral_filter(lambda,theta,thickness_new,...
                refractive_index_new,Layer,Sweep_Variable,Timedebug,Line_suppress);
        elseif strcmpi(User_selection,'textured')
            if Layer_numbers_1==1
                if 1==0
                    Textured_Angle=Slider_1;
                    disp(['Textured_Angle=',num2str(Textured_Angle)])
                    
                    T=3;
                    Tf=0.00*T;
                    Metal_Coverage=.04;
                elseif 1==1
                    T=Max_1;
                    Tf=Max_1-Slider_1;
                    %Tf=0.01*T;
                    disp(['T=',num2str(T),'  Tf=',num2str(Tf),' Flat=',num2str(Tf/T*100),'%  Text=',num2str((1-Tf/T)*100),'%'])
                    Textured_Angle=54.84;
                    Metal_Coverage=.04;
                else
                    Metal_Coverage=Slider_1/Max_1;
                    Non_Metal_Coverage=(Max_1-Slider_1)/Max_1;
                    disp(['Metal Coverage=',num2str(Metal_Coverage)])
                    T=3;
                    Tf=0.00*T;
                    Textured_Angle=54.84;
                end
            else
                T=3;
                Tf=0.00*T;
                Textured_Angle=54.84;
                Metal_Coverage=.038;
            end
            set(gca,'ylim',[0 .4])
            [RR_a,TT_a,PP_a,error_film_calculation] = film_calculation(lambda,theta,thickness_new,...
                refractive_index_new,Layer,Length,Sweep_Variable,Timedebug,Line_suppress,User_selection);
            
            [RR_b,TT_b,PP_b,error_film_calculation] = film_calculation(lambda,theta+Textured_Angle,thickness_new,...
                refractive_index_new,Layer,Length,Sweep_Variable,Timedebug,Line_suppress,User_selection);
            
            [RR_c,TT_c,PP_c,error_film_calculation] = film_calculation(lambda,180-3*Textured_Angle-theta,thickness_new,...
                refractive_index_new,Layer,Length,Sweep_Variable,Timedebug,Line_suppress,User_selection);
            
            if 1==0
                RR_metal_tmpAg=load('C:\Users\memsley117715\Documents\MATLAB\Reflectance Data\AgonSi-0degree_ref.txt');
                RR_metal_tmpAl=load('C:\Users\memsley117715\Documents\MATLAB\Reflectance Data\AlonSi-0degree_ref.txt');
                RR_metal_tmp=0.9.*RR_metal_tmpAg+0.1.*RR_metal_tmpAl;
                RR_metal(1,:)=lambda;
                RR_metal(2,:)=interp1(RR_metal_tmp(:,1),RR_metal_tmp(:,2),lambda,'linear');
                RR_metal(3,:)=interp1(RR_metal_tmp(:,1),RR_metal_tmp(:,3),lambda,'linear');
                
                Non_Metal_Coverage=1-Metal_Coverage;
                
                RR(1,:)=RR_a(1,:);
                RR(2,:)=Metal_Coverage.*(RR_metal(2,:)/2+RR_metal(3,:)/2)+...
                    Non_Metal_Coverage.*((Tf/T)*(RR_a(2,:)/2+RR_a(3,:)/2)+...
                    (1-Tf/T)*(RR_b(2,:).*RR_c(2,:)./2.+RR_b(3,:).*RR_c(3,:)./2));
                RR(3,:)=RR(2,:);

                TT(1,:)=TT_a(1,:);
                TT(2,:)=Metal_Coverage.*(0)+...
                    Non_Metal_Coverage.*((Tf/T)*(TT_a(2,:)/2+TT_a(3,:)/2)+(1-Tf/T)*(TT_b(2,:)/2+TT_b(3,:)/2+...
                    RR_b(2,:).*TT_c(2,:)./2.+RR_b(3,:).*TT_c(3,:)./2));
                TT(3,:)=TT(2,:);
            else
                RR(1,:)=RR_a(1,:);
                RR(2,:)=((Tf/T)*(RR_a(2,:)/2+RR_a(3,:)/2)+...
                    (1-Tf/T)*(RR_b(2,:).*RR_c(2,:)./2.+RR_b(3,:).*RR_c(3,:)./2));
                RR(3,:)=RR(2,:);
                
                TT(1,:)=TT_a(1,:);
                TT(2,:)=((Tf/T)*(TT_a(2,:)/2+TT_a(3,:)/2)+(1-Tf/T)*(TT_b(2,:)/2+TT_b(3,:)/2+...
                    RR_b(2,:).*TT_c(2,:)./2.+RR_b(3,:).*TT_c(3,:)./2));
                TT(3,:)=TT(2,:);
            end
            
            %
            % Longwavelength filter for inteference fringes lost by
            % spectral measurement
            %
            if 1==0
                ave_points_buffer=find(RR(1,:)>700 & RR(1,:)<900);
                ave_points_forfilter=find(RR(1,:)>700);
                
                filterlength=length(ave_points_forfilter)-length(ave_points_buffer);
                
                a_filt = 1;
                windowSize = round(filterlength/3);
                b_filt=ones(1,windowSize)/windowSize;
                
                RR_temp2=RR(2,ave_points_buffer);
                RR_temp3=RR(3,ave_points_buffer);
                
                RR(2,ave_points_forfilter)=filter(b_filt,a_filt,RR(2,ave_points_forfilter));
                RR(3,ave_points_forfilter)=filter(b_filt,a_filt,RR(3,ave_points_forfilter));
                
                RR(2,ave_points_buffer)=RR_temp2;
                RR(3,ave_points_buffer)=RR_temp3;
            end
            
            PP=PP_a;
        else
            [RR,TT,PP,error_film_calculation]=film_calculation(lambda,theta,thickness_new,...
                refractive_index_new,Layer,Length,Sweep_Variable,Timedebug,Line_suppress,User_selection);
        end
        
        R_TM=RR(2,:);
        R_TE=RR(3,:);
        T_TM=TT(2,:);
        T_TE=TT(3,:);
        P_TM=PP(2,:);
        P_TE=PP(3,:);
        
        if strcmpi(User_selection,'nonpolarized')
            R_TM=R_TM/2+R_TE/2;
            R_TE=R_TM;
        end
        
        switch Sweep_Variable
            case 100
                if strcmpi(User_selection,'biosensor')
                    %'LFOSR FilmCalc v',num2str(FVersion),
                    TitleString=['Incident Angle = ',...
                        num2str(theta),'\circ - Bio Layer = ',num2str(thickness_new(1,Layer_numbers_1+1)),' nm'];
                else
                    TitleString=['Incident Angle = ',...
                        num2str(theta),'\circ'];
                    
                end
                energy=1239.838034./lambda;
                
                switch Choice_Y
                    case 'Reflectance'
                        switch Choice_X
                            case '\lambda (nm)'
                                set(handle_sim(1),'xdata',lambda,'ydata',R_TM)
                                set(handle_sim(2),'xdata',lambda,'ydata',R_TE)
                            case '\lambda (\mum)'
                                set(handle_sim(1),'xdata',lambda./1000,'ydata',R_TM)
                                set(handle_sim(2),'xdata',lambda./1000,'ydata',R_TE)
                            case 'Energy (eV)'
                                set(handle_sim(1),'xdata',energy,'ydata',R_TM)
                                set(handle_sim(2),'xdata',energy,'ydata',R_TE)
                            otherwise
                                error('Unsupported X label.')
                        end
                        
                    case 'Transmittance'
                        switch Choice_X
                            case '\lambda (nm)'
                                set(handle_sim(1),'xdata',lambda,'ydata',T_TM)
                                set(handle_sim(2),'xdata',lambda,'ydata',T_TE)
                            case 'Energy (eV)'
                                set(handle_sim(1),'xdata',energy,'ydata',T_TM)
                                set(handle_sim(2),'xdata',energy,'ydata',T_TE)
                            otherwise
                                error('Unsupported X label.')
                        end
                        
                    case 'Phase'
                        switch Choice_X
                            case '\lambda (nm)'
                                set(handle_sim(1),'xdata',lambda,'ydata',P_TM)
                                set(handle_sim(2),'xdata',lambda,'ydata',P_TE)
                            case 'Energy (eV)'
                                set(handle_sim(1),'xdata',energy,'ydata',P_TM)
                                set(handle_sim(2),'xdata',energy,'ydata',P_TE)
                            otherwise
                                error('Unsupported X label.')
                        end
                        
                    otherwise
                        error('Unsupported Y label.')
                end
                
            case 010
                TitleString=['Incident Wavelength = ',...
                    num2str(lambda),'nm'];
                
                switch Choice_Y
                    case 'Reflectance'
                        set(handle_sim(1),'xdata',theta,'ydata',R_TM)
                        set(handle_sim(2),'xdata',theta,'ydata',R_TE)
                        
                    case 'Transmittance'
                        set(handle_sim(1),'xdata',theta,'ydata',T_TM)
                        set(handle_sim(2),'xdata',theta,'ydata',T_TE)
                        
                    case 'Phase'
                        set(handle_sim(1),'xdata',theta,'ydata',P_TM)
                        set(handle_sim(2),'xdata',theta,'ydata',P_TE)
                        
                    otherwise
                        error('Unsupported Y label.')
                end
                
            case 001
                active_thickness=RR(1,:);
                TitleString=['Incident Angle = ',...
                    num2str(theta),'\circ',' - Incident Wavelength = ',num2str(lambda),'nm'];
                
                switch Choice_Y
                    case 'Reflectance'
                        set(handle_sim(1),'xdata',active_thickness,'ydata',R_TM)
                        set(handle_sim(2),'xdata',active_thickness,'ydata',R_TE)
                        
                    case 'Transmittance'
                        set(handle_sim(1),'xdata',active_thickness,'ydata',T_TM)
                        set(handle_sim(2),'xdata',active_thickness,'ydata',T_TE)
                        
                    case 'Phase'
                        set(handle_sim(1),'xdata',active_thickness,'ydata',P_TM)
                        set(handle_sim(2),'xdata',active_thickness,'ydata',P_TE)
                        
                    otherwise
                        error('Unsupported Y label.')
                end
                
            otherwise
                error('Unsupported sweep variable.')
        end
        
    case 'detector'
        [QE,error_detector_calculation]=detector_calculation(lambda,theta,thickness_new,...
            refractive_index_new,Layer,Length,Sweep_Variable,Timedebug,Line_suppress);
        
        Thickness=thickness_new(1,Layer);
        
        QE_TM=QE(2,:);
        QE_TE=QE(3,:);
        h          =6.62617e-34;        %Planck constant [J.s]
        q          =1.60218e-19;        %Elementary charge [C]
        c          =2.998e8*1e9;        %Speed of Light in Vacuum [nm/s]
        
        RS_TM=QE_TM.*(q/h/c).*lambda';
        RS_TE=QE_TE.*(q/h/c).*lambda';
        
        if strcmpi(User_selection,'nonpolarized')
            QE_TM=QE_TM/2+QE_TE/2;
            QE_TE=QE_TM;
        end
        
        if strcmpi(User_selection,'solar')
            h    =6.62617e-34;   %Planck constant [J.s]
            c    =2.998e8;       %Speed of Light in Vacuum [m/s]
            q_e  =1.60218e-19;   %Elementary charge [C]
            T    =298;           %Temp [K]
            k_b  =1.38066e-23;   %Boltzmann constant [J/K]
            n_i  =1.01e10*100^3; %Intrinsic conc in Si [m^-3]
            N_a  =1e15*100^3;    %Source/Drain Doping [m^-3]
            
            load solarspectra.mat
            solarirradiance_int(:,1)=lambda;
            solarirradiance_int(:,2)=interp1(solarirradiance(:,1),solarirradiance(:,2),lambda,'nearest','extrap');
            
            QE_TM=solarirradiance_int(:,2)'.*QE_TM.*lambda'.*1e-9./h./c.*q_e; %A/m^2/nm
            QE_TE=solarirradiance_int(:,2)'.*QE_TE.*lambda'.*1e-9./h./c.*q_e; %A/m^2/nm
            integratedincidentpowerperunitarea=cumtrapz(solarirradiance(:,1),solarirradiance(:,2));
            totalincidientpowerperunitarea=integratedincidentpowerperunitarea(end);
            integratedpowerperunitarea_TE=cumtrapz(lambda,QE_TE);
            totalpowerperunitarea_TE=integratedpowerperunitarea_TE(end);
            integratedpowerperunitarea_TM=cumtrapz(lambda,QE_TM);
            totalpowerperunitarea_TM=integratedpowerperunitarea_TM(end);
            totalpowerperunitarea=totalpowerperunitarea_TE/2+totalpowerperunitarea_TM/2;
            
            V_oc=k_b*T/q_e*log((N_a+(totalpowerperunitarea./q_e))*totalpowerperunitarea./q_e/n_i^2);
            
            cellefficiency=(totalpowerperunitarea*V_oc)/totalincidientpowerperunitarea;
            
            disp(['Incident Power = ',num2str(totalincidientpowerperunitarea,4),' W/m^2 ',...
                'Power Generated = ',num2str(totalpowerperunitarea*V_oc,4),' W/m^2 ',...
                'V_oc = ',num2str(V_oc,4),' V ',...
                'J_sc = ',num2str(totalpowerperunitarea/10,4),' mA/cm^2 ',...
                'Efficiency = ',num2str(cellefficiency*100,4),' %'])
        end
        
        switch Sweep_Variable
            case 100
                %'LFOSR QECalc v',num2str(FVersion),
                TitleString=['Incident Angle = ',...
                    num2str(theta),'\circ - Active Layer = ',num2str(Thickness),' nm'];
                
                energy=1239.838034./lambda;
                
                switch Choice_Y
                    case 'Responsivity (A/W)'
                        switch Choice_X
                            case '\lambda (nm)'
                                set(handle_sim(1),'xdata',lambda,'ydata',RS_TM)
                                set(handle_sim(2),'xdata',lambda,'ydata',RS_TE)
                            case 'Energy (eV)'
                                set(handle_sim(1),'xdata',energy,'ydata',RS_TM)
                                set(handle_sim(2),'xdata',energy,'ydata',RS_TE)
                            otherwise
                                error('Unsupported X label.')
                        end
                        
                    case 'Quantum Efficiency'
                        switch Choice_X
                            case '\lambda (nm)'
                                set(handle_sim(1),'xdata',lambda,'ydata',QE_TM)
                                set(handle_sim(2),'xdata',lambda,'ydata',QE_TE)
                            case 'Energy (eV)'
                                set(handle_sim(1),'xdata',energy,'ydata',QE_TM)
                                set(handle_sim(2),'xdata',energy,'ydata',QE_TE)
                            otherwise
                                error('Unsupported X label.')
                        end
                    case 'Solar Irradiance Absorbed (A/m^2/nm)'
                        switch Choice_X
                            case '\lambda (nm)'
                                set(handle_sim(1),'xdata',lambda,'ydata',QE_TM)
                                set(handle_sim(2),'xdata',lambda,'ydata',QE_TE)
                            case 'Energy (eV)'
                                set(handle_sim(1),'xdata',energy,'ydata',QE_TM)
                                set(handle_sim(2),'xdata',energy,'ydata',QE_TE)
                            otherwise
                                error('Unsupported X label.')
                        end
                    otherwise
                        error('Unsupported Y label.')
                end
                
                
            case 010
                TitleString=['Incident Wavelength = ',...
                    num2str(lambda),'nm - Active Layer = ',num2str(Thickness),' nm'];
                
                switch Choice_Y
                    case 'Responsivity (A/W)'
                        set(handle_sim(1),'xdata',theta,'ydata',RS_TM)
                        set(handle_sim(2),'xdata',theta,'ydata',RS_TE)
                    case 'Quantum Efficiency'
                        set(handle_sim(1),'xdata',theta,'ydata',QE_TM)
                        set(handle_sim(2),'xdata',theta,'ydata',QE_TE)
                    otherwise
                        error('Unsupported Y label.')
                end
                
            case 001
                active_thickness=QE(1,:);
                TitleString=['Incident Angle = ',...
                    num2str(theta),'\circ',' - Incident Wavelength = ',num2str(lambda),'nm'];
                
                switch Choice_Y
                    case 'Responsivity (A/W)'
                        set(handle_sim(1),'xdata',active_thickness,'ydata',RS_TM)
                        set(handle_sim(2),'xdata',active_thickness,'ydata',RS_TE)
                    case 'Quantum Efficiency'
                        set(handle_sim(1),'xdata',active_thickness,'ydata',QE_TM)
                        set(handle_sim(2),'xdata',active_thickness,'ydata',QE_TE)
                    otherwise
                        error('Unsupported Y label.')
                end
                
            otherwise
                error('Unsupported sweep variable.')
        end
        
    otherwise
        error('Unsupported program call.')
end

set(handle_fca,'title',text(...
    'FontName',FontName,...
    'FontUnits',FontUnits,...
    'FontSize',BodyTextFontSize, ...
    'FontWeight',FontWeight,...
    'FontAngle',FontAngle,...
    'Color',OutputFigTextColor,...
    'String',TitleString))

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% END ADJUST PROGRAM OUTPUT %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
