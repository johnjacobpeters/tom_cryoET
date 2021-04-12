function this = add_maskparams(this,type,varargin)

if isempty(fieldnames(this.params)) == true
    idx = 1;
else
    idx = size(this.params,2)+1;
end

switch lower(type)
    case 'circle'
        params = [varargin{1},varargin{2},varargin{3},varargin{4}];
    case 'rectangle'
        params = [varargin{1},varargin{2},varargin{3},varargin{4}];
    case 'polygon'
    case 'freehand'
        params = varargin{1};
    case 'magic wand'
        params = {varargin{1},varargin{2},varargin{3},varargin{4},varargin{5}};
    case 'gaussian'
        params = {varargin{1},varargin{2},varargin{3}};
    case 'raised_cosine'
        params = {varargin{1},varargin{2},varargin{3},varargin{4}};
end

this.params(idx).vals = params;
this.params(idx).name = type;