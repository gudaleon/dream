library(dream)

## n-dimensional banana shaped gaussian distribution
## Hyperbolic shaped posterior probability distribution
## @param x vector of length ndim
## @param bpar banana-ness. scalar.
## @param imat matrix ndim x ndim
## @return SSR. scalar
Banshp <- function(x,bpar,imat){
  x[2] <- x[2]+ bpar * x[1]^2 - 100*bpar
  S <- -0.5 * (x %*% imat) %*% as.matrix(x)
  return(S)
}

control <- list(
                ndim=10,
                DEpairs=3,
                gamma=0,
                nCR=3,
                ndraw=1e5,
                steps=10,
                eps=5e-2,
                outlierTest='IQR_test',
                pCR.Update=TRUE,
                thin.t=10,
                boundHandling='none',
                burnin.length=Inf, ##for compatibility with matlab code
                REPORT=1e4 ##reduce frequency of progress reports
                )


pars <- replicate(control$ndim,c(-Inf,Inf),simplify=F)
cmat <- diag(control$ndim)
cmat[1,1] <- 100
bpar <- 0.1
imat <- solve(cmat)
muX=rep(0,control$ndim)
qcov=diag(control$ndim)*5

set.seed(11)

dd <- dream(
            FUN=Banshp, func.type="logposterior.density",
            pars = pars,
            FUN.pars=list(
              imat=imat,
              bpar=bpar),
            INIT = CovInit,
            INIT.pars=list(
              muX=muX,
              qcov=qcov,
              bound.handling=control$boundHandling
              ),
            control = control
            )

summary(dd)


## Show banana
library(lattice)
ddm <- as.matrix(window(dd))
plot(ddm[,1],ddm[,2])
splom(ddm)

## Results were compared to two matlab runs
## While banana doesn't appear to match, it appears this is because it is a difficult problem
## Separate matlab results do not match either
