function string_out = tom_HT_serialize_string(string)

string_out = '';
for i=1:size(string,1)
    if i > 1
        string_out = [string_out '^%^' deblank(string(i,:))]; 
    else
        string_out = string(i,:);
    end
end