#====== CHECK BALANCE FUNCTION =====#
check.balance <- function(tran,reac,irr,ddt,VF)
{
  rate <- vector(length=6)
  rate[1] <- tran$flux.up
  rate[2] <- tran$flux.down
  rate[3] <- sum(VF$mid*reac*PL$grid_data$dx)
  rate[4] <- sum(VF$mid*irr*PL$grid_data$dx)
  rate[5] <- sum(VF$mid*ddt*PL$grid_data$dx)
  rate[6] <- rate[1] - rate[2] + rate[3] + rate[4] - rate[5]
  return(rate)
}

#==== CALCULATE TORTUOSITY =====#
f.tort <- function(por) 1-2*log(por)
tort   <- function(D.grid, por.grid){
  D.grid$mid <- D.grid$mid/f.tort(por.grid$mid)
  D.grid$int <- D.grid$int/f.tort(por.grid$int)
  return(D.grid)
}
