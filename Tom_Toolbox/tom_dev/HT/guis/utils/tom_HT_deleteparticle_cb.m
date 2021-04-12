function tom_HT_deleteparticle_cb(hObject)

handles = guidata(hObject);

handles.particlestack = deleteparticle(handles.particlestack,get(gca,'UserData'));
gla;

guidata(hObject, handles);