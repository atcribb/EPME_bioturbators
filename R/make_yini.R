#Function to make initial vector to pass to steady.1D

make_yini <- function(PL){

  CH2O.f  <- 0
  CH2O.s  <- 0
  O2    <- PL$O2.ow
  SO4   <- PL$SO4.ow
  FeS   <- 0
  HCO3  <- PL$HCO3.ow
  NH4   <- PL$NH4.ow
  NO3   <- PL$NO3.ow
  HS    <- PL$HS.ow

  N <- PL$N
  yini <- vector(length=PL$N.var*PL$N)
  yini[(0*N+1):(1*N)] <- CH2O.f
  yini[(1*N+1):(2*N)] <- CH2O.s
  yini[(2*N+1):(3*N)] <- O2
  yini[(3*N+1):(4*N)] <- SO4
  yini[(4*N+1):(5*N)] <- FeS
  yini[(5*N+1):(6*N)] <- HCO3
  yini[(6*N+1):(7*N)] <- NH4
  yini[(7*N+1):(8*N)] <- NO3
  yini[(8*N+1):(9*N)] <- HS

  return(yini)

}
