#Author: jggatter@mit.edu

present=$(pwd) 	#Store pwd for later creation of .csv files

cd $1 		  	#Feed the parent folder (ex: KP1212_UVC) as the argument
directories=(*)	#Directories are all directories within the parent folder

if [ $# -lt 1 ] || [ $# -gt 3 ]; then	#Ensures the parent folder directory was specified.
	echo "Please rerun the script entering the directory of the parent folder directory as the 1st argument and start and end cut offs as the optional 2nd and 3rd arguments."
	echo "The start cut off will not count N's until after the first start_cut_off # of characters and will stop counting before the last end_cut_off # of characters."
	echo "The necessary folder hierachy is [Parent folder]/[sample group folders]/[unzipped folder containing .seq files]/[.seq files]"
	echo "The script does not check that your hierachy is correct"
	echo "For example, a folder KP1212_UVC contains all sample group folders, making it the parent folder."
	echo "If KP1212_UVC is on the Desktop, the bash command to run the program should look as follows:"
	echo "./Ncount.sh ~/Desktop/KP1212_UVC"
	echo "If you wish to ignore N's before the first 10 characters and the after the last 10 characters:"
	echo "./Ncount.sh ~/Desktop/KP1212_UVC 10 10"
	exit 1
fi

start_cut_off=0
end_cut_off=0
if [ $# -gt 1 ]; then
	start_cut_off=$2
	if [ $# -eq 3 ]; then
		end_cut_off=$3
	fi
fi

for i in ${directories[@]}; do
	
	cd $present
	if [ -f N$i.csv ]; then
		echo "	Previously existing N$i.csv file found. Removing and replacing..."
		rm ./N$i.csv
	fi

	cd $1/$i #Go into sample group directory
	
	folders=(*)		#Store all directories within this directory in order to find the folder containing .seq files.
	booleanbob=0 	#Our good friend booleanbob will confirm whether or not we find the folder that contains "seq" but not "zip"
	for h in ${folders[@]}; do
		
		if [[ $h = *"seq"* && $h != *"zip"* ]]; then
			echo "Found seq folder $h within $i"
			cd $1/$i/$h 	#Enter the folder containing .seq files
			booleanbob=1    #booleanbob has good news that the folder containing .seq files was indeed found!
		fi

	done
	if [ $booleanbob -eq 0 ]; then		#booleanbob has bad news that he couldn't find the folder then he continues to the next directory in the parent folder.
		echo "ERROR: No seq folder detected in $i!"
		continue
	fi

	samples=(*.seq)		#All .seq files are stored in an array for traversing
	echo "	Reading .seq files and counting characters..."
	for j in ${samples[@]}; do 		#For each .seq file, all charcounts per line (${#line}) after the first line are summed

		if [ -f N$i.csv ]; then
			$present/Ncount.py $j $i a $start_cut_off $end_cut_off #Arguments are: .seq file directory, sample group directory, append/write flag, start cut off, end cut off
		else
			$present/Ncount.py $j $i w $start_cut_off $end_cut_off #Arguments are: .seq file directory, sample group directory, append/write flag, start cut off, end cut off
		fi
	
	done
	
	echo "	CSV file N$i.csv has been completed and moved to $present."
	mv ./N$i.csv $present

done

echo "Program complete!"