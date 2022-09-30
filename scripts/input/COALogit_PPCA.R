COALogit_PPCA <- function(refgdx,recovery,size,PPCA_pol,oecd,nonoecd,outputfolder,title,rev=NULL,fin_pol="none",uncertainty="90_CI",run=NULL,plot=NULL) {
  require(stats, quietly = TRUE,warn.conflicts =FALSE)
  require(dplyr, quietly = TRUE,warn.conflicts =FALSE)
  require(madrat, quietly = TRUE,warn.conflicts =FALSE)
  require(mrremind, quietly = TRUE,warn.conflicts =FALSE)
  require(stringr, quietly = TRUE,warn.conflicts =FALSE)
  require(scales, quietly = TRUE,warn.conflicts =FALSE)
  require(readxl, quietly = TRUE,warn.conflicts =FALSE)
  require(countrycode, quietly = TRUE,warn.conflicts =FALSE)
  
  # Set configuration specific to snapshot of input data used in publication 
  if (!is.null(rev))  setConfig(cachefolder = paste0("/p/projects/rd3mod/inputdata/cache/",rev))
  else  setConfig(cachefolder = "/p/projects/rd3mod/inputdata/cache/SB_GCPT")
  setConfig(outputfolder = outputfolder)
  subtype <- "inputdata"
  setConfig(forcecache = T)
  options(error=recover)

  ##########################################
  ### PPCA policy implementation params ####
  ###########################################
  pol_threshold <- 0.2      # REMIND regions only enforce the policy if its member nations comprise over a threshold share of regional energy and electricity demand
  leakage_allowance <- 1.5  # Freeriders in multi-national regions can increase coal consumption by 50% above reference
  p <- c(0.95, 0.5, 0.05)   # Probability thresholds for coalition accession 

  ### Demand-exit analysis runs in three stages to control non-solid coal demand, solid coal demand, and metallurgical coal demand
  if (PPCA_pol=="demand") {
    subpolicy <- c("none","solids","steel")
  }else if (PPCA_pol=="power") {
    subpolicy <- "none"
  }else {
    stop("Invalid policy type given for cm_PPCA_pol! Current options are demand and power.")
  }

  if (size=="current") {
    phase <- c("OECD","nonOECD")
    timestep <- 2015
  }else if (nonoecd=="on") {
    phase <- "nonOECD"
    timestep <- 2025
  }else if (oecd=="on") {
    phase <- "OECD"
    timestep <- 2045
  }

  ## Neutral Covid recovery is named BAU in previously written functions (e.g. mrremind:::readGCPT)
  if (recovery=="Neutral")  recovery <- "BAU"
  
  if (is.null(run)) {
    mif <- strsplit(strsplit(refgdx,"output/",fixed=T)[[1]][2],"_202[0-9]",fixed=F)[[1]][1]
    mif <- paste0("REMIND_generic_",mif,".mif")
    run <- gsub("fulldata.gdx",mif,refgdx)
    cat("Retrieving data from",run,"\n")
  }

  #Relevant regional mappings and country classifications
  #Current members of PPCA
  PPCAmap <- toolGetMapping("regionmappingPPCA.csv",type = "regional")
  ppca_map <- new.magpie(PPCAmap[,2],years=NULL,names=NULL,PPCAmap[,3])
  #Current OECD members
  OECDmap <- toolGetMapping("regionmappingOECD.csv",type = "regional")
  oecd_map <- new.magpie(OECDmap[,2],years=NULL,names=NULL,OECDmap[,3])
  #REMIND 12 region mapping
  map <- toolGetMapping("regionmappingH12.csv",type="regional")
  # setConfig(forcecache=T)
  
  # Read historical energy demand
  io <- calcOutput("IO",subtype="input",aggregate=F)[,2015,]
  # io <- calcOutput("IO",subtype="input",aggregate=F,years=seq(2000,2015,5))
  
  #Read historical electricity generation
  data <- readSource("IEA",subtype="EnergyBalances")[,2015,] * 0.0000418680000
  # data <- readSource("IEA",subtype="EnergyBalances")[,seq(2000,2015,5),] * 0.0000418680000
  # setConfig(forcecache = F)
  totalgen_c_hist <- data[,2015,"TOTAL.ELOUTPUT"]
  # totalgen_c_hist <- data[,seq(2000,2015,5),"TOTAL.ELOUTPUT"]
  totalgen_R_hist <- toolAggregate(totalgen_c_hist[,"y2015",],map,NULL)
  
  totalgen_2015_c <- totalgen_c_hist[,2015,]
  totalgen_2015_R <- toolAggregate(totalgen_R_hist[,2015,],map,NULL)
  
  #Read historical coal power generation
  coalvars <- fulldim(data)[[2]]$PRODUCT[1:18]
  coalgen <- data[,2015,paste0(coalvars,".ELOUTPUT")]
  # coalgen <- data[,seq(2000,2015,5),paste0(coalvars,".ELOUTPUT")]
  coalgen <- dimSums(coalgen,dim=3)
  coalgen_2015_c <- coalgen[,2015,]
  coalgen_2015_R <- toolAggregate(toolAggregate(coalgen_2015_c,map,NULL),map,NULL)

  # setConfig(forcecache=T)
  #Read future load factors
  loadfactor_c <- calcOutput("CapacityFactor",aggregate=F)[,c(2025,2045),"pc"]
  loadfactor_R <- calcOutput("CapacityFactor")[,c(2025,2045),"pc"]
  
  #SSP2 GDP per capita
  gdppc <- 1e-3 * calcOutput("GDPpc",aggregate=F)
  gdppc <- gdppc[,c(2015,2025,2045),"SSP2"]
  
  ### Loop over the OECD and non-OECD phase of PPCA accession (only done in the PPCA-current runs)
  for (ii in 1:length(phase)) {

    ### For demand-exit runs, loop over the subsets of coal demand being phased out (i.e. non-solids, solids, metallurgical solids)
    for (jj in 1:length(subpolicy)) {

      #Read output from preceding REMIND run in the DPE process
      rundata <- read.report(run,as.list=F)
      rundata <- rundata[,getYears(rundata)<="y2100",]
      
      #Assign regional load factors to countries with no historical capacity
      # for (y in getYears(loadfactor_c)) {
      #   loadfactor_c[,y,][which(hist_cap_c[,y,]==0 & cap_2025_c[,,"Green"]==0)] <- 0
      #   
      #   loadfactor_c[,y,][which(hist_cap_c[,y,]==0 & cap_2025_c[,,"Brown"]!=0)] <-
      #     loadfactor_R[,y,][map$RegionCode[which(map$CountryCode %in% getRegions(loadfactor_c[which(hist_cap_c[,y,]==0 & cap_2025_c[,,"Brown"]!=0)]))],,]
      # }
      
      if (is.null(recovery)) {
        recovery <- gsub(".mif","",strsplit(run,"-")[[1]][length(strsplit(run,"-")[[1]])])
        if (!(recovery %in% c("BAU","Brown","Green"))) {
          recovery <- "none"
        }
      }
                  
      # setConfig(forcecache = T)
      #SSP2 Population
      popC <- calcOutput("PopulationFuture",aggregate=F,years = getYears(rundata)[which(getYears(rundata)>="y2015")])[,,"pop_SSP2"]
      popR <- toolAggregate(popC,map,NULL)
            
      popGrowth <- popC[,getYears(popC)>"y2015",] - popC[,2015,]
      getYears(popGrowth) <- gsub(".y2015","",getYears(popGrowth))
      
      weight <- new.magpie(getRegions(popC),getYears(popGrowth),fill=0)
      # Aggregation weights for downscaling regional model output (and re-aggregating)
      for (yr in getYears(weight)) {
        weight[,yr,] <- data[,2015,"TOTAL.ELOUTPUT"] + 
          ifelse(data[,2015,"TOTAL.ELOUTPUT"] + (data[,2015,"TOTAL.ELOUTPUT"]/popC[,2015,]) * popGrowth[,yr,] >= 0,
                (data[,2015,"TOTAL.ELOUTPUT"]/popC[,2015,]) * popGrowth[,yr,], 0)
      }
      getYears(weight) <- getYears(popGrowth)
      # Aggregation weights for downscaling coal variables are the same as for energy/electricity demand 
      # except countries with no historical or planned coal demand are given zero weights.
      coalweight <- weight
      pipeline <- readSource("GCPT",subtype="status",convert=F)
      zero_pipe_reg <- getRegions(pipeline)[which(dimSums(pipeline[,,c("Announced","Pre-permit","Permitted","Construction","Shelved","Operating")],dim=3)==0)]
      coalweight[zero_pipe_reg,getYears(coalweight)<"y2100",] <- 0
      
      #####################################
      ## Coal share downscaling function ##
      #####################################
      downscale_coal <- function(coal_c_t1,total_c_t1,coal_R_t1,total_R_t1,coal_R_t2,total_R_t2) {
        # Make sure all arguments are at country level (for regional variables, assign each country its region's value) 
        if (length(getRegions(coal_R_t1))<length(getRegions(coal_c_t1)))  
          coal_R_t1 <- toolAggregate(coal_R_t1[-which(getRegions(coal_R_t1)=="GLO"),,],map,NULL)
        if (length(getRegions(total_R_t1))<length(getRegions(coal_c_t1)))  
            total_R_t1 <- toolAggregate(total_R_t1[-which(getRegions(total_R_t1)=="GLO"),,],map,NULL)
        if (length(getRegions(coal_R_t2))<length(getRegions(coal_c_t1)))  
            coal_R_t2 <- toolAggregate(coal_R_t2[-which(getRegions(coal_R_t2)=="GLO"),,],map,NULL)
        if (length(getRegions(total_R_t2))<length(getRegions(coal_c_t1)))  
            total_R_t2 <- toolAggregate(total_R_t2[-which(getRegions(total_R_t2)=="GLO"),,],map,NULL)
        # Define known national (t1) and regional (t1 and t2) coal-power-shares
        share_c_t1 <- replace_non_finite(coal_c_t1/total_c_t1,replace=0)
        share_R_t1 <- replace_non_finite(coal_R_t1/total_R_t1,replace=0)
        share_R_t2 <- replace_non_finite(coal_R_t2/total_R_t2,replace=0)
        # Initialize new variable for national coal-power-shares in t2
        share_c_t2 <- new.magpie(getRegions(coal_c_t1),getYears(coal_R_t2),getNames(coal_c_t1),fill=0)
        for (reg in unique(map$RegionCode)) {
          reg_all <- map$CountryCode[which(map$RegionCode==reg)]
          # Only apply function to regions multinational regions
          if (length(reg_all)>1) {
            # Only operate on countries with nonzero coal share
            reg_nonzero <- reg_all[which(share_c_t1[reg_all,,]>0)]
            for (ts in getYears(total_R_t2)) {
              if (length(reg_nonzero)) {
                # If regional coal-power-share is rising
                if (share_R_t2[reg_nonzero[1],ts,]>=share_R_t1[reg_nonzero[1],,]) {
                  # Calculate percentage of each country's coal-power-share in t1 above/below the region avg, normalized to 100%
                  dist <- (share_c_t1[reg_nonzero,,]-share_R_t1[reg_nonzero,,])/(1-share_R_t1[reg_nonzero,,])
                  # Assume this percentage persists until t2
                  share_c_t2[reg_nonzero,ts,] <- share_R_t2[reg_nonzero,ts,] + dist*(1-share_R_t2[reg_nonzero,ts,])
                }else {
                  # Calculate percentage of each country's coal-power-share in t1 above/below the region avg, normalized to 0%
                  dist <- (share_c_t1[reg_nonzero,,]-share_R_t1[reg_nonzero,,])/(0-share_R_t1[reg_nonzero,,])
                  share_c_t2[reg_nonzero,ts,] <- share_R_t2[reg_nonzero,ts,] + dist*(0-share_R_t2[reg_nonzero,ts,])
                }
              }
            }
          }else  share_c_t2[reg_all,ts,] <- share_R_t2[reg_all,ts,]
        }
        getYears(share_c_t2) <- getYears(coal_R_t2)
        return(share_c_t2)
      }
      
      
      #Extrapolate or downscale 2025 coal capacity
      ## Read historical data
      hist_cap_c <- readSource("GCPT",subtype="historical",convert=F)
      hist_cap_R <- toolAggregate(hist_cap_c,rel=map,weight=NULL)
      
      # Cases with no coal capacity constraint in 2025 (unreported scenarios)
      if (recovery=="none") {
        coalgen_2025_R <- rundata[,"y2025","SE|Electricity|Coal (EJ/yr)"]
        coalgen_2025_R <- toolAggregate(coalgen_2025_R[-which(getRegions(coalgen_2025_R)=="GLO"),,],map,NULL)
        
        # Proportional country-region relationship from 2015
        Kc <- toolNAreplace(coalgen_2015_c/coalgen_2015_R,replaceby=0)[[1]]
        coalgen_2025_c <- Kc * coalgen_2025_R
        
        # Derive 2025 capacity from rundata and load factor assumptions
        cap_2025_c <- coalgen_2025_c / (loadfactor_c[,2025,]*365*24/277777.77778)
        getYears(cap_2025_c) <- "y2025"
        cap_2025_c[which(hist_cap_c[,2015,]==0 & coalgen_2025_c==0)] <- 0
      
      }else {
        #Derive 2025 national coal capacity for the given COVID recovery with readGCPT function
        # setConfig(forcecache=F)
        # setConfig(ignorecache="readGCPT")
        cap_2025_c <- calcOutput("Capacity",subtype="coal2025",aggregate=F)[,,recovery] * 1e3
        # cap_2025_c <- readSource("GCPT",subtype="future",convert=F)[,,recovery]
        # setConfig(forcecache=T)
        # setConfig(ignorecache=NULL)
        
        # Aggregate capacity to REMIND regional level and report for sanity check
        cap_R_2025 <- toolAggregate(cap_2025_c,rel=map,weight=NULL)
        print(cap_R_2025)

        #Derive 2025 coal generation in exajoules from coal capacity and default REMIND country-level load factor assumptions
        coalgen_2025_c <- cap_2025_c * loadfactor_c[,2025,] *365*24/277777.77778
        #Aggregate results to regional level
        coalgen_2025_R <- toolAggregate(toolAggregate(coalgen_2025_c,map,NULL),map,NULL)
      }
      getYears(coalgen_2025_c) <- "y2025"
      
      #########################################
      ### Total Electricity generation 2025 ###
      #########################################
      # Regional data from REMIND output
      totalgen_2025_R <- rundata[,"y2025","SE|Electricity (EJ/yr)"]
      # Downscale regional REMIND results to national level using disaggregation weight defined above
      totalgen_2025_c <- toolAggregate(totalgen_2025_R[-which(getRegions(totalgen_2025_R)=="GLO"),,],map,weight[,2025,])
      
      ### Safeguard in case downscaling results in countries with coal power share >100% ###
      # Loop over regions
      for (reg in getRegions(totalgen_2025_R)) {
        # All countries in reg
        reg_all <- map$CountryCode[which(map$RegionCode==reg)]
        # Countries with coal share >100%
        reg_excess <- reg_all[which(coalgen_2025_c[reg_all,,]/totalgen_2025_c[reg_all,,] > 1)]
        # Countries with nonzero coal generation
        reg_nonzero <- reg_all[which(totalgen_2025_c[reg_all,,] > 0)]
        
        if (length(reg_excess)) {
          # Each nonzero country's share of total electricity among all nonzero countries in region
          reg_normalized <- totalgen_2025_c[reg_nonzero,,] /
            dimSums(totalgen_2025_c[reg_nonzero,,],dim=1)
          # Excess coal power generation among all countries in region with coal share >100%
          excess <- dimSums(coalgen_2025_c[reg_excess,,] - totalgen_2025_c[reg_excess,,] / 
            max(coalgen_2015_c[reg_all,,]/totalgen_2015_c[reg_all,,],na.rm=TRUE), dim=1)
          # Increase those countries' total electricity generation so that their coal power shares equal the regional max in 2015
          totalgen_2025_c[reg_excess,,] <- coalgen_2025_c[reg_excess,,] / 
            max(coalgen_2015_c[reg_all,,]/totalgen_2015_c[reg_all,,],na.rm=TRUE)
          # Decrease total electricity generation in all other nonzero countries by the proportional amount 
          totalgen_2025_c[reg_nonzero,,] <- totalgen_2025_c[reg_nonzero,,] - 
            excess * reg_normalized
        }
      }
      getYears(totalgen_2025_c) <- "y2025"
      
      #Derive country-level coal shares
      coalShare_2025_c <- replace_non_finite(coalgen_2025_c/totalgen_2025_c,replace = 0)
           

      if (grepl("current",size)) {

      #########################################
      ########## DEFINE CURRENT PPCA ##########
      #########################################
        ppca <- PPCAmap$CountryCode[which(PPCAmap$RegionCode=="PPCA")]
        oecd <- OECDmap$CountryCode[which(OECDmap$RegionCode=="OECD")]
        EU27 <- map$CountryCode[which(map$RegionCode=="EUR")]
        nonoecd <- OECDmap$CountryCode[which(OECDmap$RegionCode=="NON")]
        #The PPCA stipulates that OECD and EU members must phase out coal power by 2030
        oecd_members <- ppca[which(ppca %in% oecd | ppca %in% EU27)]
        #While non-OECD members must phase out coal power by 2050
        nonoecd_members <- ppca[which(!(ppca %in% oecd_members))]

      }else {

        #################################################
        ################## LOGIT MODEL ##################
        #################################################
        # Read file tracking the current status of the PPCA which contains GDPpc, % coal in electricity, 
        # standing coal power capacity, among other data
        histData <- read.csv(paste0(getConfig("sourcefolder"),"/PPCA/PPCA_status_SSP2_2015.csv"),stringsAsFactors = F,sep = ",")
        # If file doesn't contain column with binary values for PPCA membership, add it
        if (!is.element("PPCA.Bin",colnames(histData)))  histData <- histData %>% mutate(PPCA.Bin=ifelse(PPCA=="PPCA",1,0))
                
        ### Logistic regression of existing PPCA membership against GDP per capita and coal-power-shares ###
        logit_model <- glm(data = histData, PPCA.Bin ~  Coal.Share + GDP.PC, family = "binomial")
        # Intercepts of threshold lines
        ic <-  (log(1/p -1) -  summary(logit_model)$coef[1])/ summary(logit_model)$coef[3]
        # Slopes of threshold lines
        slope <- -(summary(logit_model)$coef[2]/summary(logit_model)$coef[3])
        # All countries lying above this line are members of the given coalition scenario
        ln <- data.frame(Ic = ic, Slope = slope, Prob = as.character(p))
        
        getNames(coalShare_2025_c) <- recovery
        getYears(coalShare_2025_c) <- "y2025"
        
        ### New data frame containing 2025 data for logit analysis
        OECD <- data.frame(country=sort(getRegions(coalShare_2025_c)),
                           oecd=as.character(oecd_map),
                           ppca=as.character(ppca_map),
                           gdp=as.numeric(gdppc[,2025,]),
                           share=as.numeric(coalShare_2025_c),
                           Region=map$RegionCode) %>%
                ### Run logit model on 2025 data to get OECD nations' accession probabilities ###
                mutate(accession_prob = predict(object = logit_model, 
                                                newdata = data.frame(Coal.Share=share,GDP.PC=gdp),
                                                type = "response"))
        
        ##########################################
        ### Determine OECD coalition scenarios ###
        ##########################################
        OECD <- OECD %>% mutate(coalition = ifelse(accession_prob > p[3] & oecd=="OECD",
                                                 "5p", "free"))
        OECD <- OECD %>% mutate(coalition=ifelse(accession_prob > p[2] & oecd=="OECD",
                                                 "50p", coalition))
        OECD <- OECD %>% mutate(coalition=ifelse((accession_prob > p[1] | ppca=="PPCA") & (oecd=="OECD" | Region=="EUR"),
                                                 "95p", coalition))
        
        #OECD coalition
        oecd_95p <- OECD %>% filter(coalition=="95p") %>% select(country)
        oecd_50p <- OECD %>% filter(coalition %in% c("95p","50p")) %>% select(country)
        oecd_5p <- OECD %>% filter(coalition %in% c("95p","50p","5p")) %>% select(country)
        
        if (grepl("coalitions",subtype) & !grepl("non",phase[ii],ignore.case=TRUE)) {
          return(list(oecd95p=oecd_95p,oecd50p=oecd_50p,oecd5p=oecd_5p))
        }
        
        # Coalitions were originally named 1p, 2p, 3p
        if (grepl("95p",run) | grepl("95p",size) | grepl("1p",run) | grepl("1p",size)) {
          oecd_members <- as.character(oecd_95p[,1])
        }else if (grepl("50p",run) | grepl("50p",size) | grepl("2p",run) | grepl("2p",size)) {
          oecd_members <- as.character(oecd_50p[,1])
        }else if (grepl("5p",run) | grepl("5p",size) | grepl("3p",run) | grepl("3p",size)) {
          oecd_members <- as.character(oecd_5p[,1])
        }
      }
      print("OECD members")
      print(oecd_members)
      ################################################
      ########### POWER EXIT REMIND DATA #############
      ################################################
      
      # Use regional downscaling of REMIND results to derive country-level coal and total electricity generation in 2030
      coalgen_2030_R <- rundata[,getYears(rundata)>="y2030","SE|Electricity|Coal (EJ/yr)"]
      coalgen_2030_R <- toolAggregate(coalgen_2030_R[-which(getRegions(coalgen_2030_R)=="GLO"),,],map,NULL)
      
      totalgen_2030_R <- rundata[,getYears(rundata)>="y2030","SE|Electricity (EJ/yr)"]
      totalgen_2030_c <- toolAggregate(totalgen_2030_R[-which(getRegions(totalgen_2030_R)=="GLO"),,],map,weight[,2030,])
      print("weight 2030 OAS")
      print(100 * weight[map$CountryCode[which(map$RegionCode=="OAS")],2030,] / dimSums(weight[map$CountryCode[which(map$RegionCode=="OAS")],2030,],dim=1))
      
      # Apply downscale formula to derive 2030 coal generation by country
      coalshare_2030_c <- downscale_coal(coalgen_2025_c,totalgen_2025_c,coalgen_2025_R,totalgen_2025_R,coalgen_2030_R,totalgen_2030_R)
      coalgen_2030_c <- coalshare_2030_c * totalgen_2030_c

      #Read 2045 total electricity generation from appropriate OECD phase-out REMIND scenario
      totalgen_2045_R <- rundata[,"y2045","SE|Electricity (EJ/yr)"]
      totalgen_2045_c <- toolAggregate(totalgen_2045_R[-which(getRegions(totalgen_2045_R)=="GLO"),,],map,weight[,2045,])
      
      coalgen_2045_R <- rundata[,"y2045","SE|Electricity|Coal (EJ/yr)"]
      # coalgen_2045_c <- toolAggregate(coalgen_2045_R[-which(getRegions(coalgen_2045_R)=="GLO"),,],map,coalweight[,2045,])
      coalgen_2045_R <- toolAggregate(coalgen_2045_R[-which(getRegions(coalgen_2045_R)=="GLO"),,],map,NULL)
      
      #Read 2050 total electricity generation from appropriate OECD phase-out REMIND scenario
      totalgen_2050_R <- rundata[,getYears(rundata)>="y2050","SE|Electricity (EJ/yr)"]
      totalgen_2050_c <- toolAggregate(totalgen_2050_R[-which(getRegions(totalgen_2050_R)=="GLO"),,],map,weight[,2050,])
      
      coalgen_2050_R <- rundata[,getYears(rundata)>="y2050","SE|Electricity|Coal (EJ/yr)"]
      # coalgen_2050_c <- toolAggregate(coalgen_2050_R[-which(getRegions(coalgen_2050_R)=="GLO"),,],map,coalweight[,2050,])
      coalgen_2050_R <- toolAggregate(coalgen_2050_R[-which(getRegions(coalgen_2050_R)=="GLO"),,],map,NULL)
      
      print("coalshare_2030_c * leakage_allowance")
      print(coalshare_2030_c[map$CountryCode[which(map$RegionCode=="OAS")],2030,] * leakage_allowance)
              
      ##################################################
      ### 2045 COAL SHARE IN ELECTRICITY CALCULATION ###
      ##################################################
      logit_coalgen_2030_c <- coalgen_2030_c[,"y2030",]
      for (reg in unique(map$RegionCode)) {
        reg_oecd_members <- map$CountryCode[which(map$CountryCode %in% oecd_members & map$RegionCode==reg)]
        reg_all <- map$CountryCode[which(map$RegionCode==reg)]
        reg_freeriders <- setdiff(reg_all,reg_oecd_members)
        reg_nonzero_freeriders <- getRegions(logit_coalgen_2030_c[reg_freeriders,,])[which(logit_coalgen_2030_c[reg_freeriders,,]>0)]
        
        # Set OECD PPCA members' 2030 coal share to 0
        logit_coalgen_2030_c[reg_oecd_members,,] <- 0 
          
        ## If there are both OECD PPCA members and freeriders in the region, distribute the PPCA members' coal to the freeriders
        if (length(reg_oecd_members) & length(reg_nonzero_freeriders)) {
          reg_normalized_pow_dem <- totalgen_2030_c[reg_nonzero_freeriders,"y2030",]/dimSums(totalgen_2030_c[reg_nonzero_freeriders,"y2030",],dim=1)

          logit_coalgen_2030_c[reg_nonzero_freeriders,,] <- logit_coalgen_2030_c[reg_nonzero_freeriders,,] + 
            dimSums(coalgen_2030_c[reg_oecd_members,"y2030",]-logit_coalgen_2030_c[reg_oecd_members,,],dim=1) * reg_normalized_pow_dem
          
          logit_coalshare_2030_c <- logit_coalgen_2030_c / totalgen_2030_c[,"y2030",]
          
          reg_excess <- reg_nonzero_freeriders[which(logit_coalshare_2030_c[reg_nonzero_freeriders,,] > 1)]

          ## If the redistribution of coal results in other countries with >100% share in coal...
          while (length(reg_excess) & length(reg_nonzero_freeriders)) {
            excess <- dimSums(leakage_allowance * coalgen_2030_c[reg_excess,"y2030",] - logit_coalgen_2030_c[reg_excess,,], dim=1)
            print(excess)

            

            # Set them to the maximum allowed leakage
            # logit_coalshare_2030_c[reg_excess,,] <- leakage_allowance * coalshare_2030_c[reg_excess,"y2030",]

            reg_nonzero_freeriders <- reg_nonzero_freeriders[which(!(reg_nonzero_freeriders %in% reg_excess))]
            
            # And redistribute the excess to other freeriding nations (if any)
            if (length(reg_nonzero_freeriders)) {
              reg_normalized_pow_dem <- totalgen_2030_c[reg_nonzero_freeriders,"y2030",]/dimSums(totalgen_2030_c[reg_nonzero_freeriders,"y2030",],dim=1)
              logit_coalgen_2030_c[reg_nonzero_freeriders,,] <- logit_coalgen_2030_c[reg_nonzero_freeriders,,] + excess * reg_normalized_pow_dem

              # Check again if this causes any countries to exceed 100%
              reg_excess <- reg_nonzero_freeriders[which(logit_coalgen_2030_c[reg_nonzero_freeriders,,]/totalgen_2030_c[reg_nonzero_freeriders,"y2030",] > 1)]

            }
          }
        }
      }
      
      print("coalshare_2030_c OAS")
      print(logit_coalgen_2030_c[map$CountryCode[which(map$RegionCode=="OAS")],2030,] / totalgen_2030_c[map$CountryCode[which(map$RegionCode=="OAS")],2030,])

      # Derive 2045 coal share in electricity for use in logistic regression
      logit_coalShare_2045_c <- downscale_coal(logit_coalgen_2030_c,totalgen_2030_c[,"y2030",],coalgen_2030_R[,"y2030",],totalgen_2030_R[,"y2030",],coalgen_2045_R[,"y2045",],totalgen_2045_R[,"y2045",])
      logit_coalgen_2045_c <- logit_coalShare_2045_c * totalgen_2045_c[,"y2045",]
      getNames(logit_coalShare_2045_c) <- recovery
      logit_coalcap_2045_c <- logit_coalgen_2045_c / (loadfactor_c[,2045,]*365*24/277777.77778)
                      

      ###############################
      ######### DEMAND EXIT #########
      ###############################
      if (grepl("demand",PPCA_pol)) {
        
        for (yr in getYears(weight)) {
          weight[,yr,] <- data[,2015,"TOTAL.TFC"] + 
            ifelse(data[,2015,"TOTAL.TFC"] + (data[,2015,"TOTAL.TFC"]/popC[,2015,]) * popGrowth[,yr,] > 0,
                  (data[,2015,"TOTAL.TFC"]/popC[,2015,]) * popGrowth[,yr,], 0)
        }
        zero_coal_dem <- getRegions(data)[which(dimSums(data[,2015,paste0(coalvars,".TFC")],dim=3)==0)]
        coalweight[intersect(zero_coal_dem,zero_pipe_reg),getYears(coalweight)<"y2100",] <- 0
        
        # setConfig(forcecache=T)
        # Steel sector is permitted to continue using coal for 10 years after other demand sectors
        if (grepl("steel",subpolicy[jj])) {
          # Coal demand from the steel sector
          coaldem_c <- dimSums(data[,2015,paste0(coalvars,".IRONSTL")],dim=3)

          # 2040 steel sector coal demand from REMIND run (using coalemi_2030 for convenience)
          coalemi_2030_R <- rundata[,getYears(rundata)>="y2040",]
          coalemi_2030_R <- coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"Emi|CO2|FFaI|Industry|Steel|Fuel|Coal (Mt CO2/yr)"]
          totalemi_2030_R <- dimSums(rundata[,getYears(rundata)>="y2040","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
          
        }else if (grepl("solids",subpolicy[jj])) {
          # Historical coal solids demand
          coaldem_c <- io[,2015,"pecoal.sesofos.coaltr"]
          
          # Coal solids emissions except from steel sector in 2030
          coalemi_2030_R <- rundata[,getYears(rundata)>="y2030",]
          coalemi_2030_R <- coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"Emi|CO2|Energy|Demand|Solids|After IndustryCCS (Mt CO2/yr)"] * 
            (coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] / 
            (coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] + coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"PE|Biomass|Solids (EJ/yr)"])) - 
            coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"Emi|CO2|FFaI|Industry|Steel|Fuel|Coal (Mt CO2/yr)"]
          totalemi_2030_R <- dimSums(rundata[,getYears(rundata)>="y2030","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
        
        }else {
          # Coal demand (except solids) for 2015
          coaldem_c <- dimSums(io[,2015,"pecoal"],dim=3) - io[,2015,"pecoal.sesofos.coaltr"]
          
          # 2030 Coal demand from REMIND run
          coalemi_2030_R <- rundata[,getYears(rundata)>="y2030",]
          coalemi_2030_R <- coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"Emi|CO2|Fossil Fuels and Industry|Coal|Before IndustryCCS (Mt CO2/yr)"] - 
            coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"Emi|CO2|Energy|Demand|Solids|After IndustryCCS (Mt CO2/yr)"] *
              (coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] / 
              (coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] + coalemi_2030_R[-which(getRegions(coalemi_2030_R)=="GLO"),,"PE|Biomass|Solids (EJ/yr)"]))            
          totalemi_2030_R <- dimSums(rundata[,getYears(rundata)>="y2030","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
        }
        
        # Convert historical coal demand to emissions 
        # 26.1 GtC/ZJ to MtCO2/EJ
        emifac_coal <- 26.1 * 3.67 * 1e-3 * 1e3
        coalemi_c <- coaldem_c * emifac_coal
        coalemi_R <- toolAggregate(toolAggregate(coalemi_c,map,NULL),map,NULL)
        # setConfig(forcecache=T)
        
        # Read in total 2015 emissions by country
        totalemi_c <- dimSums(calcOutput("HistEmissions",subtype="sector",aggregate=F,years=2015)[,,"co2"],dim=3)
        # totalemi_c <- dimSums(calcOutput("HistEmissions",subtype="sector",aggregate=F,years=seq(2000,2015,5)),dim=2)
        totalemi_R <- toolAggregate(toolAggregate(totalemi_c,map,NULL),map,NULL)
        
        ## Downscale total emissions from REMIND energy demand and population disaggregation weight
        totalemi_2030_c <- toolAggregate(totalemi_2030_R[-which(getRegions(totalemi_2030_R)=="GLO"),,],map,weight[,getYears(totalemi_2030_R),])
        coalemi_2030_R <- toolAggregate(coalemi_2030_R,map,NULL)
        
        # Extrapolate country-level coal emissions from historical 2015 data
        coalshare_2030_c <- downscale_coal(coalemi_c,totalemi_c,coalemi_R,totalemi_R,coalemi_2030_R,totalemi_2030_R)
        coalemi_2030_c <- coalshare_2030_c * totalemi_2030_c
        getNames(coalemi_2030_c) <- recovery
        
      }
           
      
      # 2045 Coal share in electricity for use in deriving REMIND policy stringency coefficients
      coalShare_2045_c <- downscale_coal(coalgen_2030_c[,"y2030",],totalgen_2030_c[,"y2030",],coalgen_2030_R[,"y2030",],totalgen_2030_R[,"y2030",],coalgen_2045_R,totalgen_2045_R)
      coalgen_2045_c <- coalShare_2045_c * totalgen_2045_c

      getNames(coalShare_2045_c) <- recovery
      getYears(coalShare_2045_c) <- "y2045"
      
      #################################################
      ################ NON-OECD LOGIT #################
      #################################################
      if (!grepl("current",size)) {
        nonOECD <- data.frame(country=sort(getRegions(logit_coalShare_2045_c)),
                              oecd=as.character(oecd_map),
                              ppca=as.character(ppca_map),
                              share_2045=as.numeric(logit_coalShare_2045_c),
                              gdp=as.numeric(gdppc[,2045,]),
                              Region=map$RegionCode) %>%
                    ### Run logit model on 2045 data to get non-OECD nations' accession probabilities ###
                    mutate(accession_prob = predict(object = logit_model, 
                                                    newdata = data.frame(Coal.Share=share_2045,GDP.PC=gdp),
                                                    type = "response"))
        
        ##############################################
        ### Determine non-OECD coalition scenarios ###
        ##############################################
        nonOECD <- nonOECD %>% mutate(nonOECDcoalition = ifelse(accession_prob > p[3] & oecd=="Non-OECD",
                                                 "5p", "free"))
        nonOECD <- nonOECD %>% mutate(nonOECDcoalition=ifelse(accession_prob > p[2] & oecd=="Non-OECD",
                                                 "50p", nonOECDcoalition))
        nonOECD <- nonOECD %>% mutate(nonOECDcoalition=ifelse((accession_prob > p[1] | ppca=="PPCA") & oecd=="Non-OECD",
                                                 "95p", nonOECDcoalition))           
        
        #Non-OECD coalitions
        non_oecd_95p <- nonOECD %>% filter(nonOECDcoalition=="95p") %>% select(country)
        non_oecd_50p <- nonOECD %>% filter(nonOECDcoalition %in% c("95p","50p")) %>% select(country)
        non_oecd_5p <- nonOECD %>% filter(nonOECDcoalition %in% c("95p","50p","5p")) %>% select(country)
        
        if (grepl("95p",run) | grepl("95p",size) | grepl("1p",run) | grepl("1p",size)) {
          nonoecd_members <- as.character(non_oecd_95p[,1])
        }else if (grepl("50p",run) | grepl("50p",size) | grepl("2p",run) | grepl("2p",size)) {
          nonoecd_members <- as.character(non_oecd_50p[,1])
        }else if (grepl("5p",run) | grepl("5p",size) | grepl("3p",run) | grepl("3p",size)) {
          nonoecd_members <- as.character(non_oecd_5p[,1])
        }
        
        if (grepl("coalitions",subtype)) {
          for (yr in getYears(weight)) {
            weight[,yr,] <- data[,2015,"TOTAL.TFC"] + 
              ifelse(data[,2015,"TOTAL.TFC"] + (data[,2015,"TOTAL.TFC"]/popC[,2015,]) * popGrowth[,yr,] > 0,
                    (data[,2015,"TOTAL.TFC"]/popC[,2015,]) * popGrowth[,yr,], 0)
          }
          getYears(weight) <- getYears(popGrowth)
          return(list(non_oecd=unique(c(oecd_members,nonoecd_members)),weight=weight))
        }
      }
      
      if (grepl("power",PPCA_pol)) {
        
        # Extrapolate 2050 national coal shares from 2045
        coalshare_2050_c <- downscale_coal(coalgen_2045_c,totalgen_2045_c,coalgen_2045_R,totalgen_2045_R,coalgen_2050_R,totalgen_2050_R)
        coalgen_2050_c <- coalshare_2050_c * totalgen_2050_c
        getYears(coalgen_2050_c) <- getYears(coalgen_2050_R)
        
      }else if (grepl("demand",PPCA_pol)) {
        if (grepl("steel",subpolicy[jj])) {
          # Coal emissions from steel sector in 2060 (using 2050 vars for convenience)
          coalemi_2050_R <- rundata[,getYears(rundata)>="y2060",]
          coalemi_2050_R <- coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"Emi|CO2|FFaI|Industry|Steel|Fuel|Coal (Mt CO2/yr)"]
          totalemi_2050_R <- dimSums(rundata[,getYears(rundata)>="y2060","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
        }else if (grepl("solids",subpolicy[jj])) {
          # Coal solids emissions except from steel sector in 2050
          coalemi_2050_R <- rundata[,getYears(rundata)>="y2050",]
          coalemi_2050_R <- coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"Emi|CO2|Energy|Demand|Solids|After IndustryCCS (Mt CO2/yr)"] *
            (coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] / 
            (coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] + coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"PE|Biomass|Solids (EJ/yr)"])) - 
            coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"Emi|CO2|FFaI|Industry|Steel|Fuel|Coal (Mt CO2/yr)"]
          totalemi_2050_R <- dimSums(rundata[,getYears(rundata)>="y2050","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
        }else {
          # Coal emissions (except from solids) from 2050 time step of the reference scenario
          coalemi_2050_R <- rundata[,getYears(rundata)>="y2050",]
          coalemi_2050_R <- coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"Emi|CO2|Fossil Fuels and Industry|Coal|Before IndustryCCS (Mt CO2/yr)"] *
            (coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] / 
            (coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] + coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"PE|Biomass|Solids (EJ/yr)"])) - 
            coalemi_2050_R[-which(getRegions(coalemi_2050_R)=="GLO"),,"Emi|CO2|Energy|Demand|Solids|After IndustryCCS (Mt CO2/yr)"]
          totalemi_2050_R <- dimSums(rundata[,getYears(rundata)>="y2050","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
        }

        totalemi_2050_c <- toolAggregate(totalemi_2050_R[-which(getRegions(totalemi_2050_R)=="GLO"),,],map,weight[,getYears(totalemi_2050_R),])
        coalemi_2050_R <- toolAggregate(coalemi_2050_R,map,NULL)
        
        # Extrapolate 2050 national coal shares from 2030
        coalshare_2050_c <- downscale_coal(coalemi_2030_c[,getYears(coalemi_2030_c)[1],],totalemi_2030_c[,getYears(totalemi_2030_c)[1],],coalemi_2030_R[,getYears(coalemi_2030_R)[1],],totalemi_2030_R[,getYears(totalemi_2030_R)[1],],coalemi_2050_R,totalemi_2050_R)
        coalemi_2050_c <- coalshare_2050_c * totalemi_2050_c
        getYears(coalemi_2050_c) <- getYears(coalemi_2050_R)
        getNames(coalemi_2050_c) <- recovery
        getNames(totalemi_2050_c) <- recovery
        
      }
      
      # Unmanipulated reference scenario variables
      coalgen_ttot_R <- rundata[-which(getRegions(rundata)=="GLO"),getYears(coalweight),"SE|Electricity|Coal (EJ/yr)"]
      coalgen_ttot_c <- toolAggregate(coalgen_ttot_R,map,coalweight)
      
      totalgen_ttot_R <- rundata[-which(getRegions(rundata)=="GLO"),getYears(weight),"SE|Electricity (EJ/yr)"]
      totalgen_ttot_c <- toolAggregate(totalgen_ttot_R,map,weight)
      
      coalemi_ttot_R <- rundata[-which(getRegions(rundata)=="GLO"),getYears(coalweight),"Emi|CO2|Fossil Fuels and Industry|Coal|Before IndustryCCS (Mt CO2/yr)"]
      coalemi_ttot_c <- toolAggregate(coalemi_ttot_R,map,coalweight)
      
      totalemi_ttot_R <- rundata[-which(getRegions(rundata)=="GLO"),getYears(weight),"Emi|CO2 (Mt CO2/yr)"]
      totalemi_ttot_c <- toolAggregate(totalemi_ttot_R,map,weight)
      
      endem_ttot_R <- rundata[-which(getRegions(rundata)=="GLO"),getYears(weight),"PE (EJ/yr)"]
      endem_ttot_c <- toolAggregate(endem_ttot_R,map,weight)
      
      ##### Derive output for implementation of policy coalition in REMIND #####
      coalshare_2030 <- new.magpie(map$CountryCode,years=NULL,names=NULL,fill=NA)
      coalshare_2050 <- new.magpie(map$CountryCode,years=NULL,names=NULL,fill=NA)
      OECDexit <- new.magpie(unique(map$RegionCode),years=NULL,names=NULL,fill=0)
       
      for (reg in unique(map$RegionCode)) {
        reg_oecd_members <- map$CountryCode[which(map$CountryCode %in% oecd_members & map$RegionCode==reg)]
        reg_members <- map$CountryCode[which(map$CountryCode %in% c(oecd_members,nonoecd_members) & map$RegionCode==reg)]
        reg_all <- map$CountryCode[which(map$RegionCode==reg)]
        # Apply coal phase-out constraint to a region if its PPCA members constitute >20% of total regional coal power demand and energy demand 
        if (length(reg_members)>0) {
          if (grepl("power",PPCA_pol)) {
            # OECD exit
            if (!grepl("non",phase[ii],ignore.case=TRUE) && length(reg_oecd_members>0) && 
                (length(reg_oecd_members)>1 | length(reg_all)==1) &&
                dimSums(dimSums(endem_ttot_c[reg_oecd_members,getYears(endem_ttot_c)>="y2030",],dim=1),dim=2) > 
                (pol_threshold * dimSums(dimSums(endem_ttot_c[reg_all,getYears(endem_ttot_c)>="y2030",],dim=1),dim=2)) &&
                dimSums(dimSums(coalgen_2030_c[reg_oecd_members,getYears(coalgen_2030_c)>="y2030",],dim=1),dim=2) > 
                (pol_threshold * dimSums(dimSums(coalgen_2030_c[reg_all,getYears(coalgen_2030_c)>="y2030",],dim=1),dim=2))) {
                  
              #Set 2030 coal power generation in coalition members to zero
              coalgen_2030_c[reg_oecd_members,getYears(coalgen_2030_c)>="y2030",] <- 1e-9
              # Calculate 2030 coal share in electricity or energy demand as output for REMIND policy implementation 
              # Set the policy stringency based on 2050 to allow room for the leakage
              coalshare_2030[reg_all,,] <- ifelse(length(reg_oecd_members)==length(reg_all),1,leakage_allowance) *
                toolNAreplace(dimSums(coalgen_2030_c[reg_all,getYears(coalgen_2030_c)>="y2030",],dim=2) /
                                dimSums(totalgen_2030_c[reg_all,getYears(totalgen_2030_c)>="y2030",],dim=2),replaceby=0)[[1]]
              OECDexit[reg,,] <- 1
            }else {
              coalshare_2030[reg_all,,] <- 0
            }
            # Non-OECD exit 
            if (OECDexit[reg,,]==1 | ((length(reg_members)>1 | length(reg_all)==1) &&
              dimSums(dimSums(endem_ttot_c[reg_members,getYears(endem_ttot_c)>="y2050",],dim=1),dim=2) > 
                (pol_threshold * dimSums(dimSums(endem_ttot_c[reg_all,getYears(endem_ttot_c)>="y2050",],dim=1),dim=2)) &&
                dimSums(dimSums(coalgen_2050_c[reg_members,getYears(coalgen_2050_c)>="y2050",],dim=1),dim=2) > 
                (pol_threshold * dimSums(dimSums(coalgen_2050_c[reg_all,getYears(coalgen_2050_c)>="y2050",],dim=1),dim=2)))) {
              #Set 2050 coal power generation in coalition members to zero
              coalgen_2050_c[reg_members,getYears(coalgen_2050_c)>="y2050",] <- 1e-9
              # Calculate 2050 coal share in electricity or energy demand as output for REMIND policy implementation 
              coalshare_2050[reg_all,,] <- ifelse(length(reg_members)==length(reg_all),1,leakage_allowance) *
                toolNAreplace(dimSums(coalgen_2050_c[reg_all,getYears(coalgen_2050_c)>="y2050",],dim=2) / 
                                dimSums(totalgen_2050_c[reg_all,getYears(totalgen_2050_c)>="y2050",],dim=2),replaceby=0)[[1]]
            }else {
              coalshare_2050[reg_all,,] <- 0
            }
          }else if (grepl("demand",PPCA_pol)) {
            # OECD exit
            if (!grepl("non",phase[ii],ignore.case=TRUE) && length(reg_oecd_members>0) && 
                (length(reg_oecd_members)>1 | length(reg_all)==1) &&
                dimSums(dimSums(coalemi_2030_c[reg_oecd_members,,],dim=1),dim=2) > 
                (pol_threshold * dimSums(dimSums(coalemi_2030_c[reg_all,,],dim=1),dim=2)) &&
                dimSums(dimSums(endem_ttot_c[reg_oecd_members,getYears(coalemi_2030_c),],dim=1),dim=2) > 
                (pol_threshold * dimSums(dimSums(endem_ttot_c[reg_all,getYears(coalemi_2030_c),],dim=1),dim=2))) {
                  #Set 2030 coal emissions in coalition members to zero
                  coalemi_2030_c[reg_oecd_members,,] <- 1e-9
                  # Calculate 2030 coal share in electricity or energy demand as output for REMIND policy implementation 
                  coalshare_2030[reg_all,,] <- ifelse(length(reg_oecd_members)==length(reg_all),1,leakage_allowance) *
                    toolNAreplace(dimSums(coalemi_2030_c[reg_all,,],dim=2) / 
                                    dimSums(totalemi_2030_c[reg_all,,],dim=2),replaceby=0)[[1]]
                  OECDexit[reg,,] <- 1
            }else {
              coalshare_2030[reg_all,,] <- 0
            }
            # Non-OECD exit 
            if (OECDexit[reg,,]==1 | ((length(reg_members)>1 | length(reg_all)==1) &&
              dimSums(dimSums(coalemi_2050_c[reg_members,,],dim=1),dim=2) > 
                (pol_threshold * dimSums(dimSums(coalemi_2050_c[reg_all,,],dim=1),dim=2)) &&
                dimSums(dimSums(endem_ttot_c[reg_members,getYears(coalemi_2050_c),],dim=1),dim=2) > 
                (pol_threshold * dimSums(dimSums(endem_ttot_c[reg_all,getYears(coalemi_2050_c),],dim=1),dim=2)))) {
              #Set 2050 coal emissions in coalition members to zero
              coalemi_2050_c[reg_members,,] <- 1e-9
              # Calculate 2050 coal share in electricity or energy demand as output for REMIND policy implementation 
              coalshare_2050[reg_all,,] <- ifelse(length(reg_members)==length(reg_all),1,leakage_allowance) *
                toolNAreplace(dimSums(coalemi_2050_c[reg_all,,],dim=2) / 
                                dimSums(totalemi_2050_c[reg_all,,],dim=2),replaceby=0)[[1]]
            }else {
              coalshare_2050[reg_all,,] <- 0
            }
          }
        }else {
          coalshare_2030[reg_all,,] <- 0
          coalshare_2050[reg_all,,] <- 0
        }
      }
        
      if (grepl("non",phase[ii],ignore.case=TRUE)) {
        out <- coalshare_2050
        getYears(out) <- NULL
        weight_out <- dimSums(weight[,getYears(weight)>="y2050",],dim=2)
      }else {
        out <- coalshare_2030
        for (country in map$CountryCode[which(!(map$CountryCode %in% c(oecd_members,nonoecd_members)))]) {
          if (coalshare_2050[country,,] > coalshare_2030[country,,] & coalshare_2030[country,,] > 0) {
            out[country,,] <- coalshare_2050[country,,]
          }
        }
        getYears(out) <- NULL
        weight_out <- dimSums(weight[,getYears(weight)>="y2030",],dim=2)
      }
      
      # Assign phase-out stringency based on coal demand type (for compatibility with REMIND bounds)
      if (grepl("power",PPCA_pol)) {
        getNames(out) <- NULL
        numTe <- 3
      }else if (grepl("steel",subpolicy[jj])) {
        getNames(out) <- "steel"
        numTe <- 1
      }else if (grepl("solids",subpolicy[jj])) {
        getNames(out) <- "solids"
        numTe <- 10
      }else if (grepl("demand",PPCA_pol)) {
        getNames(out) <- "demand"
        numTe <- 15
      }

      out[which(out>0 & out < 1e-6)] <- 1e-6
      
      ### RETURN POLICY STRINGENCY COEFFICIENTS TO REMIND INPUT FILES ###
      out_reg <- toolAggregate(out,rel=map,weight=weight_out)

      print(out_reg)

      file <- paste0(paste("f47",phase[ii],recovery,PPCA_pol,size,sep="_"),".cs4r")
      cat("Writing",file,"to ./modules/47_regipol/PPCAcoalExit/input/\n")
      write.magpie(out_reg,file_folder = "./modules/47_regipol/PPCAcoalExit/input/", file_name = file,append = ifelse(subpolicy[jj]=="none",FALSE,TRUE))
      write.magpie(out_reg,file_folder = outputfolder, file_name = file,append = ifelse(subpolicy[jj]=="none",FALSE,TRUE))
    }
  }
  setConfig(forcecache = F)
  
  #######################################################
  ### RETURN DYNAMIC FEASIBILITY SPACE (BUBBLE CHART) ###
  #######################################################
  if (!is.null(plot)) {  
    setConfig(forcecache = T)
    
    require(ggplot2)
    require(ggnewscale)
    require(ggrepel)
    require(stringr)
    require(dplyr)
    require(scales)
    require(readxl)
    require(countrycode)
    
    #Relevant regional mappings and country classifications
    #Current members of PPCA
    PPCAmap <- toolGetMapping("regionmappingPPCA.csv",type = "regional")
    ppca_map <- as.magpie(PPCAmap[,-1])
    #Current OECD members
    OECDmap <- toolGetMapping("regionmappingOECD.csv",type = "regional")
    oecd_map <- as.magpie(OECDmap[,-1])
    #REMIND 12 region mapping
    map <- toolGetMapping("regionmappingH12.csv",type="regional")
    
    ppca <- PPCAmap$CountryCode[which(PPCAmap$RegionCode=="PPCA")]
    oecd <- OECDmap$CountryCode[which(OECDmap$RegionCode=="OECD")]
    EU27 <- map$CountryCode[which(map$RegionCode=="EUR")]
    nonoecd <- OECDmap$CountryCode[which(OECDmap$RegionCode=="NON")]
    
    new_mem_july21 <- c("DEU","FJI","GRC",'HRV','HUN','ISR','MEX','MKD','MNE','PRT','VUT')
    
    newest_mem_cop26 <- c('UKR','CHL','SGP','MUS','AZE','SVN','EST')
    
    if (recovery=="Neutral")  recovery <- "BAU"
    
    ##Probability levels and line types
    if (!is.null(file)) {
      if (grepl("50CI",file))  p <- c(.25, 0.5, 0.75)
      else if (grepl("33CI",file))  p <- c(.33, 0.5, 0.67)
      else if (grepl("60CI",file))  p <- c(0.2, 0.5, 0.8)
      else if (grepl("70CI",file))  p <- c(0.15, 0.5, 0.85)
      else if (grepl("90CI",file))  p <- c(0.05, 0.5, 0.95)
      else  p <- c(0.05, 0.5, 0.95)
    }
    
    lts <- c("0.5" = 2, "0.05" = 3, "0.95" = 4)

    # Read file tracking the current status of the PPCA which contains GDPpc, % coal in electricity, 
    # standing coal power capacity, among other data
    #Country - 3-letter ISO country code
    #PPCA - PPCA membershp
    #PPCA.Bin (binary) - PPCA membership (1/0)
    #GDP.PC - GDP per capita (1000 USD)
    #Coal.Share - Share of coal in electricity supply
    #GW Capacity - total installed capacity of coal-fired fleet
    histData <- read.csv(paste0(getConfig("sourcefolder"),"/PPCA/PPCA_status_SSP2_2015.csv"),stringsAsFactors = F,sep = ",")

    #Logit regression of existing PPCA membership 
      
    logit_model <- glm(data = histData, PPCA.Bin ~  Coal.Share + GDP.PC , family = "binomial")
    
    ## Run COALogit subfunction to retrieve national coal shares, capacities, GDPpc
    # testData <- mrremind:::calcPPCA(phase=phase,policy=policy,subpolicy="none",recovery=recovery,size=size,run=run,subtype="bubble") 

    if (grepl("non",phase,ignore.case=T)) {
      testData <- nonOECD %>%
        mutate(Region = map$RegionCode) %>%
        mutate(Capacity = as.numeric(logit_coalcap_2045_c))
        
    } else {
      testData <- OECD %>%
        mutate(Region = map$RegionCode) %>%
        mutate(Capacity = as.numeric(cap_2025_c))
    }
    testData <- testData %>% 
      mutate(Face = ifelse(ppca=="PPCA", "bold.italic", "plain"))
    
    # print(testData %>% filter(Region=="OAS"))
    ## Sanity check test data 
    testData$share[which(testData$share>1)] <- max(testData$share[which(testData$share<1)])
    
    if (phase=="OECD" & recovery=="BAU") 
      testData <- testData %>% mutate(nudge = ifelse(country=="MAR",-0.02,ifelse(country=="CHN",0.065,0.025+Capacity/1.5e4)))
    # else if (grepl("non",phase,ignore.case=T))
    #   testData <- testData %>% mutate(nudge = ifelse(country=="CHN",0.065,0.025+Capacity/1.5e4))
    else
      testData <- testData %>% mutate(nudge = ifelse(country=="CHN",0.065,0.025+Capacity/1.5e4))

    
    # Derive intercept and slope of probability thresholds 
    ic <-  (log(1/p -1) -  logit_model$coefficients[1])/ logit_model$coefficients[3]
    slope <- -(logit_model$coefficients[2]/logit_model$coefficients[3])
    # All countries lying above this line are members of the given coalition scenario
    ln <- data.frame(Ic = ic, Slope = slope, Prob = as.character(p))
    
    plotData <- filter(testData,share>=1e-2)
    
    # if (grepl("non",phase,ignore.case=T)) {
    #   plotData <- filter(plotData,!(ppca=="PPCA" & oecd=="OECD"))
    # }  
    
    if (recovery=="BAU")  recovery <- "Neutral"
    
    
    plotData <- plotData %>% 
      mutate(country=ifelse(country %in% new_mem_july21,
                            paste0(country,"*"),
                            ifelse(country %in% newest_mem_cop26,
                                    paste0(country,"^"),
                                    as.character(country))))

    clrs <- c("OECD"="#E41A1C", "Non-OECD"="#789FC6","PPCA" = "goldenrod3", "Free" = "#000000")
    # colnames(plotData)[which(grepl("cap_",colnames(plotData)))] <- paste0("GW Capacity (",gsub("cap_","",colnames(plotData)[which(grepl("cap_",colnames(plotData)))]),")")
    
    year <- ifelse(phase=="OECD","2025","2045")
    
    size <- ifelse(size=="1p", "95p",
                    ifelse(size=="2p", "50p",
                          ifelse(size=="3p", "5p", "")))
    
    print(plotData)

    ggplot(plotData) + 
      #Shading
      geom_abline(intercept = seq(ln$Ic[1]+0.1,90,0.1),
                  slope = ln$Slope[1],
                  color="gold",alpha=0.06) +
      geom_abline(intercept = seq(ln$Ic[2]+0.1,(ln$Ic[1]-0.1),0.1),
                  slope = ln$Slope[2],
                  color="#CC3333",alpha=0.06) +
      geom_abline(intercept = seq(ln$Ic[3]+0.1,(ln$Ic[2]-0.1),0.1),
                  slope = ln$Slope[3],
                  color="blue",alpha=0.06) +
      geom_point(data = plotData,aes(x = share, y = gdp, color = oecd, size = Capacity),shape=16) +
      scale_color_manual(values = clrs, name="OECD Status (2021)",breaks=c("OECD","Non-OECD"),labels=c("OECD","Non-OECD"),guide=guide_legend(override.aes = list(size=5), order=3)) +
      new_scale_color() +
      
      #Labels
      geom_text_repel(data = plotData, 
                    aes(x = share, y = gdp, label = country, fontface = Face, color = ppca), 
                    size = 5.2, segment.size = 0.3, segment.alpha = 0.5, force = 5,nudge_x = plotData$nudge,max.overlaps = 80) +
      
      scale_color_manual(values = clrs, name="PPCA Status (July 2021)",breaks=c("PPCA","Free"),labels=c("PPCA","Freerider"),guide=guide_legend(override.aes = list(size=7,label="A"),order=4)) +
      guides(size=guide_legend(order=1),color=guide_legend(order=2,override.aes = list(size=2))) +
      
      #Probability lines
      new_scale_color() +
      geom_abline(data = ln, aes(intercept = Ic, slope = Slope, color = Prob),size = 0.4,alpha=0.4) +
      
      ##Special treatment of countries 'overshadowed' by bigger ones
      geom_point(data = filter(plotData, ifelse(phase=="OECD" & recovery=="Neutral", country %in% c("VNM"),
                                country %in% "")),
                  aes(x = share, y = gdp, size = Capacity), shape = 1, color = "black", stroke = 0.2) +

      ##Axis labels (and limits, if necessary)
      scale_x_continuous("% of coal in electricity supply", labels = percent, limits = c(0, 1)) +
      scale_y_continuous("GDP p.c. ($1000)",limits = c(0,80)) + 
      scale_color_manual(values=c("gold","#CC3333","blue"), 
                          name = "Coalition Scenario", 
                          labels=c(paste0("\u2265 ",p[3]*100,"% likely"),paste0("\u2265 ",p[2]*100,"% likely"),paste0("\u2265 ",p[1]*100,"% likely")),
                          guide=guide_legend(override.aes = list(size=5),order=2)) +
      theme_bw() +
      theme(panel.grid.minor = element_blank(),
            text = element_text(size=3.5*8.5),
            plot.title = element_text(face="bold",size=3.5*10,hjust=0.5),
            legend.text = element_text(size=3.5*6),
            legend.title = element_text(size=3.5*7)) +
      scale_size_continuous(range = 2.9*c(0.15, 13), breaks = c(10, 50, 250, 900),name=paste(ifelse(grepl("non",phase,ignore.case = T),"2045","2025"),"Capacity (GW)"),guide=guide_legend(order=1)) +
      labs(title = ifelse(grepl("REdir",run,ignore.case = T),
                          ifelse(grepl("non",phase,ignore.case = T),
                                  paste0("2045 PPCA Feasibility Space (G20", ifelse(grepl("oilgas",run)," + G7 "," "), "FinEx REdirect", ifelse(grepl("noMob",run),")"," + Mobilization)")),
                                  "2025 PPCA Feasibility Space (G20 Pledged FinEx)"),
                          ifelse(grepl("non",phase,ignore.case = T),
                                  paste("PPCA Feasibility Space",paste0("(",year),recovery,size,paste0(toupper(substr(PPCA_pol,1,1)),substr(PPCA_pol,2,nchar(PPCA_pol))),"Exit)"),
                                  paste("PPCA Feasibility Space",paste0("(",year),recovery,paste0(toupper(substr(PPCA_pol,1,1)),substr(PPCA_pol,2,nchar(PPCA_pol))),"Exit)"))))
    
      ggsave(paste(outputfolder,plot,sep="/"),width=6.3*3,height=4.63*3,units="in",dpi="retina")
      
    }
    setConfig(forcecache = F)

}
