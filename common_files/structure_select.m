function structure_select(CallBack_h,Handles)

default=Handles(1);
no_default=Handles(2);
Path=Handles(3);
Edit_structure=Handles(4);

who_called=(([default no_default Path Edit_structure]-CallBack_h)==0);
who_called=who_called(1)*1e3+who_called(2)*1e2+who_called(3)*1e1+who_called(4)*1e0;

switch who_called
case 1000 %default
      set(no_default,'Value',0)
      set(Path,'String','structure.txt')
      set(default,'Value',1)
   
case 0100 %non default
   is_default_selected = get(no_default,'Value');
   %
   % This is only performed to make the button press look consistent with 
   %  radio button operation.  Has no effect on actual outcome.
   %
   set(default,'Value',0)
   set(no_default,'Value',1)
   
   %
   % Look up structure file dialog box
   %
   [fname,pname]=uigetfile('*.txt','Layer Structure File');
   
   if fname==0
      testf=1;
   else
      testf=0;
   end
   
   if pname==0
      testp=1;
   else
      testp=0;
   end
   
   if testf==1|testp==1
      set(default,'Value',is_default_selected)
      set(no_default,'Value',~is_default_selected)
   else
      set(default,'Value',0)
      set(no_default,'Value',1)
      set(Path,'String',fullfile(pname,fname))
   end
   
case 0010 %Path
   set(default,'Value',0)
   set(no_default,'Value',1)
   
case 0001
   edit(get(Path,'String'))
   
otherwise
   error('Unsupported path selection call.')
   
end

   
