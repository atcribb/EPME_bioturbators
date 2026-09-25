#==== CREATE PARAMETERS LIST FOR CONS MODEL =====#
#Note that this function will NOT work for other models with additional species, reactions, etc.
#It is specified to the function defined in CONS_model.R

init_PL <- function(biomixing, bioirrigation,
                    sediment_depth,
                    grid_layers,
                    salinity,
                    temperature,
                    pH,
                    CH2O,
                    O2,
                    SO4,
                    NO3,
                    DIC,
                    NH4,
                    H2S
                    ){

  #====== PARAMETERS LIST =====#
  PL <- list() #create empty parameters list

  # species model keeps track of
  PL$N.var <- 9
  PL$var.names <- c("CH2O.f","CH2O.s","O2","SO4","FeS","HCO3","NH4","NO3","HS")

  # reaction rates
  PL$N.rate <- 6
  PL$rate.names <- c("flux.up","flux.down","reac","irr","ddt","deficit")
  PL$rate.summary <- data.frame(matrix(nrow=PL$N.var,ncol=PL$N.rate),row.names=PL$var.names)
  names(PL$rate.summary) <- PL$rate.names

  # 7 reactions the model simulates
  PL$N.reac <- 7
  PL$reac.names <- c("R1","R2","R3","R4","R5","R6","R7")
  PL$reaction.summary <- data.frame (matrix(nrow=PL$N.reac,ncol=1),row.names=PL$reac.names)
  names(PL$reaction.summary) <- c("rate")

  #======== MODEL DOMAIN AND GRID DEFINITION =========#
  PL$L <- sediment_depth   # depth of sediment domain (cm)
  PL$N <- grid_layers  # number of grid layers
  PL$grid_data <- setup.grid.1D(x.up=0, x.down=PL$L, N=PL$N, dx.1=PL$L/2000, p.dx.1=1.1)
  PL$Depth <- PL$grid_data$x.mid

  #======= PARAMETERS =========#
  PL$S        <- salinity        # salinity
  PL$TC      <- temperature        # permian temperature (deg C)
  PL$P        <- 1.013                     # pressure (bar)
  PL$pH       <- pH

  #porosity profile:
  PL$por.0     <- 0.8    # porosity at the sediment-water interface
  PL$por.inf   <- 0.8    # asymptotic porosity at depth
  PL$por.x.att <- 1.0    # attenuation depth (cm)

  PL$por.grid <- setup.prop.1D(func=p.exp, grid=PL$grid_data, y.0=PL$por.0,     y.inf=PL$por.inf,     x.L=0, x.att=PL$por.x.att)
  PL$svf.grid <- setup.prop.1D(func=p.exp,grid=PL$grid_data,y.0=(1-PL$por.0),y.inf=(1-PL$por.inf),x.L=0,x.att=PL$por.x.att)

  #transport parameters:
  PL$rho.sed <- 2.6     # density solid sediment (g cm-3)
  PL$v.0     <- 0.2     # sedimentation velocity (cm yr-1)
  PL$v.inf   <- 0.2     # sedimentation velocity (cm yr-1)
  PL$velocity.info <- setup.compaction.1D(v.0 = PL$v.0, por.0=PL$por.0, por.inf=PL$por.inf, por.grid=PL$por.grid)
  PL$v.grid <- PL$velocity.info$v
  PL$u.grid <- PL$velocity.info$u

  #========= REACTION PARAMETERS =========#
  #organic matter decay
  PL$k.f <- 10.0     # decay constant organic matter (year-1) - Katsev et al. 2006
  PL$k.s <- 0.1      # decay constant organic matter (year-1) - Fossing et al. 2004

  PL$K_O2  <- 0.001  # Monod constant O2 consumption (umol cm-3 or mM) - van Cappellen and Wang (1996), Meysman et al. (2015)
  PL$K_NO3 <- 0.001  # Monod constant NO3 reduction  (umol cm-3 or mM) - van Cappellen and Wang (1996)
  PL$K_SO4 <- 0.9    # Monod constant SO4 reduction  (umol cm-3 or mM) - Meysman et al. (2015)

  PL$k_Sox <- 1E+06  # kinetic constant sulfide oxidation (umol-1 cm3 yr-1) - Meysman et al. (2015)
  PL$k_NH4 <- 1E+06  # kinetic constant NH4 oxidation (umol-1 cm3 yr-1)  - van Cappellen and Wang (1996)
  PL$k_Sni <- 1E+06  # kinetic sulfide oxidation with nitrate (umol-1 cm3 yr-1) - Meysman et al. (2015)

  PL$CNratio <- 106.0/16.0 # C to N ratio organic matter
  PL$f.FeS   <- 0.1        # fraction of sulphide precipitating as FeS

  #======= BOUNDARY CONDITIONS=========#
  umolcmyr <- (365.25/10) #conver to umol cm-2 y-1

  #MAX BOUNDARY CONDITIONS
  #flux boundary conditions
  F.CH2O.tot    <- CH2O            #total organic matter deposition (umol cm-2 yr-1)
  f.CH2O.fast    <- 0.50                       #fraction of organic matter that is fast degrading
  F.FeS          <- 0.0                        # FeS deposition (umol cm-2 yr-1)
  PL$F.CH2O.f <- F.CH2O.tot*f.CH2O.fast
  PL$F.CH2O.s <- F.CH2O.tot*(1-f.CH2O.fast)

  #solute boundary conditions
  PL$O2.ow    <- O2  #O2 concentration bottom water (umol cm-3 or mM)
  PL$SO4.ow   <- SO4  # SO4 concentration bottom water (umol cm-3 or mM)
  PL$NO3.ow   <- NO3   # NO3 concentration bottom water (umol cm-3 or mM)
  PL$HCO3.ow  <- DIC   # HCO3 concentration bottom water (umol cm-3 or mM)
  PL$NH4.ow   <- NH4   # NH4 concentration bottom water (umol cm-3 or mM)
  PL$HS.ow    <- H2S # HS concentration bottom water (umol cm-3 or mM)


  #Molecular diffusion (O2, SO4, HCO3, HS)
  c.fac <- 10000*(3600*24*365.25) # unit conversion

  Dmol.all <- c.fac*diffcoeff(S=PL$S, t=PL$TC, P=PL$P, species=c('O2', 'SO4', 'HCO3', 'NH4', 'NO3', 'HS'))

  PL$D.O2.grid <- setup.prop.1D(value=Dmol.all$O2, grid=PL$grid_data)
  PL$D.O2.grid <- tort(PL$D.O2.grid, PL$por.grid)

  PL$D.SO4.grid <- setup.prop.1D(value=Dmol.all$SO4, grid=PL$grid_data)
  PL$D.SO4.grid <- tort(PL$D.SO4.grid, PL$por.grid)

  PL$D.HCO3.grid <- setup.prop.1D(value=Dmol.all$HCO3, grid=PL$grid_data)
  PL$D.HCO3.grid <- tort(PL$D.HCO3.grid, PL$por.grid)

  PL$D.NH4.grid <- setup.prop.1D(value=Dmol.all$NH4, grid=PL$grid_data)
  PL$D.NH4.grid <- tort(PL$D.NH4.grid, PL$por.grid)

  PL$D.NO3.grid <- setup.prop.1D(value=Dmol.all$NO3, grid=PL$grid_data)
  PL$D.NO3.grid <- tort(PL$D.NO3.grid, PL$por.grid)

  PL$D.HS.grid <- setup.prop.1D(value=Dmol.all$HS, grid=PL$grid_data)
  PL$D.HS.grid <- tort(PL$D.HS.grid, PL$por.grid)

  #===== Bioturbation parmeters =====#
  #put variable parameters into PL
  PL$Db.0 <- biomixing
  PL$irr.0 <- bioirrigation

  #Biodiffusion grid
  PL$L.mix    <- 1 + 9*(1-exp((-PL$Db.0/3))) # Mixed depth layer - Eq from van de Velde and Meysman (2016)
  PL$Db.inf   <- 0.0      # deep Db (cm2 yr-1)
  PL$Db.x.att <- 2.0      # attenuation depth (cm)
  PL$Db.grid  <- setup.prop.1D(func=p.sig, grid=PL$grid_data,y.0=PL$Db.0,y.inf=PL$Db.inf,x.L=PL$L.mix,x.att=PL$Db.x.att)

  #Bioirrigation grid
  PL$L.irr     <- 0    # irrigation depth (cm)
  PL$irr.inf   <- 0    # deep irrigation rate (yr-1)
  PL$irr.x.att <- 3.0  # irrigation attenuation coefficient ([cm])cm)
  PL$irr.grid <- setup.prop.1D(func=p.exp,grid=PL$grid_data,y.0=PL$irr.0,y.inf=PL$irr.inf,x.L=PL$L.irr,x.att=PL$irr.x.att)


  return(PL)

}
