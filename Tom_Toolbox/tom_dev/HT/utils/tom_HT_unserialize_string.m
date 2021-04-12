function string_out = tom_HT_unserialize_string(string)


remain = string;
string_out = {};

if isempty(cell2mat(strfind(string, '^%^')))
    string_out = string;
    return;
end

l = 1;
while true
    [str, remain] = strtok(remain, '^%^');
    if isempty(str{1})
        break;  
    end
    if isempty(string_out)
        string_out{1} = str;
    else
        string_out{l} = str;
    end
    l = l+1;
end
