#!/bin/bash

DIR="$1"
BoxSize="$2"
PixelSize="$3"
StarFileDir="$4"

BoxSize=$(($BoxSize/2));

##if [ ! -d $DIR/temp ]; then mkdir $DIR/temp; OUT=$DIR/temp; else OUT=$DIR/temp; fi;

##Loops through input directory and generates a document containing all of the Tomogram Names
if [[ $DIR == */ ]];
then
	DIR=${DIR%/};
fi

if [ -f $DIR/TomoName.txt ];
then
	rm $DIR/TomoName.txt;
fi	

if ls $DIR/*.cmm &> /dev/null;
then
	echo "processing files in" $DIR
else
	echo "No files in:" $DIR
fi

for file in $DIR/*.cmm;
do
	echo ${file%[0-9][0-9][0-9][0-9][0-9][0-9]*} | xargs -I{} basename {} >> $DIR/TomoName.txt;
done
	
##makes directory for each unique tomogram
sort $DIR/TomoName.txt | uniq | xargs -I{} mkdir $DIR/{}; 

##Move cmm files into Tomogram-specific directories
for d in $DIR/*/;
do
	Tomo=${d%/};
	scp $Tomo*.cmm $d; ##Move the .cmm into new folder
	
	if [ ! -d $Tomo/temp ]; then mkdir $Tomo/temp; OUT=$Tomo/temp; else OUT=$Tomo/temp; fi;
	
	for file in $Tomo/*.cmm; ##For each .cmm in the new folder
	do
			length=$(grep x $file | awk -Fx= '{print $2}' | awk -F" " '{print $1}' | awk -F'"' '{print $2}' | wc -l);
				for i in $( seq 1 $length);
				do
					echo $file >> "$OUT/NameCoord.txt";
				done
	grep x $file | awk -Fx= '{print $2}' | awk -F" " '{print $1}' | awk -F'"' '{print $2}' | awk -v BoxSize=$BoxSize '{print $0-BoxSize}' | awk '{$0=$0 * -1} 1' | awk '{ printf("%.0f\n", $0); }' >> "$OUT/XCoord.txt";
	grep x $file | awk -Fy= '{print $2}' | awk -F" " '{print $1}' | awk -F'"' '{print $2}' | awk -v BoxSize=$BoxSize '{print $0-BoxSize}' | awk '{$0=$0 * -1} 1' | awk '{ printf("%.0f\n", $0); }' >> "$OUT/YCoord.txt";
	grep x $file | awk -Fz= '{print $2}' | awk -F" " '{print $1}' | awk -F'"' '{print $2}' | awk -v BoxSize=$BoxSize '{print $0-BoxSize}' | awk '{$0=$0 * -1} 1' | awk '{ printf("%.0f\n", $0); }' >> "$OUT/ZCoord.txt";
	done



paste -d " " $OUT/XCoord.txt $OUT/YCoord.txt $OUT/ZCoord.txt > $OUT/Together.txt;


##awk -v BoxSize=$BoxSize '{for(i=1;i<=NF;i++){$(i)=$(i)-BoxSize;}print;}' $OUT/Together.txt | column -t > $OUT/Together_Cor.txt;
##awk '{$0=$0 * -1;} 1;' $OUT/Together_Cor_neg.txt; ##With this line it is = 128-coord without this it would be coord-128
##awk -v PixelSize=$PixelSize '{for(i=1;i<=NF;i++){$(i)=$(i)*PixelSize;}print;}' $OUT/Together_Cor.txt;
##cp $OUT/Together_Cor.txt $OUT/Together_Cor_Round.txt;
##perl -i -pe 's/(\d*\.\d*)/int($1+0.5)/ge;' $OUT/Together_Cor_Round.txt;

##USE: a=$( grepv '_rlnCoordinateX' /Volumes/atbimac23/20210403MPI/NovaLink/cmm_files/20210304_pickerfilt_new.star | cut -d "#" -f 2)

Xcor=$( grep '_rlnCoordinateX' $StarFileDir | cut -d "#" -f 2);
Ycor=$( grep '_rlnCoordinateY' $StarFileDir | cut -d "#" -f 2);
Zcor=$( grep '_rlnCoordinateZ' $StarFileDir | cut -d "#" -f 2);



if grep -q filt $OUT/NameCoord.txt;
then 
	length=$(cat $OUT/NameCoord.txt | wc -l);
	for i in $(seq 1 $length );
		do
		sed "${i}q;d" $OUT/NameCoord.txt | xargs -I{} basename {} _filt.cmm | xargs -I{} grep {} $StarFileDir | awk -v X=$Xcor -v Y=$Ycor -v Z=$Zcor -F" " '{print $X, $Y, $Z}' >> $OUT/Orig_coord.txt
			##elif [ "$a" -eq 2 ]
			##then
		##sed "${i}q;d" $OUT/NameCoord.txt | xargs -I{} basename {} _filt.cmm | xargs -I{} grep {} $StarFileDir | awk -v X=$Xcor -v Y=$Ycor -v Z=$Zcor -F" " '{print $X, $Y, $Z}' >> $OUT/Orig_coord.txt;
			##fi
	done
else
	length=$(cat $OUT/NameCoord.txt | wc -l);
	for i in $(seq 1 $length );
		do
		sed "${i}q;d" $OUT/NameCoord.txt | xargs -I{} basename {} .cmm | xargs -I{} grep {} $StarFileDir | awk -v X=$Xcor -v Y=$Ycor -v Z=$Zcor -F" " '{print $X, $Y, $Z}' < /dev/null >> $OUT/Orig_coord.txt;
	done
fi
#paste $OUT/Orig_coord.txt $OUT/Together_Cor_Round.txt | awk '{ print ($1-$4), ($2-$5), ($3-$6) }' >> $OUT/Shifted_Coords.txt;

Name=$(basename $Tomo);

##paste $OUT/Orig_coord.txt $OUT/Together_Cor_Round.txt | awk '{ print ($1-$4), ($2-$5), ($3-$6) }' >> $Tomo/$Name".coordsshift";
paste $OUT/Orig_coord.txt $OUT/Together.txt | awk '{ print ($1-$4), ($2-$5), ($3-$6) }' >> $Tomo/$Name".coordsshift";

#paste -d " " $OUT/Shifted_Coords.txt $OUT/NameCoord.txt > $Tomo/$Name".coordsshift";

echo "All Done" $Name
echo $StarFileDir

done
##rm -r $OUT/temp

##Each one in its own Tomogram folder


echo "Finshed"


