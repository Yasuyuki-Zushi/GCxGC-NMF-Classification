XCompFactor <- XCompFactor
YCompFactor <- YCompFactor

TargetFile <- eval(parse(text=fileroadedname))

ypixnum <- round(re.MPeriod*SamRate)
xpixnum <- round(length(TargetFile) / ypixnum)

CompXcell <- floor(xpixnum/XCompFactor)
CompYcell <- floor(ypixnum/YCompFactor)

matrixTarget <- matrix(TargetFile/max(TargetFile),ypixnum,xpixnum)
matrixbox_Blank <- matrix(NA,CompYcell+1,CompXcell+1)


for (xt in seq(1,xpixnum,XCompFactor) ){
  for (yt in seq(1,ypixnum,YCompFactor) ){
    xc <- {(xt-1) / XCompFactor}+1
    yc <- {(yt-1) / YCompFactor}+1
    yt.vec <- yt:(yt+YCompFactor-1)
    xt.vec <- xt:(xt+XCompFactor-1)
    if(any(yt.vec > ypixnum)){
      over.num.y <- which(yt.vec > ypixnum)
      yt.vec[over.num.y] <- 1:length(over.num.y)
    }
    if(any(xt.vec > xpixnum)){
      over.num.x <- which(xt.vec > xpixnum)
      xt.vec[over.num.x] <- 1:length(over.num.x)
    }
    matrixbox_Blank[yc,xc] <- sum(matrixTarget[yt.vec,xt.vec]) / length(matrixTarget[yt.vec,xt.vec])
  }
}

matrixbox_Blank <- matrixbox_Blank[-c(nrow(matrixbox_Blank)),-c(ncol(matrixbox_Blank))]
chromatoFile <- as.numeric(matrixbox_Blank)
eval(parse(text=paste(fileroadedname, " <- chromatoFile",sep="") ))

SamRate.comp <- Sampling_Rate/(SamRate*MPeriod/nrow(matrixbox_Blank))
