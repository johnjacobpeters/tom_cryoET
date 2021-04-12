function tom_HT_particle_info_cb(hObject)

handles = guidata(hObject);

info = getinfo(handles.particlestack,get(gca,'UserData'));

string{1} = ['particle index: ' num2str(info.idx)];
string{2} = ['particle id: ' num2str(info.particleid)];
string{3} = ['micrograph id: ' num2str(info.micrographid)];
string{4} = ['position: x ' num2str(info.position.x) ', y ' num2str(info.position.y)];
string{5} = ['stack id: ' num2str(info.stackid)];

helpdlg(string,'Particle info');
%guidata(hObject, handles);
