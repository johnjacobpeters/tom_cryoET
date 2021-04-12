function this = add_contextmenu(this,r,c)


if isempty(this.cbs)
    return;
end

cmenu = uicontextmenu;

switch this.type 

    case 'particles'
        uimenu(cmenu, 'Label', 'show info', 'Callback', this.cbs{1});
        uimenu(cmenu, 'Label', 'delete', 'Callback', this.cbs{2});
    
end

set(this.imagehandles(r,c),'UIContextMenu', cmenu);