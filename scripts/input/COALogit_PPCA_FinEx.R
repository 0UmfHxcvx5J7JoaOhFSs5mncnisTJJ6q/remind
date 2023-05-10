COALogit_PPCA_FinEx <- function(refgdx, recovery, size, PPCA_pol, oecd, nonoecd, outputfolder, title, rev=NULL, fin_pol="none", mob, uncertainty="90CI", run=NULL, plot=NULL) {
  require(stats, quietly = TRUE,warn.conflicts =FALSE)
  require(dplyr)
  require(madrat, quietly = TRUE,warn.conflicts =FALSE)
  require(mrremind, quietly = TRUE,warn.conflicts =FALSE)
  require(stringr, quietly = TRUE,warn.conflicts =FALSE)
  require(scales, quietly = TRUE,warn.conflicts =FALSE)
  require(readxl, quietly = TRUE,warn.conflicts =FALSE)
  require(countrycode, quietly = TRUE,warn.conflicts =FALSE)
  
  # Set configuration specific to snapshot of input data used in publication 
  if (!is.null(rev)) cachedir <- paste0("/p/projects/rd3mod/inputdata/cache/",rev)
  else  cachedir <- "/p/tmp/stephenb/cache/SB_GCPT"
  setConfig(cachefolder = cachedir)
  setConfig(outputfolder = outputfolder)
  setConfig(forcecache = T)
  options(error=recover)
  
  source("scripts/input/readGCPT_finEx.R")

  ##########################################
  ### PPCA policy implementation params ####
  ###########################################
  pol_threshold <- 0.2      # REMIND regions only enforce the policy if its member nations comprise over a threshold share of regional energy and electricity demand
  leakage_allowance <- 1.5  # Freeriders in multi-national regions can increase coal consumption by 50% above reference
  p <- c(0.95, 0.5, 0.05)   # Probability thresholds for coalition accession 
  EJ_2_TWh <- 277777.77778

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
    timestep <- 2045
  }else if (oecd=="on") {
    phase <- "OECD"
    timestep <- 2025
  }

#   if (grepl("_2030",mob))  mob <- gsub("_2030","",mob)

  ## Neutral Covid recovery is named BAU in previously written functions (e.g. mrremind:::readGCPT)
  if (recovery=="Neutral")  recovery <- "BAU"
  
  if (is.null(run)) {
    mif <- strsplit(strsplit(refgdx,"output/",fixed=T)[[1]][2],"_202[0-9]",fixed=F)[[1]][1]
    mif <- paste0("REMIND_generic_",mif,"_withoutPlus.mif")
    run <- gsub("fulldata.gdx",mif,refgdx)
    cat("Retrieving data from",run,"\n")
  }

  #Relevant regional mappings and country classifications
  #REMIND 12 region mapping
  map <- toolGetMapping("regionmappingH12.csv",type="regional")
  EU27 <- map$CountryCode[which(map$RegionCode=="EUR")]

  #Current members of PPCA
  PPCAmap <- toolGetMapping("regionmappingPPCA_cop26.csv",type = "regional")
  ppca_map <- new.magpie(PPCAmap$CountryCode,years=NULL,names=NULL,PPCAmap$RegionCode)
  ppca <- PPCAmap$CountryCode[which(PPCAmap$RegionCode=="PPCA")]
  
  #Current OECD members
  OECDmap <- toolGetMapping("regionmappingOECD.csv",type = "regional")
  # Include all EU members in OECD, as specified by PPCA
  OECDmap <- OECDmap %>% 
    mutate(RegionCode = ifelse(CountryCode %in% EU27, 
                                "OECD",
                                RegionCode))  
  oecd <- OECDmap$CountryCode[which(OECDmap$RegionCode=="OECD")]
  non_oecd <- setdiff(map$CountryCode, oecd)
  
  oecd_map <- OECDmap$RegionCode
  
  print("plot")
  print(plot)

  if (plot != "only") {
    # Read historical energy demand from newest IEA data 
    setConfig(cachefolder = "/p/tmp/stephenb/cache/IEA_2021/IEA")
    # io <- calcOutput("IO",subtype="input",aggregate=F)
    
    #Read historical electricity generation
    data <- readSource("IEA",subtype="EnergyBalances") * 0.0000418680000
    # setConfig(forcecache = F)
    totalgen_c_hist <- data[,,"TOTAL.ELOUTPUT"]
    totalgen_R_hist <- toolAggregate(totalgen_c_hist,map,NULL)
    
    totalgen_2019_c <- totalgen_c_hist[,2019,]
    totalgen_2019_R <- toolAggregate(totalgen_R_hist[,2019,],map,NULL)
    
    #Read historical coal power generation
    coalvars <- c("BITCOAL", "ANTCOAL", "SUBCOAL", "COKCOAL", "LIGNITE")
    coalgen <- data[,2019,paste0(coalvars,".ELOUTPUT")]
    # coalgen <- data[,seq(2000,2019,5),paste0(coalvars,".ELOUTPUT")]
    coalgen <- dimSums(coalgen,dim=3)
    coalgen_2019_c <- coalgen[,2019,]
    coalgen_2019_R <- toolAggregate(toolAggregate(coalgen_2019_c,map,NULL),map,NULL)

    loadfactor_c <- calcOutput("CapacityFactor",aggregate=F)[,c(2025,2045),"pc"]
    loadfactor_R <- calcOutput("CapacityFactor")[,c(2025,2045),"pc"]
    
    #SSP2 GDP per capita
    gdppc <- 1e-3 * calcOutput("GDPpc",aggregate=F, average2020 = FALSE, FiveYearSteps = FALSE)
    gdppc <- gdppc[,,getItems(gdppc,3)[which(grepl("SSP2EU",getItems(gdppc,3)))]]

    ### Loop over the OECD and non-OECD phase of PPCA accession (only done in the PPCA-current runs)
    for (ii in 1:length(phase)) {

        ### For demand-exit runs, loop over the subsets of coal demand being phased out (i.e. non-solids, solids, metallurgical solids)
        for (jj in 1:length(subpolicy)) {

        #Read output from preceding REMIND run in the DPE process
        rundata <- read.report(run,as.list=F)
        rundata <- rundata[,getYears(rundata)<="y2100",]
        
        #Assign regional load factors to countries with no historical capacity
        # for (y in getYears(loadfactor_c)) {
        #   loadfactor_c[,y,][which(hist_cap_c[,y,]==0 & cap_2019_c[,,"Green"]==0)] <- 0
        #   
        #   loadfactor_c[,y,][which(hist_cap_c[,y,]==0 & cap_2025_c[,,"Brown"]!=0)] <-
        #     loadfactor_R[,y,][map$RegionCode[which(map$CountryCode %in% getItems(dim = 1,  x = loadfactor_c[which(hist_cap_c[,y,]==0 & cap_2025_c[,,"Brown"]!=0)]))],,]
        # }
        
        if (is.null(recovery)) {
            recovery <- gsub(".mif","",strsplit(run,"-")[[1]][length(strsplit(run,"-")[[1]])])
            if (!(recovery %in% c("BAU","Brown","Green"))) {
            recovery <- "none"
            }
        }
                    
        # setConfig(forcecache = T)
        #Historical Population
        popPast <- calcOutput("PopulationPast",aggregate=F)
        #SSP2 Population
        popC <- calcOutput("Population",aggregate=F,years = getYears(rundata)[which(getYears(rundata)>"y2015")])[,,"pop_SSP2"]
        popR <- toolAggregate(popC,map,NULL)
                
        popGrowth <- popC[,getYears(popC)>"y2015",] - popPast[,2019,]
        getYears(popGrowth) <- gsub(".y2019","",getYears(popGrowth))
        
        weight <- new.magpie(getItems(dim = 1,  x = popC),getYears(popGrowth),fill=0)
        # Aggregation weights for downscaling regional model output (and re-aggregating)
        for (yr in getYears(weight)) {
            weight[,yr,] <- data[,2019,"TOTAL.ELOUTPUT"] + 
            ifelse(data[,2019,"TOTAL.ELOUTPUT"] + (data[,2019,"TOTAL.ELOUTPUT"]/popPast[,2019,]) * popGrowth[,yr,] >= 0,
                    (data[,2019,"TOTAL.ELOUTPUT"]/popPast[,2019,]) * popGrowth[,yr,], 0)
        }
        getYears(weight) <- getYears(popGrowth)
        
        # Aggregation weights for downscaling coal variables are the same as for energy/electricity demand 
        # except countries with no historical or planned coal demand are given zero weights.
        # setConfig(cachefolder = cachedir)
        setConfig(forcecache = FALSE)        
        pipeline <- readSource("GCPT",subtype="status",convert=F)
        zero_pipe_reg <- getItems(dim = 1,  x = pipeline)[which(dimSums(pipeline[,,c("Announced","Pre-permit","Permitted","Construction","Shelved","Operating")],dim=3)==0)]
        
        #####################################
        ## Coal share downscaling function ##
        #####################################
        downscale_coal <- function(coal_c_t1,total_c_t1,coal_R_t1,total_R_t1,coal_R_t2,total_R_t2,REdir_c=NULL) {
            # Make sure all arguments are at country level (for regional variables, assign each country its region's value) 
            if (length(getItems(dim = 1,  x = coal_R_t1))<length(getItems(dim = 1,  x = coal_c_t1)))  
            coal_R_t1 <- toolAggregate(coal_R_t1[-which(getItems(dim = 1,  x = coal_R_t1)=="GLO"),,],map,NULL)
            if (length(getItems(dim = 1,  x = total_R_t1))<length(getItems(dim = 1,  x = coal_c_t1)))  
                total_R_t1 <- toolAggregate(total_R_t1[-which(getItems(dim = 1,  x = total_R_t1)=="GLO"),,],map,NULL)
            if (length(getItems(dim = 1,  x = coal_R_t2))<length(getItems(dim = 1,  x = coal_c_t1)))  
                coal_R_t2 <- toolAggregate(coal_R_t2[-which(getItems(dim = 1,  x = coal_R_t2)=="GLO"),,],map,NULL)
            if (length(getItems(dim = 1,  x = total_R_t2))<length(getItems(dim = 1,  x = coal_c_t1)))  
                total_R_t2 <- toolAggregate(total_R_t2[-which(getItems(dim = 1,  x = total_R_t2)=="GLO"),,],map,NULL)
            
            # In REdirect scenarios, offset coal share in t1 by appropriate amount
            # if (!is.null(REdir_c)) {
            #     # redir_hosts <- getItems(which(REdir_c > 0)
            #     coal_c_t1[which(REdir_c > 0),,] <- coal_c_t1[which(REdir_c > 0),,] - REdir_c[which(REdir_c > 0),,]
            # }        
            # Define known national (t1) and regional (t1 and t2) coal-power-shares
            share_c_t1 <- replace_non_finite(coal_c_t1/total_c_t1,replace=0)
            share_R_t1 <- replace_non_finite(coal_R_t1/total_R_t1,replace=0)
            share_R_t2 <- replace_non_finite(coal_R_t2/total_R_t2,replace=0)
            # Initialize new variable for national coal-power-shares in t2
            share_c_t2 <- new.magpie(getItems(dim = 1,  x = coal_c_t1),getYears(coal_R_t2),getNames(coal_c_t1),fill=0)
            for (reg in unique(map$RegionCode)) {
            reg_all <- map$CountryCode[which(map$RegionCode==reg)]
            # Only apply function to multinational regions
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
        
        ###################################################
        ### Extrapolate or downscale 2025 coal capacity ###
        ###################################################
        # setConfig(cachefolder = "/p/projects/rd3mod/inputdata/cache/default/")
        setConfig(forcecache = FALSE)
        ## Read historical data
        hist_cap_c <- readSource("GCPT",subtype="historical")
        print("hist_cap_c")
        print(hist_cap_c)
        hist_cap_R <- toolAggregate(hist_cap_c,rel=map,weight=NULL)
        
        ## Total Electricity generation 2025 
        # Regional data from REMIND output
        totalgen_2025_R <- rundata[,"y2025","SE|Electricity (EJ/yr)"]
        # Downscale regional REMIND results to national level using disaggregation weight defined above
        totalgen_2025_c <- magpiesort(
            toolAggregate(totalgen_2025_R[-which(getItems(dim = 1,  x = totalgen_2025_R)=="GLO"),,],map,weight[,getYears(totalgen_2025_R),])
        )
        ## 2025 coal power generation
        # Scenarios not fixed to Covid- or FinEx-related coal capacity constraint in 2025
        if (recovery=="none") {
            coalgen_2025_R <- rundata[,"y2025","SE|Electricity|Coal (EJ/yr)"]
            coalgen_2025_R <- magpiesort(
                toolAggregate(coalgen_2025_R[-which(getItems(dim = 1,  x = coalgen_2025_R)=="GLO"),,],map,NULL)
            )
            # Downscale coal generation based on 2019 coal share
            coalgen_2025_c <- downscale_coal(coalgen_2019_c, totalgen_2019_c, coalgen_2019_R, totalgen_2019_R, coalgen_2025_R, totalgen_2025_R)
            coalgen_2025_R <- toolAggregate(coalgen_2025_c,map,NULL)
            
            # Derive 2025 capacity from rundata and load factor assumptions
            cap_2025_c <- coalgen_2025_c / (loadfactor_c[,2025,] * 365*24 / EJ_2_TWh)
            print(paste("cap_2025_c: ", cap_2025_c))
            getYears(cap_2025_c) <- "y2025"
            cap_2025_c[which(hist_cap_c[,2019,]==0 & coalgen_2025_c==0)] <- 0
        
        # REdirect scenarios use FinEx coal capacity constraint only as upper bound 
        }else {
            if (grepl("REdirect", fin_pol, ignore.case = T) | grepl("FinEx", fin_pol, ignore.case = T)) {
                coalgen_2025_R <- rundata[, "y2025", "SE|Electricity|Coal (EJ/yr)"]
                print("\ncoalgen_2025_R: ")
                print(coalgen_2025_R)
                
                coalgen_2025_R <- magpiesort(
                    toolAggregate(coalgen_2025_R[-which(getItems(dim = 1,  x = coalgen_2025_R)=="GLO"),,], map, NULL)
                )
                print("\nDisaggregated coalgen_2025_R: ")
                print(coalgen_2025_R)

                finEx_cap_2025_c <- readGCPT_finEx(subtype = "G20_FinEx_2021")[,,recovery]
                print("\nfinEx_cap_2025_R: ")
                print(toolAggregate(finEx_cap_2025_c,map,NULL))    
                           
                finEx_cap_2025_R <- toolAggregate(toolAggregate(finEx_cap_2025_c,map,NULL),map,NULL)
                print("\nDisaggregated finEx_cap_2025_R: ")
                print(finEx_cap_2025_R)

                finEx_coalgen_2025_c <- finEx_cap_2025_c * loadfactor_c[,2025,] * (365*24) / EJ_2_TWh 
                finEx_coalgen_2025_R <- toolAggregate(toolAggregate(finEx_coalgen_2025_c,map,NULL),map,NULL)
                print("\nfinEx_coalgen_2025_R")
                print(finEx_coalgen_2025_R)

                diff_REdir_coalgen_R <- finEx_coalgen_2025_R - coalgen_2025_R
                print("\ndiff_REdir_coalgen_R")
                print(diff_REdir_coalgen_R)

                if (mob == "none" | mob == "OECD") {
                    mobil <- "oecd"
                }else if (grepl("lo",mob)) {
                    mobil <- "LO_oecd"
                }else if (grepl("hi",mob)) {
                    mobil <- "HI_oecd"
                }

                redir_c <- read.magpie(paste0("./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_", mobil, "_nat_mob_country.cs4r")) 
                # redir_R <- read.magpie(paste0("./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_", mob, "_nat_mob.cs4r")) 
                redir_R <- toolAggregate(toolAggregate(redir_c, map, NULL), map, NULL)

                redir_share_c <- replace_non_finite(redir_c / redir_R, replace = 0)
                print("\nredir_share_c")
                print(redir_share_c)
                        
                coalgen_2025_c <- finEx_coalgen_2025_c - (redir_share_c * diff_REdir_coalgen_R)
                print("\ncoalgen_2025_c after REdir:")
                print(coalgen_2025_c)

                cap_2025_c <- coalgen_2025_c / (loadfactor_c[,2025,] * (365*24) / EJ_2_TWh)
                print("\ncap_2025_c after REdir:")
                print(cap_2025_c)

            # Cases with fixed 2025 capacity due to Covid recovery or FinEx scenario
            # }else if (fin_pol=="FinEx") {
            #     cap_2025_c <- readGCPT_finEx(subtype = "G20_FinEx_2021")[,,recovery]
            }else {
            # if (fin_pol=="none" | fin_pol=="") {
                print("fin_pol")
                print(fin_pol)
                
                #Read coal capacity data from GCPT for the given COVID recovery scenario
                # cap_2025_c <- readSource("GCPT",subtype="future2021",convert=F)[,,recovery]
                # setConfig(cachefolder = "/p/projects/rd3mod/inputdata/cache/default/")
                cap_2025_c <- readGCPT_finEx(subtype="future2021")[,,recovery]

                #Derive 2025 coal generation in exajoules from coal capacity and default REMIND country-level load factor assumptions
                coalgen_2025_c <- cap_2025_c * loadfactor_c[,2025,] *365*24 / EJ_2_TWh
                coalgen_2025_c[which(hist_cap_c[,2019,]==0 & cap_2025_c==0)] <- 0
                #Aggregate results to regional level
                coalgen_2025_R <- toolAggregate(toolAggregate(coalgen_2025_c,map,NULL),map,NULL)   
            }

            # if (fin_pol == "PPCA")
            fin_pol <- unlist(strsplit(fin_pol, "_"))[1]
            # Aggregate capacity to REMIND regional level and report for sanity check
            cap_R_2025 <- toolAggregate(cap_2025_c,rel=map,weight=NULL)

        }
        getYears(coalgen_2025_c) <- "y2025"

        ### Safeguard in case downscaling results in countries with coal power share >100% ###
        # Loop over regions
        for (reg in unique(map$RegionCode)) {
            # All countries in reg
            reg_all <- map$CountryCode[which(map$RegionCode==reg)]

            # Countries with coal generation < 0           
            reg_neg <- reg_all[which(coalgen_2025_c[reg_all,,] < 0)]
            print("\nreg_neg")
            print(reg_neg)

            # Countries with nonzero coal generation
            reg_nonzero <- reg_all[which(totalgen_2025_c[reg_all,,] > 0)]

            if (length(reg_neg)) {
                # Each nonzero coal country's share of all the region's nonzero coal countries' total electricity generation
                reg_nonzero_normalized <- totalgen_2025_c[setdiff(reg_nonzero, reg_neg),,] /
                    as.numeric(dimSums(totalgen_2025_c[setdiff(reg_nonzero, reg_neg),,], dim = 1))
                
                deficit <- -as.numeric(dimSums(coalgen_2025_c[reg_neg,,], dim = 1))
                print("\ndeficit:")
                print(deficit)

                coalgen_2025_c[reg_neg,,] <- 0

                coalgen_2025_c[setdiff(reg_nonzero, reg_neg),,] <- coalgen_2025_c[setdiff(reg_nonzero, reg_neg),,] + deficit * reg_nonzero_normalized
            }

            # Countries with coal share >100%
            reg_excess <- reg_all[which(coalgen_2025_c[reg_all,,] / totalgen_2025_c[reg_all,,] > 1)]
            print(reg_excess)
                        
            while (length(reg_excess)) {
                # Each country's share of the region's total electricity generation
                reg_normalized <- totalgen_2025_c[reg_all,,] /
                    as.numeric(totalgen_2025_R[reg,,])

                # Increase total electricity generation in >100% coal-share countries so that their coal-share equals the max of all countries above the mean total electricity generation level in 2019
                max_coalshare <- as.numeric(max(coalgen_2019_c[getItems(coalgen_2019_c,dim=1)[which(totalgen_2019_c > mean(as.numeric(totalgen_2019_c)))],,] / 
                                                totalgen_2019_c[getItems(totalgen_2019_c,dim=1)[which(totalgen_2019_c > mean(as.numeric(totalgen_2019_c)))],,], na.rm = T))
                print("\nmax 2019 coal share:")
                print(as.numeric(max_coalshare))
                
                totalgen_2025_c[reg_excess,,] <- coalgen_2025_c[reg_excess,,] / max_coalshare

                print("\ntotalgen_2025_c[reg_excess,,]:")
                print(totalgen_2025_c[reg_excess,,])

                # Resulting excess power generation in region 
                excess <- as.numeric(dimSums(totalgen_2025_c[reg_all,,],dim=1) - as.numeric(totalgen_2025_R[reg,,]))
                # as.numeric(dimSums(coalgen_2025_c[reg_excess,,] - totalgen_2025_c[reg_excess,,], dim=1)
                print("\nexcess 2025:")
                print(excess)

                # Decrease total electricity generation in all other countries in the region by the proportional amount 
                totalgen_2025_c[setdiff(reg_all, reg_excess),,] <- totalgen_2025_c[setdiff(reg_all, reg_excess),,] - 
                                                                    excess * (reg_normalized[setdiff(reg_all, reg_excess),,] / as.numeric(dimSums(reg_normalized[setdiff(reg_all, reg_excess),,],dim=1)))
                print("\ntotalgen_2025_c[setdiff(reg_all, reg_excess),,]:")
                print(totalgen_2025_c[setdiff(reg_all, reg_excess),,])
                # totalgen_2025_c[setdiff(reg_all, reg_excess),,] <- totalgen_2025_c[setdiff(reg_all, reg_excess),,] - excess * reg_normalized[setdiff(reg_all, reg_excess),,]
                # / length(setdiff(reg_all, reg_excess)) 
                
                # Transfer a proportional amount of the rest of the region's electricity generation to each excess country
                # totalgen_2025_c[reg_excess,,] <- totalgen_2025_c[reg_excess,,] +  excess * reg_normalized[reg_excess,,]  
                # / length(reg_excess) 
                # reg_normalized[reg_excess,,] * as.numeric(dimSums(excess * reg_normalized[setdiff(reg_all, reg_excess),,], dim = 1))

                # print("\nreg_nonzero coal share:") 
                # print(coalgen_2025_c[reg_nonzero,,] / totalgen_2025_c[reg_nonzero,,])
                
                reg_excess <- reg_all[which(coalgen_2025_c[reg_all,,]/totalgen_2025_c[reg_all,,] > 1.001)]

                print("\nreg_excess coal share:") 
                print(coalgen_2025_c[reg_excess,,] / totalgen_2025_c[reg_excess,,])            
            }
        }
        getYears(totalgen_2025_c) <- "y2025"

        #Derive country-level coal shares
        coalShare_2025_c <- replace_non_finite(coalgen_2025_c/totalgen_2025_c,replace = 0)
            # print("coalgen_2025_c")
            # print(coalgen_2025_c)
            # print("totalgen_2025_c")
            # print(totalgen_2025_c)

        if (grepl("current",size)) {

        #########################################
        ########## DEFINE CURRENT PPCA ##########
        #########################################
            #The PPCA stipulates that OECD and EU members must phase out coal power by 2030
            oecd_members <- intersect(ppca,oecd)
            #While non-OECD members must phase out coal power by 2050
            nonoecd_members <- intersect(ppca,non_oecd)

        }else {

            #################################################
            ################## LOGIT MODEL ##################
            #################################################
            # Read file tracking the current status of the PPCA which contains GDPpc, % coal in electricity, 
            # standing coal power capacity, among other data
            histData <- read.csv(paste0(getConfig("sourcefolder"),"/PPCA/PPCA_status_COP26_combo_16_19.csv"),stringsAsFactors = F,sep = ",")
            # histData <- read.csv(paste0(getConfig("sourcefolder"),"/PPCA/PPCA_status_SSP2_2015.csv"),stringsAsFactors = F,sep = ",")
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
            
            #######################################################
            ### Derive present day PPCA accession probabilities ###
            #######################################################
            current_status <- data.frame(country=sort(map$CountryCode),
                                    oecd=as.character(oecd_map),
                                    ppca=as.character(ppca_map),
                                    gen=as.numeric(coalgen_2019_c),
                                    gdp=as.numeric(gdppc[,2019,]),
                                    share=as.numeric(coalgen_2019_c / totalgen_2019_c)) %>%
                            ### Run logit model on 2019 data to get current accession probabilities ###
                            mutate(accession_prob = predict(object = logit_model, 
                                                            newdata = data.frame(Coal.Share=share,GDP.PC=gdp),
                                                            type = "response"),
                                    Region=map$RegionCode[order(map$CountryCode)])

            current_oecd <- current_status %>% filter(ppca == "Free")
            current_oecd_top10 <- current_oecd %>% filter(oecd == "OECD") %>% filter(gen %in% tail(sort(gen), 10))

            current_nonoecd <- current_status %>% filter(accession_prob < 0.5 & oecd == "Non-OECD" & ppca == "Free")
            
            getNames(coalShare_2025_c) <- recovery
            getYears(coalShare_2025_c) <- "y2025"
            ### New data frame containing 2025 data for logit analysis
            OECD <- data.frame(country=sort(getItems(dim = 1,  x = coalShare_2025_c)),
                            oecd=as.character(oecd_map),
                            ppca=as.character(ppca_map),
                            gdp=as.numeric(gdppc[,2025,]),
                            share=as.numeric(coalShare_2025_c)) %>%
                    ### Run logit model on 2025 data to get OECD nations' accession probabilities ###
                    mutate(accession_prob = predict(object = logit_model, 
                                                    newdata = data.frame(Coal.Share=share,GDP.PC=gdp),
                                                    type = "response"),
                            Region=map$RegionCode[order(map$CountryCode)])

            ##########################################
            ### Determine OECD coalition scenarios ###
            ##########################################
            OECD <- OECD %>% mutate(coalition=ifelse(accession_prob >= p[2] & oecd=="OECD",
                                                    "50p", "free"))
            # OECD <- OECD %>% mutate(coalition = ifelse(accession_prob >= p[3] & oecd=="OECD",
            #                                         "5p", "free"))
            # OECD <- OECD %>% mutate(coalition=ifelse(accession_prob >= p[2] & oecd=="OECD",
            #                                         "50p", coalition))
            # OECD <- OECD %>% mutate(coalition=ifelse((accession_prob >= p[1] | ppca=="PPCA") & (oecd=="OECD" | Region=="EUR"),
            #                                         "95p", coalition))
            
            #             print("OECD")
            # print(OECD)

            #OECD coalition
            # oecd_95p <- OECD %>% filter(coalition=="95p") %>% select(country)
            oecd_50p <- OECD %>% filter(coalition %in% c("95p","50p")) %>% select(country)
            # oecd_5p <- OECD %>% filter(coalition %in% c("95p","50p","5p")) %>% select(country)
            
            # if (grepl("coalitions",subtype) & !grepl("non",phase[ii],ignore.case=TRUE)) {
            # return(list(oecd95p=oecd_95p,oecd50p=oecd_50p,oecd5p=oecd_5p))
            # }
            
            # Coalitions were originally named 1p, 2p, 3p
            if (grepl("50p",size) | grepl("2p",size)) {
            oecd_members <- as.character(oecd_50p[,1])
            }else if (grepl("95p",size) | grepl("1p",size)) {
            oecd_members <- as.character(oecd_95p[,1])
            }else if (grepl("5p",size) | grepl("3p",size)) {
            oecd_members <- as.character(oecd_5p[,1])
            }
        }

        ################################################
        ########### POWER EXIT REMIND DATA #############
        ################################################
        
        # Use regional downscaling of REMIND results to derive country-level coal and total electricity generation in 2030
        coalgen_2030_R <- rundata[,getYears(rundata)>="y2030","SE|Electricity|Coal (EJ/yr)"]
        coalgen_2030_R <- magpiesort(
            toolAggregate(coalgen_2030_R[-which(getItems(dim = 1,  x = coalgen_2030_R)=="GLO"),,],map,NULL)
        )
        totalgen_2030_R <- rundata[,getYears(rundata)>="y2030","SE|Electricity (EJ/yr)"]
        totalgen_2030_c <- magpiesort(
            toolAggregate(totalgen_2030_R[-which(getItems(dim = 1,  x = totalgen_2030_R)=="GLO"),,],map,weight[,getYears(totalgen_2030_R),])
        )
        # Apply downscale formula to derive 2030 coal generation by country
        coalshare_2030_c <- downscale_coal(coalgen_2025_c,totalgen_2025_c,coalgen_2025_R,totalgen_2025_R,coalgen_2030_R,totalgen_2030_R)
        coalgen_2030_c <- coalshare_2030_c * totalgen_2030_c
        #Read 2045 total electricity generation from appropriate OECD phase-out REMIND scenario
        totalgen_2045_R <- rundata[,"y2045","SE|Electricity (EJ/yr)"]
        totalgen_2045_c <- magpiesort(
            toolAggregate(totalgen_2045_R[-which(getItems(dim = 1,  x = totalgen_2045_R)=="GLO"),,],map,weight[,getYears(totalgen_2045_R),])
        )
        
        coalgen_2045_R <- rundata[,"y2045","SE|Electricity|Coal (EJ/yr)"]
        coalgen_2045_R <- magpiesort(
            toolAggregate(coalgen_2045_R[-which(getItems(dim = 1,  x = coalgen_2045_R)=="GLO"),,],map,NULL)
        )
        #Read 2050 total electricity generation from appropriate OECD phase-out REMIND scenario
        totalgen_2050_R <- rundata[,getYears(rundata)>="y2050","SE|Electricity (EJ/yr)"]
        totalgen_2050_c <- magpiesort(
            toolAggregate(totalgen_2050_R[-which(getItems(dim = 1,  x = totalgen_2050_R)=="GLO"),,],map,weight[,getYears(totalgen_2050_R),])
        )
        coalgen_2050_R <- rundata[,getYears(rundata)>="y2050","SE|Electricity|Coal (EJ/yr)"]
        coalgen_2050_R <- magpiesort(
            toolAggregate(coalgen_2050_R[-which(getItems(dim = 1,  x = coalgen_2050_R)=="GLO"),,],map,NULL)
        )        
        ##################################################
        ### 2045 COAL SHARE IN ELECTRICITY CALCULATION ###
        ##################################################
        logit_coalgen_2030_c <- coalgen_2030_c[,"y2030",]
        for (reg in unique(map$RegionCode)) {
            reg_oecd_members <- map$CountryCode[which(map$CountryCode %in% oecd_members & map$RegionCode==reg)]
            reg_all <- map$CountryCode[which(map$RegionCode==reg)]
            reg_freeriders <- setdiff(reg_all,reg_oecd_members)
            reg_nonzero_freeriders <- getItems(dim = 1,  x = logit_coalgen_2030_c[reg_freeriders,,])[which(logit_coalgen_2030_c[reg_freeriders,,]>0)]
            
            # Set OECD PPCA members' 2030 coal share to 0
            logit_coalgen_2030_c[reg_oecd_members,,] <- 0 
            
            ## If there are both OECD PPCA members and freeriders in the region, distribute the PPCA members' coal to the freeriders
            if (length(reg_oecd_members) & length(reg_nonzero_freeriders)) {
            # Each country's share of the region's total electricity generation
            reg_normalized <- totalgen_2030_c[reg_all,"y2030",] / as.numeric(totalgen_2030_R[reg,2030,])

            # Each nonzero freerider's share of all nonzero freeriders' total electricity generation
            reg_normalized_nzfree <- totalgen_2030_c[reg_nonzero_freeriders,"y2030",] / as.numeric(totalgen_2030_R[reg,2030,])

            logit_coalgen_2030_c[reg_nonzero_freeriders,,] <- logit_coalgen_2030_c[reg_nonzero_freeriders,,] + 
                as.numeric(dimSums(coalgen_2030_c[reg_oecd_members,"y2030",]-logit_coalgen_2030_c[reg_oecd_members,,],dim=1)) * reg_normalized_nzfree
            
            logit_coalshare_2030_c <- logit_coalgen_2030_c / totalgen_2030_c[,"y2030",]
            
            reg_excess <- reg_nonzero_freeriders[which(logit_coalshare_2030_c[reg_nonzero_freeriders,,] > 1)]


            ## If the redistribution of coal results in other countries with >100% share in coal...
            while (length(reg_excess)) {
                # Increase total electricity generation in >100% coal-share countries so that their coal-share equals the global max in 2019
                totalgen_2030_c[reg_excess,,] <- logit_coalgen_2030_c[reg_excess,,] / max(coalgen_2019_c / totalgen_2019_c, na.rm = T)

                # Resulting excess power generation in region 
                excess <- as.numeric(dimSums(totalgen_2030_c[reg_all,,],dim=1) - as.numeric(totalgen_2030_R[reg,2030,]))
                # as.numeric(dimSums(logit_coalgen_2030_c[reg_excess,,] - totalgen_2030_c[reg_excess,,], dim=1))
                print("\nexcess 2030:")
                print(excess)

                # Decrease total electricity generation in all other countries in the region by the proportional amount 
                totalgen_2030_c[setdiff(reg_all, reg_excess),,] <- totalgen_2030_c[setdiff(reg_all, reg_excess),,] - 
                                                                    excess * (reg_normalized[setdiff(reg_all, reg_excess),,] / 
                                                                            as.numeric(dimSums(reg_normalized[setdiff(reg_all, reg_excess),,],dim=1)))


                # excess <- as.numeric(dimSums(logit_coalgen_2030_c[reg_excess,,] - totalgen_2030_c[reg_excess,,], dim=1))
                # print("\nexcess 2030:")
                # print(excess)

                # Decrease total electricity generation in all other nonzero countries by the proportional amount 
                # totalgen_2030_c[setdiff(reg_nonzero_freeriders, reg_excess),,] <- totalgen_2030_c[setdiff(reg_nonzero_freeriders, reg_excess),,] - excess * reg_normalized_nzfree[setdiff(reg_nonzero_freeriders, reg_excess),,]
                # / length(setdiff(reg_all, reg_excess)) 
                # (1 - reg_normalized_nzfree[setdiff(reg_all, reg_excess),,])

                # Transfer a proportional amount of the rest of the region's electricity generation to each excess country
                # totalgen_2030_c[reg_excess,,] <- totalgen_2030_c[reg_excess,,] + excess * reg_normalized_nzfree[reg_excess,,]
                # / length(reg_excess)
                # totalgen_2030_c[reg_excess,,] <- totalgen_2030_c[reg_excess,,] + reg_normalized_nzfree[reg_excess,,] * as.numeric(dimSums(excess * (1 - reg_normalized_nzfree[setdiff(reg_all, reg_excess),,]), dim = 1))

                # logit_coalgen_2030_c[reg_excess,,] <- leakage_allowance * coalgen_2030_c[reg_excess,"y2030",]
                logit_coalshare_2030_c[reg_all,,] <- logit_coalgen_2030_c[reg_all,,] / totalgen_2030_c[reg_all,"y2030",]

                # Check if any are still over 100% 
                reg_excess <- reg_excess[which(logit_coalshare_2030_c[reg_excess,,] > 1.001)]

                print("\nreg_excess coal share 2030:")
                print(logit_coalshare_2030_c[reg_excess,,])

                reg_normalized_nzfree <- totalgen_2030_c[reg_all,"y2030",] / as.numeric(totalgen_2030_R[reg,2030,])

            }
            }
        }
        
        # Derive 2045 coal share in electricity for use in logistic regression
        logit_coalShare_2045_c <- downscale_coal(logit_coalgen_2030_c,totalgen_2030_c[,"y2030",],coalgen_2030_R[,"y2030",],totalgen_2030_R[,"y2030",],coalgen_2045_R[,"y2045",],totalgen_2045_R[,"y2045",])
        logit_coalgen_2045_c <- logit_coalShare_2045_c * totalgen_2045_c[,"y2045",]
        getNames(logit_coalShare_2045_c) <- recovery
        logit_coalcap_2045_c <- logit_coalgen_2045_c / (loadfactor_c[,2045,]*365*24 / EJ_2_TWh)
                        

        ###############################
        ######### DEMAND EXIT #########
        ###############################
        if (grepl("demand",PPCA_pol)) {
            
            for (yr in getYears(weight)) {
            weight[,yr,] <- data[,2019,"TOTAL.TFC"] + 
                ifelse(data[,2015,"TOTAL.TFC"] + (data[,2015,"TOTAL.TFC"]/popC[,2015,]) * popGrowth[,yr,] > 0,
                    (data[,2015,"TOTAL.TFC"]/popC[,2015,]) * popGrowth[,yr,], 0)
            }
            zero_coal_dem <- getItems(dim = 1,  x = data)[which(dimSums(data[,2015,paste0(coalvars,".TFC")],dim=3)==0)]
            
            # setConfig(forcecache=T)
            # Steel sector is permitted to continue using coal for 10 years after other demand sectors
            if (grepl("steel",subpolicy[jj])) {
            # Coal demand from the steel sector
            coaldem_c <- dimSums(data[,2015,paste0(coalvars,".IRONSTL")],dim=3)

            # 2040 steel sector coal demand from REMIND run (using coalemi_2030 for convenience)
            coalemi_2030_R <- rundata[,getYears(rundata)>="y2040",]
            coalemi_2030_R <- coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"Emi|CO2|FFaI|Industry|Steel|Fuel|Coal (Mt CO2/yr)"]
            totalemi_2030_R <- dimSums(rundata[,getYears(rundata)>="y2040","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
            
            }else if (grepl("solids",subpolicy[jj])) {
            # Historical coal solids demand
            coaldem_c <- io[,2015,"pecoal.sesofos.coaltr"]
            
            # Coal solids emissions except from steel sector in 2030
            coalemi_2030_R <- rundata[,getYears(rundata)>="y2030",]
            coalemi_2030_R <- coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"Emi|CO2|Energy|Demand|Solids|After IndustryCCS (Mt CO2/yr)"] * 
                (coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] / 
                (coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] + coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"PE|Biomass|Solids (EJ/yr)"])) - 
                coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"Emi|CO2|FFaI|Industry|Steel|Fuel|Coal (Mt CO2/yr)"]
            totalemi_2030_R <- dimSums(rundata[,getYears(rundata)>="y2030","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
            
            }else {
            # Coal demand (except solids) for 2015
            coaldem_c <- dimSums(io[,2015,"pecoal"],dim=3) - io[,2015,"pecoal.sesofos.coaltr"]
            
            # 2030 Coal demand from REMIND run
            coalemi_2030_R <- rundata[,getYears(rundata)>="y2030",]
            coalemi_2030_R <- coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"Emi|CO2|Fossil Fuels and Industry|Coal|Before IndustryCCS (Mt CO2/yr)"] - 
                coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"Emi|CO2|Energy|Demand|Solids|After IndustryCCS (Mt CO2/yr)"] *
                (coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] / 
                (coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] + coalemi_2030_R[-which(getItems(dim = 1,  x = coalemi_2030_R)=="GLO"),,"PE|Biomass|Solids (EJ/yr)"]))            
            totalemi_2030_R <- dimSums(rundata[,getYears(rundata)>="y2030","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
            }
            
            # Convert historical coal demand to emissions 
            # 26.1 GtC/ZJ to MtCO2/EJ
            emifac_coal <- 26.1 * 3.67 * 1e-3 * 1e3
            coalemi_c <- coaldem_c * emifac_coal
            coalemi_R <- toolAggregate(toolAggregate(coalemi_c,map,NULL),map,NULL)
            # setConfig(forcecache=T)

            setConfig(cachefolder = cachedir)
            # Read in total 2015 emissions by country
            totalemi_c <- dimSums(calcOutput("HistEmissions",subtype="sector",aggregate=F,years=2015)[,,"co2"],dim=3)
            # totalemi_c <- dimSums(calcOutput("HistEmissions",subtype="sector",aggregate=F,years=seq(2000,2015,5)),dim=2)
            totalemi_R <- toolAggregate(toolAggregate(totalemi_c,map,NULL),map,NULL)
            
            ## Downscale total emissions from REMIND energy demand and population disaggregation weight
            totalemi_2030_c <- magpiesort(
                toolAggregate(totalemi_2030_R[-which(getItems(dim = 1,  x = totalemi_2030_R)=="GLO"),,],map,weight[,getYears(totalemi_2030_R),])
            )
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
            nonOECD <- data.frame(country=sort(getItems(dim = 1,  x = logit_coalShare_2045_c)),
                                oecd=as.character(oecd_map),
                                ppca=as.character(ppca_map),
                                share_2045=as.numeric(logit_coalShare_2045_c),
                                gdp=as.numeric(gdppc[,2045,])) %>%
                        ### Run logit model on 2045 data to get non-OECD nations' accession probabilities ###
                        mutate(accession_prob = predict(object = logit_model, 
                                                        newdata = data.frame(Coal.Share=share_2045,GDP.PC=gdp),
                                                        type = "response"),
                            Region=map$RegionCode[order(map$CountryCode)])
            
            print("nonOECD")
            print(nonOECD)
            ##############################################
            ### Determine non-OECD coalition scenarios ###
            ##############################################
            nonOECD <- nonOECD %>% mutate(nonOECDcoalition=ifelse(accession_prob >= p[2],
                                                    "50p", "free"))
            # nonOECD <- nonOECD %>% mutate(nonOECDcoalition = ifelse(accession_prob >= p[3],
            #                                         "5p", "free"))
            # nonOECD <- nonOECD %>% mutate(nonOECDcoalition=ifelse(accession_prob >= p[2],
            #                                         "50p", nonOECDcoalition))
            # nonOECD <- nonOECD %>% mutate(nonOECDcoalition=ifelse((accession_prob >= p[1] | ppca=="PPCA"),
            #                                         "95p", nonOECDcoalition))           
            
                        print("nonOECD")
            print(nonOECD)
            #Non-OECD coalitions
            # non_oecd_95p <- nonOECD %>% filter(nonOECDcoalition=="95p") %>% select(country)
            non_oecd_50p <- nonOECD %>% filter(nonOECDcoalition %in% c("95p","50p")) %>% select(country)
            # non_oecd_5p <- nonOECD %>% filter(nonOECDcoalition %in% c("95p","50p","5p")) %>% select(country)
            
                        print("non_oecd_50p")
            print(non_oecd_50p)
            if (grepl("50p",size) | grepl("2p",size)) {
            nonoecd_members <- as.character(non_oecd_50p[,1])
            }else if (grepl("95p",size) | grepl("1p", size)) {
            nonoecd_members <- as.character(non_oecd_95p[,1])
            }else if (grepl("5p",size) | grepl("3p",size)) {
            nonoecd_members <- as.character(non_oecd_5p[,1])
            }

            print("nonoecd_members")
            print(nonoecd_members)

            print("Prob Thresholds")
            print(p)
            
            # if (grepl("coalitions",subtype)) {
            # for (yr in getYears(weight)) {
            #     weight[,yr,] <- data[,2019,"TOTAL.TFC"] + 
            #     ifelse(data[,2019,"TOTAL.TFC"] + (data[,2019,"TOTAL.TFC"]/popC[,2019,]) * popGrowth[,yr,] > 0,
            #             (data[,2019,"TOTAL.TFC"]/popC[,2019,]) * popGrowth[,yr,], 0)
            # }
            # getYears(weight) <- getYears(popGrowth)
            # return(list(non_oecd=unique(c(oecd_members,nonoecd_members)),weight=weight))
            # }
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
            coalemi_2050_R <- coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"Emi|CO2|FFaI|Industry|Steel|Fuel|Coal (Mt CO2/yr)"]
            totalemi_2050_R <- dimSums(rundata[,getYears(rundata)>="y2060","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
            }else if (grepl("solids",subpolicy[jj])) {
            # Coal solids emissions except from steel sector in 2050
            coalemi_2050_R <- rundata[,getYears(rundata)>="y2050",]
            coalemi_2050_R <- coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"Emi|CO2|Energy|Demand|Solids|After IndustryCCS (Mt CO2/yr)"] *
                (coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] / 
                (coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] + coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"PE|Biomass|Solids (EJ/yr)"])) - 
                coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"Emi|CO2|FFaI|Industry|Steel|Fuel|Coal (Mt CO2/yr)"]
            totalemi_2050_R <- dimSums(rundata[,getYears(rundata)>="y2050","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
            }else {
            # Coal emissions (except from solids) from 2050 time step of the reference scenario
            coalemi_2050_R <- rundata[,getYears(rundata)>="y2050",]
            coalemi_2050_R <- coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"Emi|CO2|Fossil Fuels and Industry|Coal|Before IndustryCCS (Mt CO2/yr)"] *
                (coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] / 
                (coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"PE|Coal|Solids (EJ/yr)"] + coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"PE|Biomass|Solids (EJ/yr)"])) - 
                coalemi_2050_R[-which(getItems(dim = 1,  x = coalemi_2050_R)=="GLO"),,"Emi|CO2|Energy|Demand|Solids|After IndustryCCS (Mt CO2/yr)"]
            totalemi_2050_R <- dimSums(rundata[,getYears(rundata)>="y2050","Emi|CO2|w/ Bunkers (Mt CO2/yr)"],dim=3)
            }

            totalemi_2050_c <- magpiesort(
                toolAggregate(totalemi_2050_R[-which(getItems(dim = 1,  x = totalemi_2050_R)=="GLO"),,],map,weight[,getYears(totalemi_2050_R),])
            )
            coalemi_2050_R <- toolAggregate(coalemi_2050_R,map,NULL)
            
            # Extrapolate 2050 national coal shares from 2030
            coalshare_2050_c <- downscale_coal(coalemi_2030_c[,getYears(coalemi_2030_c)[1],],totalemi_2030_c[,getYears(totalemi_2030_c)[1],],coalemi_2030_R[,getYears(coalemi_2030_R)[1],],totalemi_2030_R[,getYears(totalemi_2030_R)[1],],coalemi_2050_R,totalemi_2050_R)
            coalemi_2050_c <- coalshare_2050_c * totalemi_2050_c
            getYears(coalemi_2050_c) <- getYears(coalemi_2050_R)
            getNames(coalemi_2050_c) <- recovery
            getNames(totalemi_2050_c) <- recovery
            
        }
        
        # Unmanipulated reference scenario energy demand     
        endem_ttot_R <- rundata[-which(getItems(dim = 1,  x = rundata)=="GLO"),getYears(weight),"PE (EJ/yr)"]
        endem_ttot_c <- toolAggregate(endem_ttot_R,map,weight)
        
        ##### Derive output for implementation of policy coalition in REMIND #####
        coalshare_2030 <- new.magpie(map$CountryCode,years=NULL,names=NULL,fill=NA)
        coalshare_2050 <- new.magpie(map$CountryCode,years=NULL,names=NULL,fill=NA)
        OECDexit <- new.magpie(unique(map$RegionCode),years=NULL,names=NULL,fill=0)
        
        for (reg in unique(map$RegionCode)) {
            reg_oecd_members <- map$CountryCode[which(map$CountryCode %in% oecd_members & map$RegionCode==reg)]
            reg_members <- map$CountryCode[which(map$CountryCode %in% c(oecd_members,nonoecd_members) & map$RegionCode==reg)]
            reg_all <- map$CountryCode[which(map$RegionCode==reg)]
            print("reg_members")
            print(reg_members)
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

            # Return status update of top 10 nonOECD coal countries
            write.csv(current_nonoecd %>% 
                        left_join(OECD %>% 
                                mutate(accession_prob_2025 = accession_prob, 
                                        share_2025 = share, 
                                        gen_2025 = as.numeric(coalgen_2025_c)) %>% 
                                select(country, share_2025, accession_prob_2025, gen_2025), by = "country") %>% 
                        left_join(nonOECD %>% 
                                mutate(accession_prob_2045 = accession_prob, 
                                        gen_2045 = as.numeric(coalgen_2045_c[,2045,]),
                                        elgen_2045 = as.numeric(totalgen_2045_c[,2045,])) %>% 
                                select(country, share_2045, accession_prob_2045, gen_2045, elgen_2045), by = "country"),
                      file = paste0(outputfolder,"/nonoecd_top10_status.csv"))
        }else {
            out <- coalshare_2030
            for (country in map$CountryCode[which(!(map$CountryCode %in% c(oecd_members,nonoecd_members)))]) {
                if (coalshare_2050[country,,] > coalshare_2030[country,,] & coalshare_2030[country,,] > 0) {
                    out[country,,] <- coalshare_2050[country,,]
                }
            }
            getYears(out) <- NULL
            weight_out <- dimSums(weight[,getYears(weight)>="y2030",],dim=2)

            # Return status update of top 10 OECD coal countries
            write.csv(current_oecd_top10 %>% 
                        left_join(OECD %>% 
                                mutate(accession_prob_2025 = accession_prob, 
                                        share_2025 = share, 
                                        gen_2025 = as.numeric(coalgen_2025_c),
                                        elgen_2025 = as.numeric(totalgen_2025_c[,2025,])) %>% 
                                select(country, share_2025, accession_prob_2025, gen_2025, elgen_2025), by = "country"),
                      file = paste0(outputfolder,"/oecd_top10_status.csv"))            
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
        cat("Writing",file,"to output folder:", outputfolder, "\n")
        write.magpie(out_reg,file_folder = outputfolder, file_name = file,append = ifelse(subpolicy[jj]=="none",FALSE,TRUE))
        }
    }
    setConfig(forcecache = F)
    #### IF PLOT == "ONLY" ###
  } else {
        logit_model <- glm(data = histData, PPCA.Bin ~  Coal.Share + GDP.PC , family = "binomial")
        print("phase")
        print(phase)
        if (grepl("non",phase,ignore.case=T)) {
            nonOECD <- data.frame(country=sort(getItems(dim = 1,  x = logit_coalShare_2045_c)),
                                    oecd=as.character(oecd_map),
                                    ppca=as.character(ppca_map),
                                    share_2045=as.numeric(logit_coalShare_2045_c),
                                    gdp=as.numeric(gdppc[,2045,])) %>%
                            ### Run logit model on 2045 data to get non-OECD nations' accession probabilities ###
                            mutate(accession_prob = predict(object = logit_model, 
                                                            newdata = data.frame(Coal.Share=share_2045,GDP.PC=gdp),
                                                            type = "response"),
                            Region=map$RegionCode[order(map$CountryCode)])
                
                ##############################################
                ### Determine non-OECD coalition scenarios ###
                ##############################################
                nonOECD <- nonOECD %>% mutate(nonOECDcoalition=ifelse(accession_prob >= p[2],
                                                        "50p", "free"))
                # nonOECD <- nonOECD %>% mutate(nonOECDcoalition = ifelse(accession_prob >= p[3],
                #                                         "5p", "free"))
                # nonOECD <- nonOECD %>% mutate(nonOECDcoalition=ifelse(accession_prob >= p[2],
                #                                         "50p", nonOECDcoalition))
                # nonOECD <- nonOECD %>% mutate(nonOECDcoalition=ifelse((accession_prob >= p[1] | ppca=="PPCA"),
                #                                         "95p", nonOECDcoalition))    
        }else {
            OECD <- data.frame(country=sort(getItems(dim = 1,  x = coalShare_2025_c)),
                            oecd=as.character(oecd_map),
                            ppca=as.character(ppca_map),
                            gdp=as.numeric(gdppc[,2025,]),
                            share=as.numeric(coalShare_2025_c)) %>%
                    ### Run logit model on 2025 data to get OECD nations' accession probabilities ###
                    mutate(accession_prob = predict(object = logit_model, 
                                                    newdata = data.frame(Coal.Share=share,GDP.PC=gdp),
                                                    type = "response"),
                            Region=map$RegionCode[order(map$CountryCode)])

            ##########################################
            ### Determine OECD coalition scenarios ###
            ##########################################
            OECD <- OECD %>% mutate(coalition=ifelse(accession_prob >= p[2] & oecd=="OECD",
                                                    "50p", "free"))
            # OECD <- OECD %>% mutate(coalition = ifelse(accession_prob >= p[3] & oecd=="OECD",
            #                                         "5p", "free"))
            # OECD <- OECD %>% mutate(coalition=ifelse(accession_prob >= p[2] & oecd=="OECD",
            #                                         "50p", coalition))
            # OECD <- OECD %>% mutate(coalition=ifelse((accession_prob >= p[1] | ppca=="PPCA") & (oecd=="OECD" | Region=="EUR"),
            #                                         "95p", coalition))
        }       
    }
  #######################################################
  ### RETURN DYNAMIC FEASIBILITY SPACE (BUBBLE CHART) ###
  #######################################################
  
  if (!is.null(plot) & size != "current") {  
    # install.packages("ggnewscale")
    setConfig(forcecache = T)
    
    require(ggplot2)
    require(ggnewscale)
    require(ggrepel)
    require(stringr)
    require(dplyr)
    require(scales)
    require(readxl)
    require(countrycode)

    if (isTRUE(plot)) {
      plot <- paste("DFS", ifelse(nonoecd=="on", "2045", "2025"), recovery, PPCA_pol, size, fin_pol, mob, uncertainty,  sep = "_")
    }
    
    if (!grepl('.', plot, fixed = TRUE)) {
      pdf <- paste0(plot,".pdf")
      jpg <- paste0(plot,".jpg")
    }
    
    #Relevant regional mappings and country classifications
    #Current members of PPCA
    ppca <- PPCAmap$CountryCode[which(PPCAmap$RegionCode=="PPCA")]
    #Current OECD and non-OECD members
    oecd <- OECDmap$CountryCode[which(OECDmap$RegionCode=="OECD")]
    non_oecd <- OECDmap$CountryCode[which(OECDmap$RegionCode=="NON")]
    #Current EU members   
    EU27 <- map$CountryCode[which(map$RegionCode=="EUR")]
    
    new_mem_july21 <- c("DEU","FJI","GRC",'HRV','HUN','ISR','MEX','MKD','MNE','PRT','VUT')
    
    newest_mem_cop26 <- c('UKR','CHL','SGP','MUS','AZE','SVN','EST')
    
    if (recovery=="Neutral")  recovery <- "BAU"
    
    ##Probability levels and line types
    # if (!is.null(file)) {
      # if (grepl("50CI",file))  p <- c(.25, 0.5, 0.75)
      # else if (grepl("33CI",file))  p <- c(.33, 0.5, 0.67)
      # else if (grepl("60CI",file))  p <- c(0.2, 0.5, 0.8)
      # else if (grepl("70CI",file))  p <- c(0.15, 0.5, 0.85)
      # else if (grepl("90CI",file))  p <- c(0.05, 0.5, 0.95)
      # else  p <- c(0.05, 0.5, 0.95)
    # }
    if (grepl("50CI",uncertainty))  p <- c(.25, 0.5, 0.75)
    else if (grepl("33CI",uncertainty))  p <- c(.33, 0.5, 0.67)
    else if (grepl("60CI",uncertainty))  p <- c(0.2, 0.5, 0.8)
    else if (grepl("70CI",uncertainty))  p <- c(0.15, 0.5, 0.85)
    else if (grepl("90CI",uncertainty))  p <- c(0.05, 0.5, 0.95)
    else if (uncertainty=="10step")      p <- seq(10,90,10) / 100
    else if (uncertainty=="5step")      p <- seq(10,90,20) / 100
    else  p <- c(0.05, 0.5, 0.95)

    lnCols <- setNames(c(rep("grey50", length(p)-1), "red"), 
                            nm = c(p[-which(p==0.5)], 0.5)
    )

    # lnAlpha <- setNames()

    print("lnCols")
    print(lnCols)
    # lts <- setNames(c(3, 2, 4), nm = p) 

    # Read file tracking the current status of the PPCA which contains GDPpc, % coal in electricity, 
    # standing coal power capacity, among other data
    #Country - 3-letter ISO country code
    #PPCA - PPCA membershp
    #PPCA.Bin (binary) - PPCA membership (1/0)
    #GDP.PC - GDP per capita (1000 USD)
    #Coal.Share - Share of coal in electricity supply
    #GW Capacity - total installed capacity of coal-fired fleet
    # histData <- read.csv(paste0(getConfig("sourcefolder"),"/PPCA/PPCA_status_SSP2_COP26.csv"),stringsAsFactors = F,sep = ";")
    # histData <- read.csv(paste0(getConfig("sourcefolder"),"/PPCA/PPCA_status_SSP2_2015.csv"),stringsAsFactors = F,sep = ",")

    #Logit regression of existing PPCA membership 
      
    # if (plot == "only") 
    ## Run COALogit subfunction to retrieve national coal shares, capacities, GDPpc
    # testData <- mrremind:::calcPPCA(phase=phase,policy=policy,subpolicy="none",recovery=recovery,size=size,run=run,subtype="bubble") 

    if (grepl("non",phase,ignore.case=T)) {
      testData <- nonOECD %>%
        # mutate(Region = map$RegionCode) %>%
        mutate(Capacity = as.numeric(logit_coalcap_2045_c))
        
    } else {
      testData <- OECD %>%
        # mutate(Region = map$RegionCode) %>%
        mutate(Capacity = as.numeric(cap_2025_c))
    }
    testData <- testData %>% 
      mutate(Face = ifelse(ppca=="PPCA", "bold.italic", "plain"))
    
    # print(testData %>% filter(Region=="OAS"))
    ## Sanity check test data 
    testData$share[which(testData$share>1)] <- max(testData$share[which(testData$share<1)], na.rm = T)
    
    if (phase=="OECD" & recovery=="BAU") 
      testData <- testData %>% mutate(nudge = ifelse(country=="MAR",-0.02,ifelse(country=="CHN",0.065,0.025+Capacity/1.5e4)))
    # else if (grepl("non",phase,ignore.case=T))
    #   testData <- testData %>% mutate(nudge = ifelse(country=="CHN",0.065,0.025+Capacity/1.5e4))
    else
      testData <- testData %>% mutate(nudge = ifelse(country=="CHN",0.065,0.025+Capacity/1.5e4))

    # Derive intercept and slope of probability thresholds 
    ic <-  (log(1/p -1) -  summary(logit_model)$coef[1])/ summary(logit_model)$coef[3]
    slope <- -(summary(logit_model)$coef[2]/summary(logit_model)$coef[3])
    # All countries lying above this line are members of the given coalition scenario
    ln <- data.frame(Ic = ic, Slope = slope, Prob = as.character(p))
    
    plotData <- filter(testData,share>=1e-2)
    
    # if (grepl("non",phase,ignore.case=T)) {
    #   plotData <- filter(plotData,!(ppca=="PPCA" & oecd=="OECD"))
    # }  
    
    if (recovery=="BAU")  recovery <- "Neutral"
    
    clrs <- c("OECD"="#E41A1C", "Non-OECD"="#789FC6","PPCA" = "goldenrod3", "Free" = "#000000")
    # colnames(plotData)[which(grepl("cap_",colnames(plotData)))] <- paste0("GW Capacity (",gsub("cap_","",colnames(plotData)[which(grepl("cap_",colnames(plotData)))]),")")
    
    year <- ifelse(phase=="OECD","2025","2045")
    
    size <- ifelse(size=="1p", "95p",
                    ifelse(size=="2p", "50p",
                          ifelse(size=="3p", "5p", "")))
    
    print(plotData)
    print(ln$Ic[which(ln$Prob==0.5)])
    print(ln$Ic)

    if (mob == "none")  mob <- ""
    else if (mob == "hi_oecd")  mob <- "Grants"
    else if (mob == "lo_oecd")  mob <- "Crowd-out"
    else if (mob == "OECD")  mob <- "Crowd-in"
    else if (mob == "hi_oecd_2030")  mob <- "Grants 2025-30"
    else if (mob == "hi_oecd_cond")  mob <- "Conditional Grants"

    ggplot(plotData) + 
      #Probability lines
      geom_abline(intercept = seq(ln$Ic[which(ln$Prob==0.5)]+0.1,90,0.2),
                  slope = ln$Slope[1],
                  color="gold",
                  alpha=0.06
                #   linetype = 2
                  ) +
    #   geom_abline(intercept = ln$Ic[which(ln$Prob==0.5)],
    #               slope = ln$Slope[1],
    #               color="red",
    #               alpha=0.3,
    #               linetype = 2) +
      geom_point(data = plotData,aes(x = share, y = gdp, color = oecd, size = Capacity),shape=16) +
      scale_color_manual(values = clrs, name="OECD Status (2021)",breaks=c("OECD","Non-OECD"),labels=c("OECD","Non-OECD"),guide=guide_legend(override.aes = list(size=5), order=3)) +
      new_scale_color() +
      
      #Labels
      geom_text_repel(data = plotData, 
                    aes(x = share, y = gdp, label = country, fontface = Face, color = ppca), 
                    size = 5.2, 
                    alpha = 0.9, segment.size = 0.3, segment.alpha = 0.25, force = 5,nudge_x = plotData$nudge,max.overlaps = 80) +
      
      scale_color_manual(values = clrs, name="PPCA Status (July 2021)",breaks=c("PPCA","Free"),labels=c("PPCA","Freerider"),guide=guide_legend(override.aes = list(size=7,label="A"),order=4)) +
      guides(size=guide_legend(order=1),color=guide_legend(order=2,override.aes = list(size=2))) +
      
      #Probability lines
      new_scale_color() +
      geom_abline(data = ln, aes(intercept = Ic, slope = Slope, color = Prob), size = 0.6, linetype = 3) +
    #   scale_alpha_manual(values = (1-p), name = "Coalition Scenario", labels = paste0(p*100,"% likely"), guide=guide_legend(override.aes = list(size=5),order=2)) +
      ##Special treatment of countries 'overshadowed' by bigger ones
      geom_point(data = filter(plotData, ifelse(phase=="OECD" & recovery=="Neutral", country %in% c("VNM"),
                                country %in% "")),
                  aes(x = share, y = gdp, size = Capacity), shape = 1, color = "black", stroke = 0.2) +

      ##Axis labels (and limits, if necessary)
      scale_x_continuous("% of coal in electricity supply", labels = percent, limits = c(0, 1)) +
      scale_y_continuous("GDP p.c. ($1000)",limits = c(0,80)) + 
      scale_color_manual(values=lnCols, guide = "none",
    #   values=c("gold","#CC3333","blue"), 
                          name = "Coalition Scenario", 
                          labels = paste0(p*100,"% likely"),
                        #   c(paste0("\u2265 ",p[3]*100,"% likely"),paste0("\u2265 ",p[2]*100,"% likely"),paste0("\u2265 ",p[3]*100,"% likely")),
                        #   guide=guide_legend(override.aes = list(size=1),order=2)
                          ) +
      theme_bw() +
      theme(panel.grid.minor = element_blank(),
            text = element_text(size=3.5*8.5),
            plot.title = element_text(face="bold",size=3.5*10,hjust=0.5),
            legend.text = element_text(size=3.5*6),
            legend.title = element_text(size=3.5*7)) +
      scale_size_continuous(range = 2.9*c(0.15, 13), breaks = c(10, 50, 250, round(max(plotData$Capacity),0)),name=paste(ifelse(grepl("non",phase,ignore.case = T),"2045","2025"),"Capacity (GW)"),guide=guide_legend(order=1)) +
      labs(title = paste0(ifelse(nonoecd=="on", "2045", "2025"), " PPCA Feasibility Space (", ifelse(fin_pol=="none", "PPCA", fin_pol), ifelse(mob=="","", paste0(" ",mob)),")"))

      # ifelse(fin_pol=="REdirect",
      #                     ifelse(grepl("non",phase,ignore.case = T),
      #                             paste0("2045 PPCA Feasibility Space (G20", ifelse(grepl("oilgas",run)," + G7 "," "), "FinEx REdirect", ifelse(grepl("noMob",run),")"," + Mobilization)")),
      #                             "2025 PPCA Feasibility Space (G20 Pledged FinEx)"),
      #                     ifelse(grepl("non",phase,ignore.case = T),
      #                             paste("PPCA Feasibility Space",paste0("(",year),recovery,size,paste0(toupper(substr(PPCA_pol,1,1)),substr(PPCA_pol,2,nchar(PPCA_pol))),"Exit)"),
      #                             paste("PPCA Feasibility Space",paste0("(",year),recovery,paste0(toupper(substr(PPCA_pol,1,1)),substr(PPCA_pol,2,nchar(PPCA_pol))),"Exit)"))))
      
      cat("Saving figure",pdf,"to output folder:", outputfolder, "\n")
      cat("Saving figure",jpg,"to output folder:", outputfolder, "\n")

      ggsave(paste(outputfolder,pdf,sep="/"),width=6.3*3,height=4.63*3,units="in",device = "pdf", dpi="retina")
      ggsave(paste(outputfolder,jpg,sep="/"),width=6.3*3,height=4.63*3,units="in",device = "jpg", dpi="retina")
      paste(outputfolder,plot,sep="/")
    }
    setConfig(forcecache = F)

}
