function h = drawcross()


width = get(gca,'Xlim');
width = width(2);

length = width.*.8;
middle = width./2+1;
bottom = width.*.2;
h = line([middle length middle bottom middle length middle bottom],[middle bottom middle length middle length middle bottom],'LineWidth',2,'Color',[1 0 0]);

