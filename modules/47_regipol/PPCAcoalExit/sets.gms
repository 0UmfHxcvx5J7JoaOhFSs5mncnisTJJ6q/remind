*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/sets.gms

SETS
coalElTeNoCCS(all_te)    "Coal power technologies without carbon capture"
/
pc
coalchp
igcc
/

teSeelCoal(all_te)      "All coal power generation technologies"
/
pc
coalchp
igcc
pco
pcc
igccc
/

coalNonSolTe(all_te)    "All non-solid coal consuming technologies"
/
pc
coalchp
igcc
pco
pcc
igccc
coalhp
coalftrec
coalh2
coalh2c
coalgas
/

cov_coal "COVID coal sector recovery scenario"
/
BAU
Neutral
Green
Brown
Norm
/

ppca_phase "Accession stage of the PPCA policy initiative (OECD = 2030, NonOECD = 2050)"
/
oecd
nonoecd
/

$ifthen %cm_PPCA_pol% == "demand"
dem_sector  "Demand exit phases out steel, solids and total demand separately"
/
demand
solids
steel
/
$endif
;

*** EOF ./modules/47_regipol/PPCAcoalExit/sets.gms