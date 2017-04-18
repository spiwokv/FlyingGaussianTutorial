fes <- function(step) {
  ifilename<-paste("fes",toString(step), sep="")
  ifilename<-paste(ifilename, ".txt", sep="")
  ifile <- read.table(ifilename)
  mat<-t(matrix(ifile[,3], nrow=48))
  image(-24:24*7.5, -24:24*7.5, mat,
        xlab="phi", ylab="psi", zlim=c(0,25), main=step,
        col=rainbow(70)[50:1], axes=F)
  axis(1, at=60*(-3:3))
  axis(2, at=60*(-3:3))
  box()
}

png("fes%03d.png")
for(i in 0:500) {
  fes(i)
}
dev.off()
