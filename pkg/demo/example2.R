## Example 2
## n-dimensional Gaussian distribution
## From Vrugt's matlab code

library(dream)
## Original version used ndim=100. The current R version has memory problems with such high dimensions
ndim <- 9
## Commented lines are default settings
control <- list(
                thin.t=10,
                ##pCR.Update=T,
                ##ndim=100,
                nseq=ndim,
                ndraw=1e5, ##The number of runs was reduced from 1e6 for speed
                ##nCR=3,
                ##gamma=0,
                DEpairs=3,
                ##steps=10,
                ##eps=5e-2,
                ##outlierTest='IQR_test',
                boundHandling='none',
                burnin.length=Inf, ##compatibility with matlab version, remove outliers all the time
                REPORT=1e4 ## Reduce frequency of progress reporting
                )

pars <- replicate(ndim,c(-5,15),simplify=F)

A <- 0.5*diag(ndim)+0.5
C <- matrix(NA,nrow=ndim,ncol=ndim)
for (i in 1:ndim){
  for (j in 1:ndim){
    C[i,j] <- A[i,j]*sqrt(i*j)
  }
}
invC <- solve(C) ## checked against matlab for ndim=3 and 7

normalfunc <- function(x){
  as.numeric(-0.5* x %*% invC %*% matrix(x))
}

ddd <- dream(normalfunc,
             func.type="logposterior.density",
             pars=pars,
             control=control
             )

################################################

library(reshape)
library(latticeExtra)
checkNormality <- function(seqs){
  print(round(sapply(apply(as.matrix(seqs),2,shapiro.test),
                     function(x) x$p.value),2))
  xxw.long <- melt(as.matrix(seqs))
  qqmath(~value|X2,xxw.long,as.table=T)+layer(panel.qqmathline(x))
}


summary(ddd)

## Using fraction of sequences
checkNormality(window(ddd,frac=0.45))

## Using extension of sequences
checkNormality(window(simulate(ddd,nsim=1e4)))


## Output matches that from matlab

