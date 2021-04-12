function [data struct_fieldnames]=tom_HT_struct2cell(struct)

struct_fieldnames=fieldnames(struct);
data=squeeze(struct2cell(struct))';