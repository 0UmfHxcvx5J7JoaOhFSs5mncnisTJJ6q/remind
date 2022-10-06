*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCoalExit/sets.gms

SETS
	cov_coal "COVID coal sector recovery scenario"
	/
	BAU
	Green
	Brown
	Norm
	/

	coal_sup_regi(all_regi) "coalition willing to phase out coal extraction" / EUR, JPN, LAM, MEA, NEU /
	coal_sup_regi_50pc(all_regi) "coalition willing to phase out coal extraction" / CAZ, EUR, JPN, LAM, MEA, NEU, USA /
	coal_sup_regi_5pc(all_regi) "coalition willing to phase out coal extraction" / CAZ, CHA, EUR, JPN, LAM, MEA, NEU, USA /
	coal_dem_regi(all_regi) "coalition willing to phase out coal consumption" / CAZ, EUR, LAM, NEU, USA / !!swing regions - USA, CAZ, SSA 
	coal_PPCA_regi(all_regi) "coalition willing to phase out coal power generation" / LAM, MEA, EUR /  
	PPCA_regi_50prob(all_regi)  "Countries with a 50% probability of joining the PPCA Jewell et al 2019" / CAZ, EUR, LAM, JPN, MEA, USA /
	PPCA_regi_5prob(all_regi)  "Countries with a 5% probability of joining the PPCA Jewell et al 2019" / CAZ, EUR, JPN, LAM, MEA, NEU, REF, USA, CHA, IND, OAS, SSA /
	coal_exp_regi(all_regi) "coalition willing to phase out coal exports" / CHA, EUR, IND, JPN, MEA, NEU, OAS /
	coal_imp_regi(all_regi) "coalition willing to phase out coal imports" / CAZ, EUR, IND, LAM, MEA, NEU, REF, SSA, USA /
	OECD_regi(all_regi)		"OECD regions"		/ CAZ, EUR, JPN, NEU, USA / 
	nonOECD_regi(all_regi)	"non-OECD regions"	/ CHA, IND, LAM, MEA, OAS, REF, SSA /



	coal_sup_regiPLUS(all_regi) "coalition willing to phase out coal extraction plus CAZ" / CAZ, EUR, JPN, LAM, MEA, NEU, USA /
	coal_sup_regiPlusCHA(all_regi) "coalition willing to phase out coal extraction plus CAZ & CHA" / CAZ, CHA, EUR, JPN, LAM, MEA, NEU, USA /
	coal_sup_regiPlusIND(all_regi) "coalition willing to phase out coal extraction plus CAZ & IND" / CAZ, EUR, JPN, IND, LAM, MEA, NEU, USA /
	coal_dem_regiPLUS(all_regi) "coalition willing to phase out coal consumption plus JPN" / CAZ, EUR, JPN, LAM, MEA, NEU, USA /
	coal_dem_regiPlusCHA(all_regi) "coalition willing to phase out coal consumption plus JPN & CHA" / CAZ, CHA, EUR, JPN, LAM, MEA, NEU, USA /
	coal_dem_regiPlusIND(all_regi) "coalition willing to phase out coal consumption plus JPN & IND" / CAZ, EUR, IND, JPN, LAM, MEA, NEU, USA /
	coal_exp_regiPLUS(all_regi) "coalition willing to phase out coal exports plus CAZ & USA" / CAZ, CHA, EUR, IND, JPN, MEA, NEU, OAS, USA /
	coal_imp_regiPLUS(all_regi) "coalition willing to phase out coal imports plus CHA" / CAZ, CHA, EUR, IND, LAM, MEA, NEU, REF, SSA, USA /
;

*** EOF ./modules/47_regipol/regiCoalExit/sets.gms
