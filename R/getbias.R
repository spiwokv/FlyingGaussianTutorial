cv0<-read.table("../COLVAR.0")
cv1<-read.table("../COLVAR.1")
cv2<-read.table("../COLVAR.2")
cv3<-read.table("../COLVAR.3")
cv4<-read.table("../COLVAR.4")
cv5<-read.table("../COLVAR.5")
cv6<-read.table("../COLVAR.6")
cv7<-read.table("../COLVAR.7")
cv8<-read.table("../COLVAR.8")
cv9<-read.table("../COLVAR.9")
cv10<-read.table("../COLVAR.10")
cv11<-read.table("../COLVAR.11")
cv12<-read.table("../COLVAR.12")
cv13<-read.table("../COLVAR.13")
cv14<-read.table("../COLVAR.14")
cv15<-read.table("../COLVAR.15")
cv16<-read.table("../COLVAR.16")
cv17<-read.table("../COLVAR.17")
cv18<-read.table("../COLVAR.18")
cv19<-read.table("../COLVAR.19")

bias <- function(t) {
  t<-100*t
  cvone <- c(cv0[t,2],cv1[t,2],cv2[t,2],cv3[t,2],cv4[t,2],
           cv5[t,2],cv6[t,2],cv7[t,2],cv8[t,2],cv9[t,2],
           cv10[t,2],cv11[t,2],cv12[t,2],cv13[t,2],cv14[t,2],
           cv15[t,2],cv16[t,2],cv17[t,2],cv18[t,2],cv19[t,2])
  cvone <- 180*cvone/pi
  cvtwo <- c(cv0[t,3],cv1[t,3],cv2[t,3],cv3[t,3],cv4[t,3],
           cv5[t,3],cv6[t,3],cv7[t,3],cv8[t,3],cv9[t,3],
           cv10[t,3],cv11[t,3],cv12[t,3],cv13[t,3],cv14[t,3],
           cv15[t,3],cv16[t,3],cv17[t,3],cv18[t,3],cv19[t,3])
  cvtwo <- 180*cvtwo/pi
  x <- -36:36*5
  y <- -36:36*5
  ds <- 0.3*180/pi
  bp <- rep(0, times=length(x)*length(y))
  for(i in 1:length(x)) {
    for(j in 1:length(y)) {
      for(k in 1:length(cvone)) {
        dx <- (cvone[k]-x[i])
        if(dx < -180) {dx<-dx+360}
        if(dx >  180) {dx<-dx-360}
        dy <- (cvtwo[k]-x[j])
        if(dy < -180) {dy<-dy+360}
        if(dy >  180) {dy<-dy-360}
        bp[length(x)*(i-1)+j] <- bp[length(x)*(i-1)+j] + 4*exp(-(dx*dx+dy*dy)/2/ds/ds)
      }
    }
  }
  mat <- t(matrix(bp, nrow=length(x)))
  image(x, y, mat, xlab="phi", ylab="psi", zlim=c(0,25), col=rainbow(70)[50:1], axes=F, main=t/100)
  axis(1, at=60*(-3:3))
  axis(2, at=60*(-3:3))
  box()
  points(cvone, cvtwo, pch=21, bg=rainbow(length(cvone)))
}

png("bias%03d.png")
for(i in 1:501) {
  bias(i)
}
dev.off()

