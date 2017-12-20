###All chromatogram depiction
setwd(codeDrive)

###Require
#chromatoFileTemp
#lengthID
#input.type.name <- "SampleID"
#output.png.name <- "Append_withImageSimilarity.png"


finalRank <- Rank.max
setwd(codeDrive)


for (w2 in 1:lengthID ){
  
  chromatoFile <- chromatoFileTemp[,w2]
  
  setwd(codeDrive)
  source("source_basic_chromato_xx1yy1zz1.r")
  cstep <- 100
  cfactor <- 2
  clevels <- seq(0,(1/1000)^(1/cfactor),length.out=cstep )^(cfactor)
  
  windows(10,5)
  setwd(TempDrive)
  jpeg( paste(input.type.name,w2,".jpg",sep=""),width=1000,height=500 )
  par(mar=c(5,7,1,1))
  filled.contour(xx1,yy1,zz1,xlab="RT1 (min)",ylab="RT2 (sec)", col=red_blue(cstep),levels=clevels[1:cstep] )
  text(RTini*2+Masking_left/60,MPeriod*0.85-Masking_top,paste("ID: ",w2,sep=""),cex=10,col="darkgray")
  
  if (finalRank[w2]==1)
  {col.chosen="red"}
  if (finalRank[w2]==2)
  {col.chosen="yellow"}
  if (finalRank[w2]==3)
  {col.chosen="black"}
  
  text(RTini*2.2+Masking_left/60,MPeriod*0.65-Masking_top,paste("Rank: ",finalRank[w2],sep=""),cex=10,col=col.chosen)
  
  dev.off()
  dev.off()
}


###Combine all the chromatogram with rank assignment
library(jpeg)

windows()
par(mar=c(0,0,0,0))
par(mfrow=c(max(ceiling(length(sortID)/4),5),4))

setwd(TempDrive)
for (w2 in 1:lengthID ){
  
  gcxgc.pic <- readJPEG( paste(input.type.name,w2,".jpg",sep="") )
  
  par(mar=c(0,0,0,0))
  plot( 0,0,xlim=c(0,700),ylim=c(0,512), axes=F,type="n")
  rasterImage(gcxgc.pic, 0, 0, 800, 512)
  
}

setwd(outputDrive)
dev.copy(device=png,file=output.png.name)
dev.off()
dev.off()
dev.off()



