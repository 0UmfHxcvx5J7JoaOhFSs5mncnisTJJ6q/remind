*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind-r@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/realization.gms

*' @description  
*'
*' The `PPCAcoalExit` realization enables the implementation of coal phase-out policies only in countries which are 
*' considered politically willing based on empirical analysis of the Powering Past Coal Alliance (PPCA) by COALogit
*'
*' @authors Stephen Bi 

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/47_regipol/PPCAcoalExit/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/47_regipol/PPCAcoalExit/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/47_regipol/PPCAcoalExit/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/47_regipol/PPCAcoalExit/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/47_regipol/PPCAcoalExit/bounds.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/47_regipol/PPCAcoalExit/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/47_regipol/PPCAcoalExit/realization.gms
