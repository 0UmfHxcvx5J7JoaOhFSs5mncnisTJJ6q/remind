*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCoalExit/realization.gms

*' @description  
*'
*' The `regiCoalExit` realization enables the implementation of various coal phase-out policies (extraction moratorium,
*' coal-fired electricity phase-out, total demand phase-out, export ban, and import ban) only in regions which might 
*' conceivably be politically willing.
*'
*' @authors Stephen Bi 

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/47_regipol/regiCoalExit/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/47_regipol/regiCoalExit/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/47_regipol/regiCoalExit/datainput.gms"
$Ifi "%phase%" == "bounds" $include "./modules/47_regipol/regiCoalExit/bounds.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/47_regipol/regiCoalExit/realization.gms
