function lfosr_guivalues(CallBack_figure,CallBack_h,Handles)

Lambda            =Handles(1);
Theta             =Handles(2);
A_Length          =Handles(3);
Start             =Handles(4);
Stop              =Handles(5);
Angle             =Handles(6);
Wavelength        =Handles(7);
Layer             =Handles(8);
Length            =Handles(9);
Percentage_Length =Handles(10);

Program_call=get(CallBack_figure,'Tag');

%Values
who_called=(([Lambda Theta A_Length]-CallBack_h)==0);
who_called=who_called(1)*1e2+who_called(2)*1e1+who_called(3)*1e0;

switch who_called
    case 100  %lambda callback
        Start_default=Handles(11);
        Stop_default=Handles(12);
        if get(Lambda,'Value')
            set(Theta,'Value',0)
            set(A_Length,'Value',0)
        else
            set(Lambda,'Value',1)
        end
        if get(Lambda,'Value')
            set(Start,'String',Start_default)
            set(Stop,'String',Stop_default)
            set(Angle,'Enable','on')
            set(Wavelength,'Enable','off')
            switch Program_call
                case 'FILM'
                    set(Layer,'Enable','off')
                case 'DETECTOR'
                    set(Layer,'Enable','on')
                    set(Length,'Enable','off')
                    set(Percentage_Length,'Enable','off')
                    set(Percentage_Length,'Value',0)
            end
        end
    case 010 %theta callback
        Start_default=Handles(13);
        Stop_default=Handles(14);
        if get(Theta,'Value')
            set(Lambda,'Value',0)
            set(A_Length,'Value',0)
        else
            set(Theta,'Value',1)
        end
        if get(Theta,'Value')
            set(Start,'String',Start_default)
            set(Stop,'String',Stop_default)
            set(Angle,'Enable','off')
            set(Wavelength,'Enable','on')
            switch Program_call
                case 'FILM'
                    set(Layer,'Enable','off')
                case 'DETECTOR'
                    set(Layer,'Enable','on')
                    set(Length,'Enable','off')
                    set(Percentage_Length,'Enable','off')
                    set(Percentage_Length,'Value',0)
            end
        end
    case 001 %layer callback
        Start_default=Handles(15);
        Stop_default=Handles(16);
        if get(A_Length,'Value')
            set(Lambda,'Value',0)
            set(Theta,'Value',0)
        else
            set(A_Length,'Value',1)
        end
        if get(A_Length,'Value')
            set(Start,'String',Start_default)
            set(Stop,'String',Stop_default)
            set(Angle,'Enable','on')
            set(Wavelength,'Enable','on')
            set(Layer,'Enable','on')
            set(Length,'Enable','on')
            set(Percentage_Length,'Enable','on')
        end
    otherwise
        error('Unsupported sweep variable.')
end
return



