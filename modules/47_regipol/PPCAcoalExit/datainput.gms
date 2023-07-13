*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/datainput.gms

*** Enable rapid early retirement in initial timestep if indicated by Global Coal Plant Tracker data
pm_regiEarlyRetiRate("2020",regi,coalElTeNoCCS)$(p47_coalCapCOVID("2025",regi,"%cm_COVID_coal_scen%") le (0.55 * p_PE_histCap("2020",regi,"pecoal","seel"))) = 0.16;

*** more coal plant retirement possible for OECD members who join the PPCA and must phase out coal by 2030
$ifthen.oecd %cm_PPCA_OECD% == "on"
$ifthen.pol %cm_PPCA_pol% == "power"
  pm_regiEarlyRetiRate("2025",regi,coalElTeNoCCS)$(p47_max_coal_el_share_oecd(regi) lt 0.25 AND p47_max_coal_el_share_oecd(regi) gt 0) = 0.2;
$elseif.pol %cm_PPCA_pol% == "demand"
  pm_regiEarlyRetiRate("2025",regi,coalNonSolTe)$(p47_max_coal_dem_share_oecd(regi,"demand") lt 0.25 AND p47_max_coal_dem_share_oecd(regi,"demand") gt 0) = 0.2;
  pm_regiEarlyRetiRate("2025",regi,"coaltr")$(p47_max_coal_dem_share_oecd(regi,"solids") lt 0.25 AND p47_max_coal_dem_share_oecd(regi,"solids") gt 0) = 0.2;
$endif.pol
$endif.oecd


*** Read in variables from reference and upstream (DPE) scenarios
Execute_Loadpoint 'input_ref' p47_prodSe = vm_prodSe.l;
Execute_Loadpoint 'input_ref' p47_demFeSector = vm_demFeSector.l;

$ifthenE.reinvest sameas("%cm_REdir_mobil%","hi_oecd_cond")or(sameas("%cm_REdir_mobil%","hi_oecd_cond_2030"))
Execute_Loadpoint 'input_bau' p47_costTeCapital_bau = vm_costTeCapital.l;
Execute_Loadpoint 'input_bau' p47_prodSe_bau = vm_prodSe.l;
Execute_Loadpoint 'input_bau' p47_deltaCap_bau = vm_deltaCap.l;
Execute_Loadpoint 'input_bau' p47_costInvTeAdj_bau = v_costInvTeAdj.l;
Execute_Loadpoint 'input_bau' p47_costInvTeDir_bau = v_costInvTeDir.l;
Execute_Loadpoint 'input_bau' p47_capFac_bau = vm_capFac.l;
Execute_Loadpoint 'input_bau' p47_pvp = pm_pvp;

Execute_Loadpoint 'input_ref' p47_deltaCap_ref = vm_deltaCap.L;

*** Calculate interest rate from baseline scenario t/(t-1)
p47_int_rate(ttot) <- (1 - 
((p47_pvp(ttot,"good")) / (p47_pvp(ttot-1,"good"))) ** 
(1 / (pm_dt))
)


display p47_deltaCap_bau, p47_prodSe_bau, p47_costTeCapital_bau;
$endif.reinvest

*** Read scenario-specific PPCA constraints
$ifthen.finex %cm_pubfinex_pol% == "none"
parameter p47_coalCapCOVID(tall,all_regi,COV_coal) "2025 coal capacity scenarios based on COVID recovery scenarios"
/
$ondelim
* $include "./modules/47_regipol/PPCAcoalExit/input/p47_coalCapCOVID_mar10.cs4r"
$include "./modules/47_regipol/PPCAcoalExit/input/p47_coalCapCOVID_2020data.cs4r"
$offdelim
/
;

$else.finex
parameter p47_coalCapCOVID(tall,all_regi,COV_coal) "2025-2030 coal capacity scenarios based on COVID recovery scenarios and public overseas finance exit pledges"
/
$ondelim
* $include "./modules/47_regipol/PPCAcoalExit/input/p47_coalCapCOVID_pubfinex_nov29.cs4r"
$include "./modules/47_regipol/PPCAcoalExit/input/p47_coalCapCOVID_finEx2023.cs4r"
$offdelim
/
;
$endif.finex

* $if.REsub %cm_pubfinex_pol% == "REdirect"
* parameter p47_deltaCap_REsub(tall,all_regi) "2025-2030 overseas financed RE capacity, equal to public overseas coal finance exit pledges"
* /
* $ondelim
* $include "./modules/47_regipol/PPCAcoalExit/input/p47_pubfinex_capREsub.cs4r"
* $offdelim
* /
* ;
* $endif.REsub

* $ifthen.size %cm_PPCA_size% == "current"

$ifthen.REdir %cm_pubfinex_pol% == "REdirect"
Execute_Loadpoint 'input_ref' p47_ref_costInvTeDir_RE = v_costInvTeDir.l;
Execute_Loadpoint 'input_ref' p47_ref_costInvTeAdj_RE = v_costInvTeAdj.l;
$endif.REdir

* $ifthen.finEx not %cm_pubfinex_pol% == "none"
parameter p47_REdir_vol(all_regi)     !! Finance volume redirected G20 to FinEx hosts
/
$ifthen.mobil %cm_REdir_mobil% == "none"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_pubOnly.cs3r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "OECD"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_oecd_nat_mob.cs3r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "lo_oecd"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_LO_oecd_nat_mob.cs4r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "hi_oecd"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_HI_oecd_nat_mob.cs4r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "hi_oecd_2030"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_HI_oecd_nat_mob.cs4r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "hi_oecd_cond"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_HI_oecd_nat_mob.cs4r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "hi_oecd_cond_2030"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_HI_oecd_nat_mob.cs4r"
$offdelim

* Execute_Loadpoint 'input_ref' p47_deltaCap = vm_deltaCap.l;

$elseif.mobil %cm_REdir_mobil% == "oilgas_oecd"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_oecd_nat_mob.cs3r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "oilgas_pub"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_pubOnly.cs3r"
$offdelim

$elseif.mobil %cm_REdir_mobil% == "oilgas_oecd_med"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/p47_FinEx_REdirect_oecd_nat_mob.cs3r"
$offdelim

$endif.mobil
/
;
* $endif.finEx
* $endif.size

* *** PPCA coal exit scenario cascade should all have the same C price but includes runs with different startyears
* $ifthen.ppca %cm_PPCA_nonOECD% == "on"
* Execute_Loadpoint "input_opt" pm_taxCO2eq = pm_taxCO2eq;
* $endif.ppca


*** 2030 OECD PPCA phase-out ***
$ifthen.phase1 %cm_PPCA_OECD% == "on"
*** Power-exit policy ***
$ifthen.polscen %cm_PPCA_pol% == "power"

parameter p47_max_coal_el_share_oecd(all_regi)    "Maximum share of met coal emissions from total coal emissions after the OECD phases out steel sector coal demand"
/
$ifthen.recovery1 %cm_COVID_coal_scen% == "none"
$ifthen.coalition %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_current.cs4r"
$offdelim

$elseif.coalition %cm_PPCA_size% == "1p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_1p.cs4r"
$offdelim

$elseif.coalition %cm_PPCA_size% == "2p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_2p.cs4r"
$offdelim

$elseif.coalition %cm_PPCA_size% == "3p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_3p.cs4r"
$offdelim

$endif.coalition
$endif.recovery1

$ifthen.recovery %cm_COVID_coal_scen% == "Neutral"
$ifthen.coalition1 %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_power_current.cs4r"
$offdelim

*** 95%-probable 1p coalition (renamed to 95p in manuscript) ***
$elseif.coalition1 %cm_PPCA_size% == "1p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_power_1p.cs4r"
$offdelim

*** 50%-probable 2p coalition (renamed to 50p in manuscript) ***
$elseif.coalition1 %cm_PPCA_size% == "2p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_power_2p.cs4r"
$offdelim

*** 5%-probable 3p coalition (renamed to 5p in manuscript) ***
$elseif.coalition1 %cm_PPCA_size% == "3p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_power_3p.cs4r"
$offdelim

$endif.coalition1
$endif.recovery

*** Brown Covid recovery ***
$ifthen.recovery2 %cm_COVID_coal_scen% == "Brown"

$ifthen.coalition2 %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_power_current.cs4r"
$offdelim

$elseif.coalition2 %cm_PPCA_size% == "1p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_power_1p.cs4r"
$offdelim

$elseif.coalition2 %cm_PPCA_size% == "2p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_power_2p.cs4r"
$offdelim

$elseif.coalition2 %cm_PPCA_size% == "3p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_power_3p.cs4r"
$offdelim

$endif.coalition2
$endif.recovery2

*** Green Covid recovery ***
$ifthen.recovery3 %cm_COVID_coal_scen% == "Green"

$ifthen.coalition3 %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_power_current.cs4r"
$offdelim

$elseif.coalition3 %cm_PPCA_size% == "1p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_power_1p.cs4r"
$offdelim

$elseif.coalition3 %cm_PPCA_size% == "2p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_power_2p.cs4r"
$offdelim

$elseif.coalition3 %cm_PPCA_size% == "3p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_power_3p.cs4r"
$offdelim

$endif.coalition3
$endif.recovery3

*** Scenarios with no Covid considerations (not reported in study) ***
$ifthen.recovery1 %cm_COVID_coal_scen% == "none"
$ifthen.coalition %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_current.cs4r"
$offdelim

$elseif.coalition %cm_PPCA_size% == "1p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_1p.cs4r"
$offdelim

$elseif.coalition %cm_PPCA_size% == "2p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_2p.cs4r"
$offdelim

$elseif.coalition %cm_PPCA_size% == "3p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_noCOV_power_3p.cs4r"
$offdelim

$endif.coalition
$endif.recovery1

/
;

$elseif.polscen %cm_PPCA_pol% == "demand"
*** Demand Exit policy scenarios
*** 2030 OECD PPCA phase-out
parameter p47_max_coal_dem_share_oecd(all_regi,dem_sector)    "Maximum share of met coal emissions from total coal emissions after the OECD phases out steel sector coal demand"
/
$ifthen.recovery7 %cm_COVID_coal_scen% == "Neutral"
$ifthen.coalition7 %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_demand_current.cs4r"
$offdelim

$elseif.coalition7 %cm_PPCA_size% == "1p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_demand_1p.cs4r"
$offdelim


$elseif.coalition7 %cm_PPCA_size% == "2p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_demand_2p.cs4r"
$offdelim


$elseif.coalition7 %cm_PPCA_size% == "3p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_BAU_demand_3p.cs4r"
$offdelim

$endif.coalition7
$endif.recovery7

$ifthen.recovery8 %cm_COVID_coal_scen% == "Brown"

$ifthen.coalition8 %cm_PPCA_size% == "current"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_demand_current.cs4r"
$offdelim


$elseif.coalition8 %cm_PPCA_size% == "1p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_demand_1p.cs4r"
$offdelim

$elseif.coalition8 %cm_PPCA_size% == "2p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_demand_2p.cs4r"
$offdelim


$elseif.coalition8 %cm_PPCA_size% == "3p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Brown_demand_3p.cs4r"
$offdelim


$endif.coalition8
$endif.recovery8

$ifthen.recovery9 %cm_COVID_coal_scen% == "Green"

$ifthen.coalition9 %cm_PPCA_size% == "current"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_demand_current.cs4r"
$offdelim


$elseif.coalition9 %cm_PPCA_size% == "1p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_demand_1p.cs4r"
$offdelim


$elseif.coalition9 %cm_PPCA_size% == "2p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_demand_2p.cs4r"
$offdelim


$elseif.coalition9 %cm_PPCA_size% == "3p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_OECD_Green_demand_3p.cs4r"
$offdelim


$endif.coalition9
$endif.recovery9
/
;
$endif.polscen
$endif.phase1


*** Non-OECD 2050 power-exit ***

$ifthen.phase2 %cm_PPCA_nonOECD% == "on"
$ifthen.polscen2 %cm_PPCA_pol% == "power"

$ifthen.root not %cm_PPCA_size% == "current"
*** Set OECD PPCA constraint to upstream OECD scenario
Execute_Loadpoint "input_ref" p47_max_coal_el_share_oecd = p47_max_coal_el_share_oecd;
$endif.root 

parameter p47_max_coal_el_share_nonoecd(all_regi)     "Maximum regional coal share from 2050 on as a result of non-OECD PPCA countries phasing out coal"
/
$ifthen.recovery1 %cm_COVID_coal_scen% == "none"
$ifthen.coalition %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_noCOV_power_current.cs4r"
$offdelim

$elseif.coalition %cm_PPCA_size% == "1p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_noCOV_power_1p.cs4r"
$offdelim

$elseif.coalition %cm_PPCA_size% == "2p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_noCOV_power_2p.cs4r"
$offdelim

$elseif.coalition %cm_PPCA_size% == "3p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_noCOV_power_3p.cs4r"
$offdelim

$endif.coalition
$endif.recovery1

$ifthen.recovery4 %cm_COVID_coal_scen% == "Neutral"
$ifthen.coalition4 %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_power_current.cs4r"
$offdelim

$elseif.coalition4 %cm_PPCA_size% == "1p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_power_1p.cs4r"
$offdelim

$elseif.coalition4 %cm_PPCA_size% == "2p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_power_2p.cs4r"
$offdelim

$elseif.coalition4 %cm_PPCA_size% == "3p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_power_3p.cs4r"
$offdelim
$endif.coalition4
$endif.recovery4

$ifthen.recovery5 %cm_COVID_coal_scen% == "Brown"
$ifthen.coalition5 %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_power_current.cs4r"
$offdelim

$elseif.coalition5 %cm_PPCA_size% == "1p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_power_1p.cs4r"
$offdelim

$elseif.coalition5 %cm_PPCA_size% == "2p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_power_2p.cs4r"
$offdelim

$elseif.coalition5 %cm_PPCA_size% == "3p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_power_3p.cs4r"
$offdelim

$endif.coalition5
$endif.recovery5

$ifthen.recovery6 %cm_COVID_coal_scen% == "Green"

$ifthen.coalition6 %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_power_current.cs4r"
$offdelim

$elseif.coalition6 %cm_PPCA_size% == "1p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_power_1p.cs4r"
$offdelim

$elseif.coalition6 %cm_PPCA_size% == "2p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_power_2p.cs4r"
$offdelim

$elseif.coalition6 %cm_PPCA_size% == "3p"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_power_3p.cs4r"
$offdelim

$endif.coalition6
$endif.recovery6
/
;


*** Non-OECD demand-exit ***
$elseif.polscen2 %cm_PPCA_pol% == "demand"
parameter p47_max_coal_dem_share_nonoecd(all_regi,dem_sector)     "Maximum regional coal share from 2050 on as a result of non-OECD PPCA countries phasing out coal"
/
$ifthen.recovery10 %cm_COVID_coal_scen% == "Neutral"
$ifthen.coalition10 %cm_PPCA_size% == "current"
$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_demand_current.cs4r"
$offdelim


$elseif.coalition10 %cm_PPCA_size% == "1p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_demand_1p.cs4r"
$offdelim


$elseif.coalition10 %cm_PPCA_size% == "2p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_demand_2p.cs4r"
$offdelim


$elseif.coalition10 %cm_PPCA_size% == "3p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_BAU_demand_3p.cs4r"
$offdelim


$endif.coalition10
$endif.recovery10

$ifthen.recovery11 %cm_COVID_coal_scen% == "Brown"

$ifthen.coalition11 %cm_PPCA_size% == "current"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_demand_current.cs4r"
$offdelim


$elseif.coalition11 %cm_PPCA_size% == "1p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_demand_1p.cs4r"
$offdelim


$elseif.coalition11 %cm_PPCA_size% == "2p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_demand_2p.cs4r"
$offdelim


$elseif.coalition11 %cm_PPCA_size% == "3p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Brown_demand_3p.cs4r"
$offdelim


$endif.coalition11
$endif.recovery11

$ifthen.recovery12 %cm_COVID_coal_scen% == "Green"

$ifthen.coalition12 %cm_PPCA_size% == "current"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_demand_current.cs4r"
$offdelim


$elseif.coalition12 %cm_PPCA_size% == "1p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_demand_1p.cs4r"
$offdelim


$elseif.coalition12 %cm_PPCA_size% == "2p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_demand_2p.cs4r"
$offdelim


$elseif.coalition12 %cm_PPCA_size% == "3p"

$ondelim
$include "./modules/47_regipol/PPCAcoalExit/input/f47_nonOECD_Green_demand_3p.cs4r"
$offdelim


$endif.coalition12
$endif.recovery12
/
;

$endif.polscen2
$endif.phase2


*** EOF ./modules/47_regipol/PPCAcoalExit/datainput.gms
