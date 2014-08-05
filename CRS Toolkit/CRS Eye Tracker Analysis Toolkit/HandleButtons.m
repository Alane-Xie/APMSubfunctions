function HandleButtons(handle,eventStruct)

% handle radio button presses when showing a sequence chart

global classAs;
global f;
name=get(eventStruct.NewValue,'String');
classAs=name(1);
if (ishandle(f))
    uiresume(f);
end
    
end