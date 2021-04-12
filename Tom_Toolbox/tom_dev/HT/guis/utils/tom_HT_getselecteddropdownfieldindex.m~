function [name,id] = tom_HT_getselecteddropdownfieldindex(hObject)

contents = get(hObject,'String');       
name = contents{get(hObject,'Value')};

userdata = get(hObject,'UserData');
if ~isempty(userdata)
    id = userdata(get(hObject,'Value'));
else
    id = [];
end