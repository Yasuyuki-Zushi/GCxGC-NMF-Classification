Unknown_Sample_list_filename <- "unknownIDlist.csv"

#NMF result load
setwd(TempDrive)
resnmf.basis <- as.matrix(read.csv("resnmf.basis.csv",header=T)[,-c(1)])


chosenRank <- rank.number

#Translate
MPeriod <- Modulation_Period
phase.shift <- Phase_Shift
SamRate <- SamRate.comp <- Sampling_Rate
RTini <- RTini.Del <- Initial_RT
DeleteCol <- round(Masking_left/MPeriod)
DeleteCol.end <- round(Masking_right/MPeriod)
DeleteRow.lower <- Masking_bottom #sec
DeleteRow.upper <- Masking_top #sec


###Masking
column.unit <- MPeriod*SamRate
lowside.cut <- round(SamRate * DeleteRow.lower)
upside.cut <- round(SamRate * DeleteRow.upper)
re.column.unit <- column.unit - (lowside.cut + upside.cut)
re.MPeriod <- re.column.unit/SamRate



###
###
###Loading unknow sample
setwd(codeDrive)
source("cosine.dist.r")

setwd(inputDrive2)
unknown.list <- matrix(1:(length(list.files())*2),length(list.files()),2 )
unknown.list[,2] <- list.files()
colnames(unknown.list) <- c("ID","File Name")
setwd(TempDrive)
write.csv(unknown.list, Unknown_Sample_list_filename,row.names=F)


###Data load and its ID
setwd(TempDrive)
unknownIDlist <- read.csv(Unknown_Sample_list_filename, header=T)
unknown.sortID <- unknownIDlist[,1]


###Loading standard data
unknown.StdFilename <- unknownIDlist[1,2]
setwd(inputDrive2)
unknown.StdFile <- as.numeric( scan(paste(unknown.StdFilename), what="" ) )
RTruntime <- length(unknown.StdFile)/SamRate/60


StdValueList <- 0

        for (w in 1:length(unknown.sortID)){
        	setwd(inputDrive2)
        	filereadname <- unknownIDlist[w,2]
        	fileroadedname <- paste("unkonwn",unknown.sortID[w],sep="")
        	cat(ReadFileName <- paste(fileroadedname, " <- as.numeric( scan('", filereadname,"'",", what='' ) )", sep=""))
        	eval(parse(text=ReadFileName ))

        	remPix <- DeleteCol*MPeriod*SamRate
        	remPix.end <- DeleteCol.end*MPeriod*SamRate
        	fileLength <- length(eval(parse(text=fileroadedname)))
        	dofileroadnameDelete <- paste(fileroadedname," <- ",fileroadedname,"[",(remPix+1),":",(fileLength-(remPix.end)),"]",sep="" )
        	eval(parse(text=dofileroadnameDelete))

        	subst.data <- eval(parse(text=paste(fileroadedname)))
        	for (cut.i in 1:(length(subst.data)/ column.unit) ){
        		if (cut.i==1){
        			comb.vector.lowside <- (1:lowside.cut)
        			comb.vector.upside <- {(column.unit-upside.cut+1):column.unit}
        		} else {
        			comb.vector.lowside <- {(cut.i-1)*column.unit}+(1:lowside.cut)
        			comb.vector.upside <- {(cut.i-1)*column.unit}+{(column.unit-upside.cut+1):column.unit}
        		}
        		if (cut.i ==1){
        			lowside.cut.vec <- comb.vector.lowside
        			upside.cut.vec <- comb.vector.upside
        		} else {
        			lowside.cut.vec <- c(lowside.cut.vec, comb.vector.lowside)
        			upside.cut.vec <- c(upside.cut.vec, comb.vector.upside)
        		}
        	}
        	subst.data <- subst.data[-c(lowside.cut.vec,upside.cut.vec)]
        	eval(parse(text=paste(fileroadedname," <- subst.data",sep="") ))


        	setwd(codeDrive)
        	source("Picture_Compression.r")

        	###Normalization
        	ChatStdValue <- paste("sum(",fileroadedname,")",sep="")
        	StdValue <- eval(parse(text=paste(ChatStdValue)))
        	StdValueList <- c(StdValueList,StdValue)
        	eval(parse(text=paste(fileroadedname,"_Std <-", fileroadedname, "/StdValue",sep="") ))
        } #for (w in 1:length(dataID)){
        unknown.StdValueList <- StdValueList[-c(1)]


        #unknown data list
        unknown.roadedChromatoList <- paste("unkonwn",1:length(unknown.sortID),"_Std",sep="")
        cat(unknown.ChatRoadedChromatoList <- paste(unknown.roadedChromatoList,collapse=","))
        unknown.ChatEachFileList <- paste("cbind(",unknown.ChatRoadedChromatoList,")",sep="")
        unknown.AllChromatoMatrix <- eval(parse(text=unknown.ChatEachFileList))


        ###Cos Dist between basis and unknown
        for (w in 1:length(unknown.sortID)){

                rankIDdisp <- 1:chosenRank
                AbsSubstValue.mat <- 0
                for(i4 in rankIDdisp){
                	eachfilename <- paste("unkonwn",w,"_Std",sep="")
                	basisMatName <- "(resnmf.basis[,i4]/max(resnmf.basis[,i4]))"
                	SampleVector <- eval(parse(text=eachfilename))
                	BasisVector <- eval(parse(text=basisMatName))
                	Sample_BasisVect <- cbind(SampleVector,BasisVector)
                	cos_Sample_BasisVect <- cosine.dist(Sample_BasisVect )[1,2]
                	AbsSubstValue.mat <- c(AbsSubstValue.mat,cos_Sample_BasisVect)

                }
                AbsSubstValue.mat <- AbsSubstValue.mat[-c(1)]
                names(AbsSubstValue.mat) <- paste("unkonwn",1:length(unknown.sortID),"_Std",rankIDdisp,sep="")


                maxCosDist <- max(AbsSubstValue.mat)[1]
                maxRank <- which(AbsSubstValue.mat==maxCosDist)


                if (w==1){
                	outputbox <- c(maxRank,maxCosDist)
                } else {
                	outputbox.1 <- c(maxRank,maxCosDist)
                	outputbox <- rbind(outputbox,outputbox.1)
                }

	} #for (w in 1:length(unknown.sortID)){
rownames(outputbox) <- 1:nrow(outputbox)
finalOutputbox <- cbind(unknownIDlist,outputbox)
colnames(finalOutputbox) <- c("ID","File Name","Assigned Rank (Class)","Similarity (0`1)")

setwd(outputDrive)
write.csv(finalOutputbox, Output_filename2 )

##Append Picture
setwd(codeDrive)
Rank.max <- finalOutputbox[,3]
chromatoFileTemp <- unknown.AllChromatoMatrix
lengthID <- length(unknown.sortID)
input.type.name <- "UnknownID"
output.png.name <- "Unknowns_Append_withImageSimilarity.png"
var.sortID <- unknown.sortID
source("AllChromatoWithRank_Disp.r")

