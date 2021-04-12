function text_out = tom_HT_formattextfield(textstruct)


height = 9;

col = 1;

for i=1:size(textstruct,2)
   
    textstruct(i).col = col;
    if mod(i,height) == 0 && i<size(textstruct,2)
        col = col+1;
    end
    if ~ischar(textstruct(i).value)
        textstruct(i).value = num2str(textstruct(i).value);
    end
    textstruct(i).size = size(textstruct(i).name,2) + 2 + size(textstruct(i).value,2) + 3;

end

coltext=cell(height,col);

for i=size(textstruct,2)+1:(height*col)
    textstruct(i).name = ' ';
    textstruct(i).value = ' ';
    textstruct(i).size = 7;
    textstruct(i).col = col;
end

for i=1:col
    idx = find([textstruct.col]==i);
    colstruct = textstruct(idx);
    collength = max([colstruct.size]);
    for j=1:size(colstruct,2)
        if strcmp(colstruct(j).name, ' ')
            t = ' ';
        else
            t = [colstruct(j).name ': ' colstruct(j).value ];
        end
        coltext{j,i} = [sprintf(['%-' int2str(collength) 's'],t) ' | '];
    end
end

text_out = cell2mat(coltext);