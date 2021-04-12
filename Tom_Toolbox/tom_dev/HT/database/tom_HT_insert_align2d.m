function tom_HT_insert_align2d(conn,align2d)





% result = fetch(conn,'DESCRIBE particles');
% colnames={result.Field};


colnames={'stacks_sid', 'micrographs_mid', 'ccc','pos_x', 'pos_y', 'angle', 'class', 'quality'};




%for i=1:length(align2d)

for i=1:1



    %vals={1,1,align2d(1,i).ccc,'NULL','NULL','NULL','NULL',align2d(1,i).position.x,align2d(1,i).position.y,align2d(1,i).angle,align2d(1,i).quality,'NULL'};
    %vals={1,1,align2d(1,i).ccc,align2d(1,i).position.x,align2d(1,i).position.y,1,align2d(1,i).class,align2d(1,i).quality};
    
   
    
    
    [al_cell filenames]=tom_HT_align2d2cell(align2d,[1,100]);
   
    for ii=1:length(filenames)
    
        curs=exec(conn,['select filename from micrographs where filename= ' '''' filenames{i} '''']); close(curs);
        %tmp=fetch(curs);
        if (curs.Data==0)
            tt{1}='filename';
            tt2{1}=filenames{ii};
            fastinsert(conn,'micrographs',tt,filenames{ii});
        end;
        curs=exec(conn,['select filename from micrographs where filename= ' '''' filenames{i} '''']); tmp_id{ii}=fetch(curs); close(curs);
        
    end;
    
    
    close(curs);
    fastinsert(conn,'particles', colnames, al_cell);
    
    
    %disp(num2str(i));
    
end;

