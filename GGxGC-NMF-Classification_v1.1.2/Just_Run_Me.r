##Input the folder location of "GCxGC-NMF-Classification_v1.1.1", including itself.
Folder_location <-"C:/.../GGxGC-NMF-Classification_v1.1.2"


#Name the output table file (csv).
Output_filename1 <- "GCxGC_NMF_result.csv"
Output_filename2 <- "Unknown_sample_result.csv"


#Not required to change.
inputDrive1 <- paste(Folder_location, "/Input/NMF_Input_Dataset",sep="")
inputDrive2 <- paste(Folder_location, "/Input/Unknown_Samples_to_Classify",sep="")
outputDrive <- paste(Folder_location, "/Output",sep="")
codeDrive <- paste(Folder_location, "/Code",sep="")
TempDrive <- paste(Folder_location, "/Output/NMFinput_and_Unknowns_eachpic_others",sep="")


###Skip the following installation code, if the following packages have been installed.
install.packages("NMF")
install.packages("JPEG")


###Parameters of measurement data
Modulation_Period  <- 4
Sampling_Rate <- 25.25
Phase_Shift <- 0
Initial_RT <- 7


###Masking of the GCxGC picture (measurement data).
Masking_left <- 8      #Left edge to remove from the data (sec)
Masking_right <- 120   #Right edge to remove from the data (sec)
Masking_bottom <- 0.6  #Bottom edge to remove from the data (sec)
Masking_top <- 0.2     #Top edge to remove from the data (sec)


###Parameter on the picture resolution.
###If you chose XCompFactor=2, 2 neighboring pixels in 1st dimension are merged with intensity averaging. YCompFactor is for 2nd dimension.
XCompFactor <- 2
YCompFactor <- 2


###The number of NMF rank (The number of class)
rank.number <- 3




###############################################################################################
###############################################################################################
###You can skip this process to supress calculation cost, if you already own the NMF results###
###Run the NMF code start###
setwd(codeDrive)
source("GCxGC_NMF_main.r")
###Run the NMF code end###
###You can skip this process to supress calculation cost, if you already own the NMF results###
###############################################################################################
###############################################################################################




####################################################################
####################################################################
###If you have unknown samples for the classification, run this code.###
###Run the unknown classification code start###
setwd(codeDrive)
source("GCxGC_Unknown_classification.r")
###Run the unknown classification code end###
###If you have unknown samples for the classification, run this code.###
####################################################################
####################################################################

