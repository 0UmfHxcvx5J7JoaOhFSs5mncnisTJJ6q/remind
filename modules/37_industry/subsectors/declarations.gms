*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/declarations.gms

Scalar
  s37_clinker_process_CO2   "CO2 emissions per unit of clinker production"
  s37_costAddH2Inv          "additional h2 distribution costs for low diffusion levels. [$/kWh]"
  s37_costDecayStart        "simplified logistic function end of full value   (ex. 5%  -> between 0 and 5% the simplified logistic function will have the value 1). [%]" 
  s37_costDecayEnd          "simplified logistic function start of null value (ex. 10% -> between 10% and 100% the simplified logistic function will have the value 0). [%]"
;

Parameters
  pm_abatparam_Ind(ttot,all_regi,all_enty,steps)                             "industry CCS MAC curves [ratio @ US$2005]"
  p37_energy_limit(all_in)                                                   "thermodynamic/technical limits of energy use [GJ/product]"                    
  p37_clinker_cement_ratio(ttot,all_regi)                                    "clinker content per unit cement used"                                         
  pm_ue_eff_target(all_in)                                                   "energy efficiency target trajectories [% p.a.]"                               
  pm_IndstCO2Captured(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)   "Captured CO2 in industry by energy carrier, subsector and emissions market"   
  p37_CESMkup(ttot,all_regi,all_in)                                          "CES markup cost parameter [trUSD/CES input]"                                  
  p37_cesIO_up_steel_secondary(tall,all_regi,all_GDPscen)                    "upper limit to secondary steel production based on scrap availability"        

*** output parameters only for reporting
  o37_emiInd(ttot,all_regi,all_enty,secInd37,all_enty)                   "industry CCS emissions [GtC/a]"                                                                                
  o37_cementProcessEmissions(ttot,all_regi,all_enty)                     "cement process emissions [GtC/a]"                                                                              
  o37_demFeIndTotEn(ttot,all_regi,all_enty,all_emiMkt)                   "total FE per energy carrier and emissions market in industry (sum over subsectors)"
  o37_shIndFE(ttot,all_regi,all_enty,secInd37,all_emiMkt)                "share of subsector in FE industry energy carriers and emissions markets"                                       
  o37_demFeIndSub(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)   "FE demand per industry subsector"                                                                              
  o37_demFeIndSub_SecCC(ttot,all_regi,secInd37)                          "FE per subsector whose emissions can be captured, helper parameter for calculation of industry captured CO2"   

$ifThen.CESMkup not "%cm_CESMkup_ind%" == "standard" 
  p37_CESMkup_input(all_in)  "markup cost parameter read in from config for CES levels in industry to influence demand-side cost and efficiencies in CES tree [trUSD/CES input]" / %cm_CESMkup_ind% /
$endIf.CESMkup
;

Variable
  v37_costExponent(ttot,all_regi)   "logistic function exponent for additional hydrogen low penetration cost"
;

Positive Variables
  vm_macBaseInd(ttot,all_regi,all_enty,secInd37)   "industry CCS baseline emissions [GtC/a]"
  vm_emiIndCCS(ttot,all_regi,all_enty)             "industry CCS emissions [GtC/a]"
  vm_IndCCSCost(ttot,alL_regi,all_enty)            "industry CCS cost"
  v37_expSlack(ttot,all_regi)                      "slack variable to avoid overflow on too high logistic function exponent"
  v37_emIIndCCSmax(ttot,all_regi,emiInd37)         "maximum abatable industry emissions"
  v37_H2share(ttot,all_regi)                       "H2 share in gases"
  v37_costAddTeInvH2(ttot,all_regi,all_te)         "Additional hydrogen phase-in cost at low H2 penetration levels [trUSD]"
;

Equations
  q37_energy_limits(ttot,all_regi,all_in)             "thermodynamic/technical limit of energy use"
  q37_limit_secondary_steel_share(ttot,all_regi)      "no more than 90% of steel from seconday production"
  q37_macBaseInd(ttot,all_regi,all_enty,secInd37)     "gross industry emissions before CCS"
  q37_emiIndCCSmax(ttot,all_regi,emiInd37)            "maximum abatable industry emissions at current CO2 price"
  q37_IndCCS(ttot,all_regi,emiInd37)                  "limit industry emissions abatement"
  q37_cementCCS(ttot,all_regi)                        "link cement fuel and process abatement"
  q37_IndCCSCost                                      "Calculate industry CCS costs"
  q37_demFeIndst(ttot,all_regi,all_enty,all_emiMkt)   "industry final energy demand (per emission market)"
  q37_costCESmarkup(ttot,all_regi,all_in)             "calculation of additional CES markup cost to represent demand-side technology cost of end-use transformation, for example, cost of heat pumps etc."
  q37_H2Share(ttot,all_regi)                          "H2 share in gases"
  q37_auxCostAddTeInv(ttot,all_regi)                  "auxiliar logistic function exponent calculation for additional hydrogen low penetration cost" 
  q37_costAddH2PhaseIn(ttot,all_regi)                 "calculation of additional industry hydrogen t&d cost at low penetration levels of hydrogen in industry"  
  q37_costCESmarkup(ttot,all_regi,all_in)             "calculation of additional CES markup cost to represent demand-side technology cost of end-use transformation, for example, cost of heat pumps etc."
  q37_costAddTeInv(ttot,all_regi,all_te)              "summation of sector-specific demand-side cost"
;

*** EOF ./modules/37_industry/subsectors/declarations.gms

