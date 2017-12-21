NMF_data_list_filename <- "sampleIDlist.csv"

setwd(outputDrive)
suppressWarnings( dir.create("NMFinput_and_Unknowns_eachpic_others") )

setwd(inputDrive1)
data.list <- matrix(1:(length(list.files())*2),length(list.files()),2 )
data.list[,2] <- list.files()
colnames(data.list) <- c("ID","File Name")
setwd(TempDrive)
write.csv(data.list, NMF_data_list_filename,row.names=F)

library(NMF)

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


###Data load and its ID
setwd(TempDrive)
sampleIDlist <- read.csv(NMF_data_list_filename, header=T)
sortID <- sampleIDlist[,1]


###Loading standard data
StdFilename <- sampleIDlist[1,2]
setwd(inputDrive1)
StdFile <- as.numeric( scan(paste(StdFilename), what="" ) )
RTruntime <- length(StdFile)/SamRate/60


###Loading supervised data
###Loading all the data, normalization
StdValueList <- 0
for (w in 1:length(sortID)){
	setwd(inputDrive1)
	filereadname <- sampleIDlist[w,2]
	fileroadedname <- paste("Sample",sortID[w],sep="")
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
StdValueList <- StdValueList[-c(1)]


roadedChromatoList <- paste("Sample",sortID[1:length(sortID)],"_Std",sep="")
cat(ChatRoadedChromatoList <- paste(roadedChromatoList,collapse=","))
ChatEachFileList <- paste("cbind(",ChatRoadedChromatoList,")",sep="")
AllChromatoMatrix <- eval(parse(text=ChatEachFileList))


##Store all chromatogram
setwd(codeDrive)
chromatoFileTemp <- AllChromatoMatrix
lengthID <- length(sortID)


###NMF
fcnum.nmf <- rank.number
malgo <- "Frobenius"
salgo <- "nndsvd"
nrun_value <- 1

resnmf <- nmf(AllChromatoMatrix, rank=fcnum.nmf, nrun=nrun_value, seed=salgo, malgo )

consensusmap(resnmf, labCol=NA, labRow=NA)

chosenRank <- rank.number
resnmf.coef <- coef(resnmf)
resnmf.basis <- basis(resnmf)


###rank sort
cum.resnmf.coef <- apply(resnmf.coef,1,sum)
order.for.resort <- order( cum.resnmf.coef, decreasing=T )
resnmf.coef <- resnmf.coef[order.for.resort,]
resnmf.basis <- resnmf.basis[,order.for.resort]

coefmap(resnmf)
dev.off()



setwd(TempDrive)
write.csv(resnmf.basis,"resnmf.basis.csv")



###coef
coefStdFactor <- apply(resnmf.coef,2,sum)
coefStdFactor.mat <- coefStdFactor

for (i0 in 1:chosenRank){
  coefStdFactor.mat <- rbind(coefStdFactor.mat,coefStdFactor)
}

coefStdFactor.mat <- coefStdFactor.mat[-c(1),]

par(mar=c(9,7,1,1))
barplot( resnmf.coef,las=3,ylab="NMF Coefficient",col=gray((1:rank.number)/(rank.number+1))  )

windows(width=8,height=8)
par(mar=c(9,7,1,1))
barplot( resnmf.coef/coefStdFactor.mat,las=3,ylab="Relative NMF Coefficient",col=gray((1:rank.number)/(rank.number+1))  )
legend("topright",legend=paste("Rank ",1:rank.number,sep=""),fill=gray((1:rank.number)/(rank.number+1)) )

setwd(outputDrive)
dev.copy(png,paste("Sample_Coefficients.png",sep=""))
dev.off()


###basis
for (i1 in 1:chosenRank){
	eachbasis <- paste("factor",i1 ," <- resnmf.basis[",',',i1,"]",sep="")
	eval(parse(text=eachbasis))

	eachbasis_Std <- paste("chromatoFile <- factor",i1 ,"/ max(factor",i1,")",sep="")
	eval(parse(text=eachbasis_Std))	

	setwd(codeDrive)
	source("source_basic_chromato_xx1yy1zz1.r")

	cstep <- 100
	cfactor <- 2
	clevels <- seq(0,(1)^(1/cfactor),length.out=cstep )^(cfactor)

	windows(width=10,height=5)
	par(mar=c(5,7,1,1))
	filled.contour(xx1,yy1,zz1,xlab="GC1 (min)",ylab="GC2 (sec)", col=red_blue(cstep),levels=clevels[1:cstep] )
	text(RTini*1.1+Masking_left/60,MPeriod*0.95-Masking_top,paste("Rank: ",i1,sep=""),col="black")

	setwd(outputDrive)
	dev.copy(png,paste("GCxGC_chromatogram_Rank",i1,".png",sep=""),width=1000,height=500)
	dev.off()
}


max.resnmf.coef <- apply(resnmf.coef,2,max)
max.resnmf.coef.mat <-  max.resnmf.coef
for (repi in 1:(fcnum.nmf-1)){
	max.resnmf.coef.mat <- rbind(max.resnmf.coef.mat,max.resnmf.coef)
}


RankForSample <- which(resnmf.coef==as.matrix(max.resnmf.coef.mat),arr.ind=T)
Rank.chosen <- RankForSample[,1]


Rank.max <- Rank.chosen
finalOutputbox <- cbind(sampleIDlist,Rank.max)
colnames(finalOutputbox) <- c("ID","File Name","Assigned Rank (Class)")


#CSV summary
setwd(outputDrive)
write.csv(finalOutputbox, Output_filename1)


#Append Picture
setwd(codeDrive)
chromatoFileTemp <- AllChromatoMatrix
lengthID <- length(sortID)
input.type.name <- "SampleID"
output.png.name <- "NMFinput_Append_withImageSimilarity.png"
var.sortID <- sortID
source("AllChromatoWithRank_Disp.r")

cat("NMF class generated")

