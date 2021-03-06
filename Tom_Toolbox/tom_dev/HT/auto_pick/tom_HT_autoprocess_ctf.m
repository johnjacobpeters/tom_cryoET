function tom_HT_autoprocess_ctf(input_dir,min_freq,max_freq,enhance_filter_min,enhance_filter_max,enhance_weight,psdsize,masksize,masksize_outer,svmStruct,handles)

if nargin < 11
    handles = [];
end

if nargin < 10
    svmStruct = [];
    masksize = 0;
    masksize_outer = 0;
end

if nargin < 7
    psdsize = 256;
end

if nargin < 6
    enhance_weight = 5;
end

if nargin < 5
    enhance_filter_max = 0.2;
end

if nargin < 4
    enhance_filter_min = 0.02;
end

if nargin < 3
    max_freq = 0.2;
end

if nargin < 2
    min_freq = 0.02;
end

set(handles.listbox_messages,'String','','Value',1);

while 1

    if strcmp(get(handles.text_fitstatus,'String'),'stopping...') == 1
        set(handles.text_fitstatus,'String','stopped','ForegroundColor',[1 0 0]);
        break;
    end
    
    try
        dircell = tom_HT_getdircontents([input_dir '/high'],{'em'},false);
    catch
        dircell = {};
    end
    
    if ~isempty(dircell)
        tic;
        [path,filename] = fileparts(dircell{1});
        
        if ~isempty(handles)
            handles = update_listbox(handles,['Found new file: ' filename '.em']);
        else
            disp(['Found new file: ' filename '.em']);
        end
        
        header = tom_emreadc([input_dir '/high/' filename '.em']);
        if ~isempty(handles)
            set(gcf,'CurrentAxes',handles.axes_micrograph);
            imagesc(header.Value');axis ij;colormap gray;axis off;
            drawnow;
        end
        ps = tom_calc_periodogram(header.Value,psdsize);
        if ~isempty(handles)
            set(gcf,'CurrentAxes',handles.axes_psd);
            cla;
            ps_enhanced = tom_xmipp_psd_enhance(ps,true,true,enhance_filter_min,enhance_filter_max,enhance_weight,enhance_filter_min,enhance_filter_max);
            imagesc(ps_enhanced');axis ij;colormap gray;axis off;
            drawnow;
        end
            
        if ~isempty(svmStruct)
            result = tom_HT_classifyctfs(fftshift(log(ps)),masksize,masksize_outer,svmStruct);
        else
            if ~isempty(handles)
                handles = update_listbox(handles,'SVM support deactivated.');
            else
                disp('SVM support deactivated.');
            end
            
            result = 1;
        end

        if result == 1
            if ~isempty(handles)
                handles = update_listbox(handles,'File is suitable for CTF fitting');
            else
                disp('File is suitable for CTF fitting');
            end
            Dz = header.Header.Defocus;
            voltage = header.Header.Voltage./1000;
            objectpixelsize = header.Header.Objectpixelsize;
            Cs = header.Header.Cs;
            Ca = 2;
            ctfmodelsize = psdsize;

            epsilon = 0;
            method = 'leave';

            ctfmodel = tom_xmipp_adjust_ctf(ps,Dz,voltage,objectpixelsize,ctfmodelsize,Cs,min_freq,max_freq,Ca,enhance_filter_min,enhance_filter_max,enhance_weight);
            
            for i=1:5
                line(ctfmodel.zeros(1,:,i),ctfmodel.zeros(2,:,i),'Color',[1 0 0]);
            end
            drawnow;
            header.Value = tom_xmipp_ctf_correct_phase(header.Value,ctfmodel,method,epsilon);
            tom_emwrite([input_dir '/corr/' filename '.em'],header);
            tom_emwrite([input_dir '/high_orig/' filename '.em'],header);
            save([input_dir '/ctfmodels/' filename '_ctfmodel.mat'],'ctfmodel');
            delete([input_dir '/high/' dircell{1}]);
            %delete([input_dir '/high/' filename '.crc']);
            if ~isempty(handles)
                handles = update_listbox(handles,['DzU: ' num2str(ctfmodel.DeltafU) ', DzV: ' num2str(ctfmodel.DeltafV) ', Angle: ' num2str(ctfmodel.AzimuthalAngle)]);
                handles = update_listbox(handles,['Fitting time: ' num2str(toc) ' seconds']);
                handles = update_listbox(handles,'-----------------------------------------------------------------');
            else
                disp(['DzU: ' num2str(ctfmodel.DeltafU) ', DzV: ' num2str(ctfmodel.DeltafV) ', Angle: ' num2str(ctfmodel.AzimuthalAngle)]);
                disp(['Fitting time: ' num2str(toc) ' seconds']);
                disp('-----------------------------------------------------------------');
            end
        else
            if ~isempty(handles)
                handles = update_listbox(handles,'File is not suitable for CTF fitting.');
            else
                disp('File is not suitable for CTF fitting.');
            end
        end
        
    else
        pause(1);
    end
end

function handles = update_listbox(handles,string)

string_old = get(handles.listbox_messages,'String');
string_old{end+1} = string;
set(handles.listbox_messages,'String',string_old,'Value',size(string_old,1));
drawnow;
