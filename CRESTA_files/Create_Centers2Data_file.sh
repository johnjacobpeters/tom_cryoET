#!/bin/bash

star="$1"
CoordDir="$2"
Dir="$3"
Suffix="$4"
CRESTA_DIR="$5"
bin="$6"
cmm_directory="$7"


if [[ $Dir == */ ]];
then
	UseDir=${Dir%/};
	echo $UseDir
else
	UseDir=$Dir;
	echo $UseDir
fi

if [[ $CoordDir == */ ]];
then
	CoordDir=${CoordDir%/};
fi

if [[ $cmm_directory == */ ]];
then
	cmm_directory=${cmm_directory%/};
fi
if [ ! -d $UseDir ];
then
	mkdir $UseDir;
if [ ! -d $UseDir/temp ];
then
	mkdir $UseDir/temp;
fi	
fi

##This gets the positions of micrograph name, and original x y and z coordinates from the star file
NamePos=$(grep "_rlnImageName" $star | cut -d '#' -f 2);
InterfaceXPos=$(grep "_rlnCoordinateX" $star | cut -d '#' -f 2 );
InterfaceYPos=$(grep "_rlnCoordinateY" $star | cut -d '#' -f 2 );
InterfaceZPos=$(grep "_rlnCoordinateZ" $star | cut -d '#' -f 2 );
echo 'got positions'

##All of this just computes how many interfaces there are by counting the lines with any header(s) removed and new file "decapitated.txt" created
width=$(awk '{print NF}' $star | sort -nu | tail -n 1 );
cat $star | awk -v width=$width '{print $width}' > $UseDir/temp/length.txt;
decap=$(grep -cv '\S' $UseDir/temp/length.txt);
TotalLength=$(cat $UseDir/temp/length.txt | wc -l);
UseLines="$(($TotalLength-$decap))";
tail -n $UseLines $star > $UseDir/temp/decapitated.txt;
echo "made decapitated and length"


##This part needs to go find the corresponding other coords files and input them accordingly...
##First check that the _rlnImageName closely matches the coordinate either bin1 or 4
length=$(($(cat $UseDir/temp/decapitated.txt | wc -l)+1));
for i in $(seq 1 $length );
do
	 InterfaceNum=$(cat $UseDir/temp/decapitated.txt | awk -v NamePos=$NamePos '{print $NamePos}' | sed "${i}q;d" | xargs basename | sed 's/_filt.mrc//');
	 Inter=$((10#${InterfaceNum: -3}));
	 TomoNum=${InterfaceNum:0:3};
	 sed "${Inter}q;d" $CoordDir/$TomoNum*$Suffix | perl -pe 's/\b(\d+\.)?\d+\b/$&*'$bin'/ge' >> $UseDir/temp/"All_bin1.coords"$Suffix;
 done
 wait
##This part creates the first four lines of the python_transform input file
Names=$(awk -v NamePos=$NamePos '{print $NamePos}' $UseDir/temp/decapitated.txt);
InterXPos=$(awk -v InterfaceXPos=$InterfaceXPos '{print $InterfaceXPos}' $UseDir/temp/decapitated.txt);
InterYPos=$(awk -v InterfaceYPos=$InterfaceYPos '{print $InterfaceYPos}' $UseDir/temp/decapitated.txt);
InterZPos=$(awk -v InterfaceZPos=$InterfaceZPos '{print $InterfaceZPos}' $UseDir/temp/decapitated.txt);
CXpos=$(awk '{print $1}' $UseDir/temp/"All_bin1.coords"$Suffix);
CYpos=$(awk '{print $2}' $UseDir/temp/"All_bin1.coords"$Suffix);
CZpos=$(awk '{print $3}' $UseDir/temp/"All_bin1.coords"$Suffix);
paste -d, <(echo "$Names") <(echo "$InterXPos") <(echo "$InterYPos") <(echo "$InterZPos") <(echo "$CXpos") <(echo "$CYpos") <(echo "$CZpos")> $UseDir/centers2data.csv;

##Removes temp folder...comment out to debug



echo "All done! Output file is in" $UseDir"/centers2data.csv" 
echo "Starting python transform"

if [[ $CRESTA_DIR == */ ]];
then
	CRESTA_DIR=${CRESTA_DIR%/};
else
	CRESTA_DIR=$CRESTA_DIR;
fi

##Runs the python script
##/Users/leitzj/anaconda3/bin/python3 -m pip list
/Users/leitzj/anaconda3/bin/python3 $CRESTA_DIR/transform_project_JL.py calcangles --csv $UseDir/centers2data.csv --outdir $UseDir;
wait
sed 's/nan/0/g' $UseDir/neweulerangs.csv > $UseDir/temp/neweulerangs_nonan.csv;
RoundX=$(awk '{print $1}' $UseDir/temp/newEulerangs_nonan.csv | cut -d',' -f1 | awk '{printf "%.2f\n", $1}');
RoundY=$(awk '{print $1}' $UseDir/temp/newEulerangs_nonan.csv | cut -d',' -f2 | awk '{printf "%.2f\n", $1}');
RoundZ=$(awk '{print $1}' $UseDir/temp/newEulerangs_nonan.csv | cut -d',' -f3 | awk '{printf "%.2f\n", $1}');
Name=$(awk '{print $1}' $UseDir/centers2data.csv | cut -d',' -f1);

paste -d, <(echo "$RoundX") <(echo "$RoundY") <(echo "$RoundZ") <(echo "$Name") > $UseDir/temp/neweulerangs_round.csv;

echo "Done created file neweulaerangs.csv in " $UseDir
echo "Creating new starfiles..."

echo "using star file in "$star ", and cmm_folder "$cmm_directory




##Maybe edit this part out
if $(grep -q "data_optics" $star)
then
	Header=$(awk '/data_particles/{ print NR; exit }' $star)
	Firstheader=$((Header - 1))
	sed -e '1,'$Firstheader'd' $star > $UseDir/temp/Star_no_hat.txt
else 
	$star > $UseDir/temp/Star_no_hat.txt
fi
CoordshiftedXcol=$(grep "_rlnCoordinateX" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2)
CoordshiftedYcol=$(grep "_rlnCoordinateY" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2)
CoordshiftedZcol=$(grep "_rlnCoordinateZ" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2)
ImageNamecol=$(grep "_rlnImageName" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2)
MicrographNamecol=$(grep "_rlnMicrographName" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2)
OpticsGroupcol=$(grep "_rlnOpticsGroup" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2)
GroupNocol=$(grep "_rlnGroupNumber" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2);
AngleRotcol=$(grep "_rlnAngleRot" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2)
AngleTiltcol=$(grep "_rlnAngleTilt" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2)
AnglePsicol=$(grep "_rlnAnglePsi" $UseDir/temp/Star_no_hat.txt | cut -d '#' -f 2)

head -n$decap $star > $UseDir/temp/subpartheader.star;
cp $UseDir/temp/subpartheader.star $UseDir/NewStar.star


##This combines the coorshift file with the corresponding names of the tomograms in that file.  Then it expands those names so that each is unique.  The expansion goes for eg. from T0200002_filt.cmm to T0200002_01_filt.cmm and gives them a sequentially increasing number.  Note: this differs from previous manual creation where the individual points were given alphabetical names, eg T0200002a. 

for AllTomo in $cmm_directory/*/;
do
	Tomo=$(basename $AllTomo);
	paste -d$'\t' $cmm_directory/$Tomo/*.coordsshift $cmm_directory/$Tomo/temp/NameCoord.txt  > $UseDir/temp/$Tomo".shift";
	#Checks to make sure the files we're about to build don't already exist.
	if [ -f $UseDir/temp/$Tomo"_microname.txt" ];
	then
		rm $UseDir/temp/$Tomo"_microname.txt";
	fi	
	if [ -f $UseDir/temp/$Tomo"_expanded.txt" ];
	then
		rm $UseDir/temp/$Tomo"_expanded.txt";
	fi	
	
	for particle in $(awk '{print $4}' $UseDir/temp/$Tomo".shift" | uniq);
		do 
			base=$(basename $particle)
			repeat=$(grep $particle $UseDir/temp/$Tomo".shift" | wc -l)
			for i in $(seq -f "%02g" 1 $repeat)
				do
					grep $particle $UseDir/temp/$Tomo".shift" | sed -n "${i}p" | sed "s/filt.cmm/${i}_filt.mrc/" >> $UseDir/temp/$Tomo"_expanded.txt"
			done
	done
	## Next we use this expanded file to generate a file containing the micrograph name so that the files are the same size.  This produces Tomo#_microname.txt.
			for subpart in $(awk '{print $4}' $UseDir/temp/$Tomo"_expanded.txt");
				do
					BaseA=$(basename $subpart "_filt.mrc");
					basemrc=${BaseA::${#BaseA}-3};
					grep $basemrc $star | cut -d$'\t' -f $MicrographNamecol >> $UseDir/temp/$Tomo"_microname.txt";
					grep $basemrc $star | cut -d$'\t' -f $OpticsGroupcol >> $UseDir/temp/$Tomo"OpticsGroup.txt";
					grep $basemrc $UseDir/temp/neweulerangs_round.csv | cut -d',' -f1 >> $UseDir/temp/$Tomo"_Rot";
					grep $basemrc $UseDir/temp/neweulerangs_round.csv | cut -d',' -f2 >> $UseDir/temp/$Tomo"_Tilt";
					grep $basemrc $UseDir/temp/neweulerangs_round.csv | cut -d',' -f3 >> $UseDir/temp/$Tomo"_Psi";
			done
			##Finally we put it all together and create a "NewStar.star" file in the working directory.  Additionally, all of these intermediate files are stored in each cmm file folder as well as a working direcotry temp folder. 
		paste -d$'\t' $UseDir/temp/$Tomo"_expanded.txt" $UseDir/temp/$Tomo"_microname.txt" $UseDir/temp/$Tomo"OpticsGroup.txt" $UseDir/temp/$Tomo"_Rot" $UseDir/temp/$Tomo"_Tilt" $UseDir/temp/$Tomo"_Psi" > $UseDir/temp/$Tomo"_Newstar.star"; 
		cat $UseDir/temp/$Tomo"_Newstar.star" >> $UseDir/NewStar.star
done

echo "All done, boss!"

#Uncomment the following line once confirmed to be working.
#rm -r $UseDir/temp/






	 
	 
	 



