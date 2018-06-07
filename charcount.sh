#Author: jggatter@mit.edu
present=$(pwd) 	#Store pwd for later creation of .csv files
cd $1 		  	#Feed the parent folder (ex: KP1212_UVC) as the argument
directories=(*)	#Directories are all directories within the parent folder

if [ $# -ne 1 ]; then	#Ensures the parent folder directory was specified.
	echo "Please rerun the script entering the directory of the parent folder directory as the sole argument."
	echo "The necessary folder hierachy is [Parent folder]/[sample group folders]/[unzipped folder containing .seq files]/[.seq files]"
	echo "The script does not check that your hierachy is correct"
	echo "For example, a folder KP1212_UVC contains all sample group folders, making it the parent folder."
	echo "If KP1212_UVC is on the Desktop, the bash command to run the program should look as follows:"
	echo "./charcount.sh ~/Desktop/KP1212_UVC"
	exit 1
fi

for i in ${directories[@]}; do
	
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
	printf "Sample,CharCount\n" >> $present/$i.csv #The .csv file is created in the directory where this bashscript is located.
	echo "	CSV file $i.csv has been created."
	echo "	Reading .seq files and counting characters..."

	for j in ${samples[@]}; do 		#For each .seq file, all charcounts per line (${#line}) after the first line are summed
		
		charCount=0
		lineCount=1

		while IFS= read -r line; do
			if [ $lineCount -gt 1 ]; then
				(( charCount = $charCount + ${#line} ))
			fi
			(( lineCount = $lineCount + 1 ))
		done < "$j"

		printf "$j,$charCount\n" >> $present/$i.csv	#sample and its charCount are stored in the CSV
	
	done

	echo "	CSV file $i.csv has been completed."

done

echo "Program complete!"