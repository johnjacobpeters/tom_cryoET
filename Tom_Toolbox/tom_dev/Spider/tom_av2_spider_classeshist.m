function n = tom_av2_spider_classeshist(paramsfile)


A = importdata(paramsfile);

numclasses = max(A.data(:,6));


n = histc(A.data(:,6),1:numclasses);

