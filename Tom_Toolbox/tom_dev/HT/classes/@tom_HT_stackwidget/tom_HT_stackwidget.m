function this = tom_HT_stackwidget(varargin)

this.rows = [];
this.cols = [];
this.figurehandle = [];
this.axeshandles = [];
this.imagehandles = [];
this.markhandles = [];
this.type = 'particles';
this.cbs = {};
this.leftcb = '';
this.slider = 0;
this.textbox = 0;
this.numpages = 1;

this = class(this,'tom_HT_stackwidget');