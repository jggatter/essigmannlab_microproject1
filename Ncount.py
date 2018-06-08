#!/usr/bin/env python

#Author: jggatter@mit.edu

import sys

if len(sys.argv) != 6:
	print("Invalid number of arguments. Need 5")	#Arguments are: .seq file directory, sample group directory, append/write flag, start cut off, end cut off
	sys.exit()

start_cut_off = sys.argv[4]
end_cut_off = sys.argv[5]

file = open(sys.argv[1], "r")
contents = file.read() 
test = contents.split('ab1') 	#Split the first line off from the actual sequence.
characters = test[1] 			#The actual sequence

index = 0		#Current index while traversing characters
Ncount = 0		#Number of N's appended to list
Nloci = []		#Where N's are located
for i in characters:
	if i == 'N' and index >= int(start_cut_off) and index <= ((len(characters))-(int(end_cut_off))):	#Start and end cut offs determine whether an N is appended or ignored (For noise filtering purposes)
		Ncount = Ncount + 1
		Nloci.append(index)
	index = index + 1

file.close()

sampleName = sys.argv[1].split(".seq")	#Takes the file name and just cleaves the .seq. For sample name in the CSV.
fileName = "N" + sys.argv[2] + ".csv"	#Add "N" to the front and ".csv" to the back

csvfile = open(fileName, sys.argv[3])
if sys.argv[3] == "w":					#If write specified, begin the file with the categories
	csvfile.write("Sample,Ncount,Locus\n")

csvfile.write(sampleName[0] + "," + str(Ncount) + ",\n")
if Ncount > 0:							#If there were N's counted, write their loci to file.										
	for j in Nloci:						
		csvfile.write(",," + str(j) + "\n")

csvfile.close()