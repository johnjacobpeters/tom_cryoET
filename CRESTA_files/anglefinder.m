vatpaseang=[];
list = dir ('/Volumes/Data_3/EM/Cryo/20190611_MPI/Etomo/Tomo*');

for j = 1:length(list)
test = fopen(strcat(list(j).folder, '/', list(j).name, '/', list(j).name, '.coords'));

if test>0
data=textscan(test,'%f%f%f%f');



endloop=max(data{1,1});

for i=1:endloop
   index=find(data{1,1}==i);
   tempmembrane = [data{1,2}(index(2)),data{1,3}(index(2)),data{1,4}(index(2))];
   tempcenter= [data{1,2}(index(3)),data{1,3}(index(3)),data{1,4}(index(3))]; 
   tempang = [];
   if length(index)>3
       vatpase1 = [data{1,2}(index(4)),data{1,3}(index(4)),data{1,4}(index(4))];
       mem2cen1 = tempmembrane - tempcenter;
       vatp2cen1 = vatpase1 - tempcenter;
       tempang(1) = rad2deg(acos(dot(mem2cen1, vatp2cen1)/(sum(mem2cen1.^2)^.5 * sum(vatp2cen1.^2)^.5)));
   end
   if length(index)>4
       vatpase2 = [data{1,2}(index(5)),data{1,3}(index(5)),data{1,4}(index(5))];
       mem2cen2 = tempmembrane - tempcenter;
       vatp2cen2 = vatpase2 - tempcenter;
       tempang(2) = rad2deg(acos(dot(mem2cen2, vatp2cen2)/(sum(mem2cen2.^2)^.5 * sum(vatp2cen2.^2)^.5)));
   end
   if length(index)>5
       vatpase3 = [data{1,2}(index(6)),data{1,3}(index(6)),data{1,4}(index(6))];
       mem2cen3 = tempmembrane - tempcenter;
       vatp2cen3 = vatpase3 - tempcenter;
       tempang(3) = rad2deg(acos(dot(mem2cen3, vatp2cen3)/(sum(mem2cen3.^2)^.5 * sum(vatp2cen3.^2)^.5)));
   end
   vatpaseang= [vatpaseang, tempang];
   end
  test=[]; 
end


end