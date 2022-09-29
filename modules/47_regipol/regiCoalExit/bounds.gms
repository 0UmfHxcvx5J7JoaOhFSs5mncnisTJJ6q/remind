*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCoalExit/bounds.gms

***PPCA scenarios
$ifthen.coalRegiPol %cm_coalExitRegi% == "PPCA-1e4-ccs"
vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030
    AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco")) = 1e-4;
vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050
    AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco")) = 1e-4;

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_se-1e4-ccs"
* sum(pe2se("pecoal","seel",te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")),
*     vm_prodSe(t,coal_PPCA_regi,"pecoal","seel",te))
*     + sum(pc2te("pecoal",entySE(enty3),te,"seel")$(sameas(te,"coalchp")$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030)),
* 		pm_prodCouple(coal_PPCA_regi,"pecoal",enty3,te,"seel")
*          * 
*          vm_prodSe(t,coal_PPCA_regi,"pecoal",enty3,te)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030)) = 1e-4;

* sum(pe2se("pecoal","seel",te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")),
*     vm_prodSe(t,coal_PPCA_regi,"pecoal","seel",te))
*     + sum(pc2te("pecoal",entySE(enty3),te,"seel")$(sameas(te,"coalchp")$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050)),
* 		pm_prodCouple(coal_PPCA_regi,"pecoal",enty3,te,"seel")
*          * 
*          vm_prodSe(t,coal_PPCA_regi,"pecoal",enty3,te)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050)) = 1e-4;
         

$elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_50pc-1e4-ccs"
vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030
    AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco")) = 1e-4;
vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050
    AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco")) = 1e-4;


* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_se-50pc-1e4-ccs"
* sum(pe2se("pecoal","seel",te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")),
*     vm_prodSe(t,PPCA_regi_50prob,"pecoal","seel",te)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030))
*     + sum(pc2te("pecoal",entySE(enty3),te,"seel")$(sameas(te,"coalchp")),
* 		pm_prodCouple(PPCA_regi_50prob,"pecoal",enty3,te,"seel") 
*         * 
*         vm_prodSe(t,PPCA_regi_50prob,"pecoal",enty3,te)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030)) = 1e-4;

* sum(pe2se("pecoal","seel",te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")),
*     vm_prodSe(t,PPCA_regi_50prob,"pecoal","seel",te)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050))
*     + sum(pc2te("pecoal",entySE(enty3),te,"seel")$(sameas(te,"coalchp")),
* 		pm_prodCouple(PPCA_regi_50prob,"pecoal",enty3,te,"seel") 
*         * 
*         vm_prodSe(t,PPCA_regi_50prob,"pecoal",enty3,te)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050)) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_5pc-1e4-ccs"
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_se-5pc-1e4-ccs"
* sum(pe2se("pecoal","seel",te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")),
*     vm_prodSe(t,PPCA_regi_5prob,"pecoal","seel",te)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030))
*     + sum(pc2te("pecoal",entySE(enty3),te,"seel")$(sameas(te,"coalchp")),
* 		pm_prodCouple(PPCA_regi_5prob,"pecoal",enty3,te,"seel") 
*         * 
*         vm_prodSe(t,PPCA_regi_5prob,"pecoal",enty3,te)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030)) = 1e-4;

* sum(pe2se("pecoal","seel",te)$(sameas(te,"pc") OR sameas(te,"coalchp") OR sameas(te,"igcc")),
*     vm_prodSe(t,PPCA_regi_5prob,"pecoal","seel",te)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050))
*     + sum(pc2te("pecoal",entySE(enty3),te,"seel")$(sameas(te,"coalchp")),
* 		pm_prodCouple(PPCA_regi_5prob,"pecoal",enty3,te,"seel") 
*         * 
*         vm_prodSe(t,PPCA_regi_5prob,"pecoal",enty3,te)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050)) = 1e-4;
        
        
$elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_ALL-1e4-ccs"
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND 
        ((OECD_regi(regi) AND t.val ge 2030) OR (nonOECD_regi(regi) AND t.val ge 2050))
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;


***Demand exit scenarios (PPCA coalitions)
$elseif.coalRegiPol %cm_coalExitRegi% == "demand-PPCA-1e4"
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "demand-PPCA50pc-1e4"
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "demand-PPCA5pc-1e4"
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "demand-emi-PPCA-1e4"
    vm_emiTeDetail.up(t,coal_PPCA_regi,entyPe,entySe,te,"co2")$(sameas(entyPe,"pecoal") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030) = 1e-4;
    vm_emiTeDetail.up(t,coal_PPCA_regi,entyPe,entySe,te,"co2")$(sameas(entyPe,"pecoal") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "demand-emi-PPCA50pc-1e4"
    vm_emiTeDetail.up(t,PPCA_regi_50prob,entyPe,entySe,te,"co2")$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030) = 1e-4;
    vm_emiTeDetail.up(t,PPCA_regi_50prob,entyPe,entySe,te,"co2")$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "demand-emi-PPCA5pc-1e4"
    vm_emiTeDetail.up(t,PPCA_regi_5prob,entyPe,entySe,te,"co2")$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030) = 1e-4;
    vm_emiTeDetail.up(t,PPCA_regi_5prob,entyPe,entySe,te,"co2")$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "demand-emi_ALL-1e4"
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND t.val ge 2030 AND OECD_regi(regi)) = 1e-4;
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND t.val ge 2050 AND nonOECD_regi(regi)) = 1e-4;


***PPCA and complementary policies
$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDPPCA"
    vm_fuExtr.up(t,coal_PPCA_regi,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,coal_PPCA_regi,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "importANDPPCA"
    vm_Mport.up(t,coal_PPCA_regi,enty)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,coal_PPCA_regi,enty)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "exportANDPPCA"
    vm_Xport.up(t,coal_PPCA_regi,enty)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,coal_PPCA_regi,enty)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDPPCA5pc"
    vm_fuExtr.up(t,PPCA_regi_5prob,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,PPCA_regi_5prob,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "importANDPPCA5pc"
    vm_Mport.up(t,PPCA_regi_5prob,enty)$(OECD_regi(PPCA_regi_5prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_5prob,enty)$(nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "exportANDPPCA5pc"
    vm_Xport.up(t,PPCA_regi_5prob,enty)$(OECD_regi(PPCA_regi_5prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,PPCA_regi_5prob,enty)$(nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDPPCA50pc"
    vm_fuExtr.up(t,PPCA_regi_50prob,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,PPCA_regi_50prob,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "importANDPPCA50pc"
    vm_Mport.up(t,PPCA_regi_50prob,enty)$(OECD_regi(PPCA_regi_50prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_50prob,enty)$(nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "exportANDPPCA50pc"
    vm_Xport.up(t,PPCA_regi_50prob,enty)$(OECD_regi(PPCA_regi_50prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,PPCA_regi_50prob,enty)$(nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "tradeANDPPCA"
    vm_Xport.up(t,coal_PPCA_regi,enty)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,coal_PPCA_regi,enty)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,coal_PPCA_regi,enty)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,coal_PPCA_regi,enty)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "tradeANDPPCA50pc"
    vm_Xport.up(t,PPCA_regi_50prob,enty)$(OECD_regi(PPCA_regi_50prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,PPCA_regi_50prob,enty)$(nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_50prob,enty)$(OECD_regi(PPCA_regi_50prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_50prob,enty)$(nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "tradeANDPPCA5pc"
    vm_Xport.up(t,PPCA_regi_5prob,enty)$(OECD_regi(PPCA_regi_5prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,PPCA_regi_5prob,enty)$(nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_5prob,enty)$(OECD_regi(PPCA_regi_5prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_5prob,enty)$(nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "tradeANDPPCA5pc"
    vm_Xport.up(t,regi,enty)$(OECD_regi(regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,regi,enty)$(nonOECD_regi(regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,regi,enty)$(OECD_regi(regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,regi,enty)$(nonOECD_regi(regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(regi) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(regi) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "AllANDPPCA"
    vm_fuExtr.up(t,coal_PPCA_regi,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,coal_PPCA_regi,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050) = 1e-4;
    vm_Xport.up(t,coal_PPCA_regi,enty)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,coal_PPCA_regi,enty)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,coal_PPCA_regi,enty)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,coal_PPCA_regi,enty)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "AllANDPPCA50pc"
    vm_fuExtr.up(t,PPCA_regi_50prob,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,PPCA_regi_50prob,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050) = 1e-4;
    vm_Xport.up(t,PPCA_regi_50prob,enty)$(OECD_regi(PPCA_regi_50prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,PPCA_regi_50prob,enty)$(nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_50prob,enty)$(OECD_regi(PPCA_regi_50prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_50prob,enty)$(nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "AllANDPPCA5pc"
    vm_fuExtr.up(t,PPCA_regi_5prob,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,PPCA_regi_5prob,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050) = 1e-4;
    vm_Xport.up(t,PPCA_regi_5prob,enty)$(OECD_regi(PPCA_regi_5prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,PPCA_regi_5prob,enty)$(nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_5prob,enty)$(OECD_regi(PPCA_regi_5prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Mport.up(t,PPCA_regi_5prob,enty)$(nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDPPCAall"
    vm_fuExtr.up(t,regi,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(regi) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,regi,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(regi) AND t.val ge 2050) = 1e-4;
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(regi) AND t.val ge 2030
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(regi) AND t.val ge 2050
        AND not sameas(te,"igccc") AND not sameas(te,"pcc") AND not sameas(te,"pco") AND not sameas(te,"coalh2c") AND not sameas(te,"coalftcrec")) = 1e-4;


***Demand exit and complementary policies
$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDdemand"
    vm_fuExtr.up(t,coal_PPCA_regi,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,coal_PPCA_regi,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDdemandall"
    vm_fuExtr.up(t,regi,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(regi) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,regi,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(regi) AND t.val ge 2050) = 1e-4;
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(regi) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(regi) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDdemand50pc"
    vm_fuExtr.up(t,PPCA_regi_50prob,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,PPCA_regi_50prob,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDdemand5pc"
    vm_fuExtr.up(t,PPCA_regi_5prob,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030) = 1e-4;
    vm_fuExtr.up(t,PPCA_regi_5prob,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "exportANDdemand"
    vm_Xport.up(t,coal_PPCA_regi,enty)$(OECD_regi(coal_PPCA_regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,coal_PPCA_regi,enty)$(nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "exportANDdemand50pc"
    vm_Xport.up(t,PPCA_regi_50prob,enty)$(OECD_regi(PPCA_regi_50prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,PPCA_regi_50prob,enty)$(nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "exportANDdemand5pc"
    vm_Xport.up(t,PPCA_regi_5prob,enty)$(OECD_regi(PPCA_regi_5prob) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,PPCA_regi_5prob,enty)$(nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050) = 1e-4;

$elseif.coalRegiPol %cm_coalExitRegi% == "tradeANDdemandall"
    vm_Xport.up(t,regi,enty)$(OECD_regi(regi) AND t.val ge 2030 AND sameas(enty,"pecoal")) = 1e-4;
    vm_Xport.up(t,regi,enty)$(nonOECD_regi(regi) AND t.val ge 2050 AND sameas(enty,"pecoal")) = 1e-4;
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(regi) AND t.val ge 2030) = 1e-4;
    vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(regi) AND t.val ge 2050) = 1e-4;


* $elseif.coalRegiPol %cm_coalExitRegi% == "supply-1e4"
*     vm_fuExtr.up(t,coal_sup_regi,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(coal_sup_regi) AND t.val ge 2030) = 1e-4;
*     vm_fuExtr.up(t,coal_sup_regi,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(coal_sup_regi) AND t.val ge 2050) = 1e-4;

* $elseif.coalRegiPol %cm_coalExitRegi% == "supply-Bud600"
*     vm_fuExtr.fx(t,regi,enty,rlf)$(coal_sup_regi(regi) AND sameas(enty,"pecoal")) = 
*         p47_coalExtr600(t,regi,enty,rlf)$(coal_sup_regi(regi) AND sameas(enty,"pecoal"));

* $elseif.coalRegiPol %cm_coalExitRegi% == "supply50pc-1e4"
*** Supply side coal phase out (Mining moratorium) with same rules as PPCA
* vm_fuExtr.up(t,coal_sup_regi_50pc,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND 
*     OECD_regi(coal_sup_regi_50pc) AND t.val ge 2030) = 1e-5;
* vm_fuExtr.up(t,coal_sup_regi_50pc,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND 
*     nonOECD_regi(coal_sup_regi_50pc) AND t.val ge 2050) = 1e-5;
*     vm_fuExtr.up(t,coal_sup_regi_50pc,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(coal_sup_regi_50pc) AND t.val ge 2030) = 1e-4;
*     vm_fuExtr.up(t,coal_sup_regi_50pc,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(coal_sup_regi_50pc) AND t.val ge 2050) = 1e-4;

* $elseif.coalRegiPol %cm_coalExitRegi% == "supply50pc-Bud600"
*     vm_fuExtr.fx(t,regi,enty,rlf)$(coal_sup_regi_50pc(regi) AND sameas(enty,"pecoal")) = 
*         p47_coalExtr600(t,regi,enty,rlf)$(coal_sup_regi_50pc(regi) AND sameas(enty,"pecoal"));

* $elseif.coalRegiPol %cm_coalExitRegi% == "supply5pc-1e4"
*     vm_fuExtr.up(t,coal_sup_regi_5pc,enty,rlf)$(sameas(enty,"pecoal") AND OECD_regi(coal_sup_regi_5pc) AND t.val ge 2030) = 1e-4;
*     vm_fuExtr.up(t,coal_sup_regi_5pc,enty,rlf)$(sameas(enty,"pecoal") AND nonOECD_regi(coal_sup_regi_5pc) AND t.val ge 2050) = 1e-4;

* $elseif.coalRegiPol %cm_coalExitRegi% == "demand-1e4"
*     vm_demPe.up(t,coal_dem_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(coal_dem_regi) AND t.val ge 2030) = 1e-4;
*     vm_demPe.up(t,coal_dem_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(coal_dem_regi) AND t.val ge 2050) = 1e-4;



* $elseif.coalRegiPol %cm_coalExitRegi% == "demand-B600"
*     vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_dem_regi(regi) AND sameas(entyPe,"pecoal")) = 
*         p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_dem_regi(regi) AND sameas(entyPe,"pecoal"));

* $elseif.coalRegiPol %cm_coalExitRegi% == "demand-PPCA-B600"
*     vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_PPCA_regi(regi) AND sameas(entyPe,"pecoal")) = 
*         p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_PPCA_regi(regi) AND sameas(entyPe,"pecoal"));

* $elseif.coalRegiPol %cm_coalExitRegi% == "demand-PPCA50pc-B600"
*     vm_demPe.fx(t,regi,entyPe,entySe,te)$(PPCA_regi_50prob(regi) AND sameas(entyPe,"pecoal")) = 
*         p47_coalDem600(t,regi,entyPe,entySe,te)$(PPCA_regi_50prob(regi) AND sameas(entyPe,"pecoal"));

* $elseif.coalRegiPol %cm_coalExitRegi% == "demand-PPCA5pc-B600"
*     vm_demPe.lo(t,regi,entyPe,entySe,te)$(PPCA_regi_5prob(regi) AND sameas(entyPe,"pecoal")) = 
*         0.95 * p47_coalDem600(t,regi,entyPe,entySe,te)$(PPCA_regi_5prob(regi) AND sameas(entyPe,"pecoal"));
*     vm_demPe.up(t,regi,entyPe,entySe,te)$(PPCA_regi_5prob(regi) AND sameas(entyPe,"pecoal")) = 
*         1.05 * p47_coalDem600(t,regi,entyPe,entySe,te)$(PPCA_regi_5prob(regi) AND sameas(entyPe,"pecoal"));
        
* $elseif.coalRegiPol %cm_coalExitRegi% == "demand-PPCA-1e5"
*     vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(coal_PPCA_regi) AND t.val ge 2030) = 1e-5;
*     vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050) = 1e-5;

* $elseif.coalRegiPol %cm_coalExitRegi% == "demand-PPCA50pc-1e5"
*     vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030) = 1e-5;
*     vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050) = 1e-5;

* $elseif.coalRegiPol %cm_coalExitRegi% == "demand-PPCA5pc-1e5"
*     vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030) = 1e-5;
*     vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050) = 1e-5;

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA-1e5"
*     vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND 
*         OECD_regi(coal_PPCA_regi) AND t.val ge 2030) = 1e-5;
*     vm_demPe.up(t,coal_PPCA_regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND 
*         nonOECD_regi(coal_PPCA_regi) AND t.val ge 2050) = 1e-5;

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_Bud600"
*     vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_PPCA_regi(regi) AND sameas(entyPe,"pecoal") AND sameas(entySe,"seel")) =
*         p47_coalPow600(t,regi,entyPe,entySe,te)$(coal_PPCA_regi(regi) AND sameas(entyPe,"pecoal") AND sameas(entySe,"seel"));

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_50pc-Bud600"
*     vm_demPe.fx(t,regi,entyPe,entySe,te)$(PPCA_regi_50prob(regi) AND sameas(entyPe,"pecoal") AND sameas(entySe,"seel")) =
*         p47_coalPow600(t,regi,entyPe,entySe,te)$(PPCA_regi_50prob(regi) AND sameas(entyPe,"pecoal") AND sameas(entySe,"seel"));

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_5pc-Bud600"
*     vm_demPe.fx(t,regi,entyPe,entySe,te)$(PPCA_regi_5prob(regi) AND sameas(entyPe,"pecoal") AND sameas(entySe,"seel")) =
*         p47_coalPow600(t,regi,entyPe,entySe,te)$(PPCA_regi_5prob(regi) AND sameas(entyPe,"pecoal") AND sameas(entySe,"seel"));

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_50pc-1e4"
*     vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_50prob) AND t.val ge 2030) = 1e-4;
*     vm_demPe.up(t,PPCA_regi_50prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_50prob) AND t.val ge 2050) = 1e-4;

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_5pc-1e4"
*     vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND OECD_regi(PPCA_regi_5prob) AND t.val ge 2030) = 1e-4;
*     vm_demPe.up(t,PPCA_regi_5prob,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND nonOECD_regi(PPCA_regi_5prob) AND t.val ge 2050) = 1e-4;

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_ALL-Bud600"
*     vm_demPe.fx(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel")) =
*         p47_coalPow600(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel"));

* $elseif.coalRegiPol %cm_coalExitRegi% == "PPCA_ALL-1e4"
*     vm_demPe.up(t,regi,entyPe,entySe,te)$(sameas(entyPe,"pecoal") AND sameas(entySe,"seel") AND 
*         ((OECD_regi(regi) AND t.val ge 2030) OR (nonOECD_regi(regi) AND t.val ge 2050))) = 1e-4;









$elseif.coalRegiPol %cm_coalExitRegi% == "export"
    vm_Xport.up(t,coal_exp_regi,enty)$(OECD_regi(coal_exp_regi) AND t.val ge 2030) = 1e-4;
    vm_Xport.up(t,coal_exp_regi,enty)$(nonOECD_regi(coal_exp_regi) AND t.val ge 2050) = 1e-4;
* vm_Xport.fx(t,regi,enty)$(coal_exp_regi(regi) AND sameas(enty,"pecoal")) = 
*     p47_coalExp600(t,regi,enty)$(coal_exp_regi(regi) AND sameas(enty,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "import"
        vm_Mport.up(t,coal_imp_regi,enty)$(OECD_regi(coal_imp_regi) AND t.val ge 2030) = 1e-4;
    vm_Mport.up(t,coal_imp_regi,enty)$(nonOECD_regi(coal_imp_regi) AND t.val ge 2050) = 1e-4;
* vm_Mport.fx(t,regi,enty)$(coal_imp_regi(regi) AND sameas(enty,"pecoal")) = 
*     p47_coalImp600(t,regi,enty)$(coal_imp_regi(regi) AND sameas(enty,"pecoal"));




        

$elseif.coalRegiPol %cm_coalExitRegi% == "importANDextract"
    vm_Mport.fx(t,regi,enty)$(coal_imp_regi(regi) AND sameas(enty,"pecoal")) = 
        p47_coalImp600(t,regi,enty)$(coal_imp_regi(regi) AND sameas(enty,"pecoal"));
    vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_dem_regi(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_dem_regi(regi) AND sameas(entyPe,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDdemand"
    vm_fuExtr.fx(t,regi,enty,rlf)$(coal_sup_regi(regi) AND sameas(enty,"pecoal")) = 
        p47_coalExtr600(t,regi,enty,rlf)$(coal_sup_regi(regi) AND sameas(enty,"pecoal"));
    vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_dem_regi(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_dem_regi(regi) AND sameas(entyPe,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "importANDexport"
    vm_Mport.fx(t,regi,enty)$(coal_imp_regi(regi) AND sameas(enty,"pecoal")) = 
        p47_coalImp600(t,regi,enty)$(coal_imp_regi(regi) AND sameas(enty,"pecoal"));
    vm_Xport.fx(t,regi,enty)$(coal_exp_regi(regi) AND sameas(enty,"pecoal")) = 
        p47_coalExp600(t,regi,enty)$(coal_exp_regi(regi) AND sameas(enty,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "importANDextract"
    vm_Mport.fx(t,regi,enty)$(coal_imp_regiPLUS(regi) AND sameas(enty,"pecoal")) = 
        p47_coalImp600(t,regi,enty)$(coal_imp_regiPLUS(regi) AND sameas(enty,"pecoal"));
    vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_dem_regiPLUS(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_dem_regiPLUS(regi) AND sameas(entyPe,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyANDdemandplus"
    vm_fuExtr.fx(t,regi,enty,rlf)$(coal_sup_regiPLUS(regi) AND sameas(enty,"pecoal")) = 
        p47_coalExtr600(t,regi,enty,rlf)$(coal_sup_regiPLUS(regi) AND sameas(enty,"pecoal"));
    vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_dem_regiPLUS(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_dem_regiPLUS(regi) AND sameas(entyPe,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "importANDexportplus"
    vm_Mport.fx(t,regi,enty)$(coal_imp_regiPLUS(regi) AND sameas(enty,"pecoal")) = 
        p47_coalImp600(t,regi,enty)$(coal_imp_regiPLUS(regi) AND sameas(enty,"pecoal"));
    vm_Xport.fx(t,regi,enty)$(coal_exp_regiPLUS(regi) AND sameas(enty,"pecoal")) = 
        p47_coalExp600(t,regi,enty)$(coal_exp_regiPLUS(regi) AND sameas(enty,"pecoal"));

*** ALL Fossil Fuel phase out scenarios
$elseif.coalRegiPol %cm_coalExitRegi% == "FFsupply_OECD"
    vm_fuExtr.fx(t,regi,entyPe,rlf)$(OECD_regi(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalExtr600(t,regi,entyPe,rlf)$(OECD_regi(regi) AND sameas(entyPe,"pecoal"));
    vm_fuExtr.fx(t,regi,entyPe,rlf)$(OECD_regi(regi) AND sameas(entyPe,"peoil")) = 
        p47_coalExtr600(t,regi,entyPe,rlf)$(OECD_regi(regi) AND sameas(entyPe,"peoil"));
    vm_fuExtr.fx(t,regi,entyPe,rlf)$(OECD_regi(regi) AND sameas(entyPe,"pegas")) = 
        p47_coalExtr600(t,regi,entyPe,rlf)$(OECD_regi(regi) AND sameas(entyPe,"pegas"));            
*vm_fuExtr.fx(t,regi,entyPe,rlf)$(OECD_regi(regi) AND (sameas(entyPe,"pecoal") OR sameas(entyPe,"peoil") OR sameas(entyPe,"pegas"))) = 
*       p47_coalExtr600(t,regi,entyPe,rlf)$(OECD_regi(regi) AND (sameas(entyPe,"pecoal") OR sameas(entyPe,"peoil") OR sameas(entyPe,"pegas")));

$elseif.coalRegiPol %cm_coalExitRegi% == "FFdemand_OECD"
    vm_demPe.lo(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"pecoal")) = 
        0.9*p47_coalDem600(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"pecoal"));
    vm_demPe.up(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"pecoal")) = 
        1.1*p47_coalDem600(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"pecoal"));
    vm_demPe.lo(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"peoil")) = 
        0.9*p47_coalDem600(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"peoil"));
    vm_demPe.up(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"peoil")) = 
        1.1*p47_coalDem600(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"peoil"));
    vm_demPe.lo(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"pegas")) = 
        0.9*p47_coalDem600(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"pegas"));
    vm_demPe.up(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"pegas")) = 
        1.1*p47_coalDem600(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND sameas(entyPe,"pegas"));

*    vm_demPe.fx(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND (sameas(entyPe,"pecoal") OR sameas(entyPe,"peoil") OR sameas(entyPe,"pegas"))) = 
*        p47_coalDem600(t,regi,entyPe,entySe,te)$(OECD_regi(regi) AND (sameas(entyPe,"pecoal") OR sameas(entyPe,"peoil") OR sameas(entyPe,"pegas")));

$elseif.coalRegiPol %cm_coalExitRegi% == "FFexport_OECD"
    vm_Xport.fx(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalExp600(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"pecoal"));
    vm_Xport.fx(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"peoil")) = 
        p47_coalExp600(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"peoil"));
    vm_Xport.fx(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"pegas")) = 
        p47_coalExp600(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"pegas"));
*    vm_Xport.fx(t,regi,entyPe)$(OECD_regi(regi) AND (sameas(entyPe,"pecoal") OR sameas(entyPe,"peoil") OR sameas(entyPe,"pegas"))) = 
*        p47_coalExp600(t,regi,entyPe)$(OECD_regi(regi) AND (sameas(entyPe,"pecoal") OR sameas(entyPe,"peoil") OR sameas(entyPe,"pegas")));

$elseif.coalRegiPol %cm_coalExitRegi% == "FFimport_OECD"
    vm_Mport.fx(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalImp600(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"pecoal"));
    vm_Mport.fx(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"peoil")) = 
        p47_coalImp600(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"peoil"));
    vm_Mport.fx(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"pegas")) = 
        p47_coalImp600(t,regi,entyPe)$(OECD_regi(regi) AND sameas(entyPe,"pegas"));
    
*    vm_Mport.fx(t,regi,entyPe)$(OECD_regi(regi) AND (sameas(entyPe,"pecoal") OR sameas(entyPe,"peoil") OR sameas(entyPe,"pegas"))) = 
*        p47_coalImp600(t,regi,entyPe)$(OECD_regi(regi) AND (sameas(entyPe,"pecoal") OR sameas(entyPe,"peoil") OR sameas(entyPe,"pegas")));

***Unlikely coalitions incl. CHA and/or IND
$elseif.coalRegiPol %cm_coalExitRegi% == "supplyPlusCHA"
    vm_fuExtr.fx(t,regi,enty,rlf)$(coal_sup_regiPlusCHA(regi) AND sameas(enty,"pecoal")) = 
        p47_coalExtr600(t,regi,enty,rlf)$(coal_sup_regiPlusCHA(regi) AND sameas(enty,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyPlusIND"
    vm_fuExtr.fx(t,regi,enty,rlf)$(coal_sup_regiPlusIND(regi) AND sameas(enty,"pecoal")) = 
        p47_coalExtr600(t,regi,enty,rlf)$(coal_sup_regiPlusIND(regi) AND sameas(enty,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "demandPlusCHA"
    vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_dem_regiPlusCHA(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_dem_regiPlusCHA(regi) AND sameas(entyPe,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "demandPlusIND"
    vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_dem_regiPlusIND(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_dem_regiPlusIND(regi) AND sameas(entyPe,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyanddemPlusCHA"
    vm_fuExtr.fx(t,regi,enty,rlf)$(coal_sup_regiPlusCHA(regi) AND sameas(enty,"pecoal")) = 
        p47_coalExtr600(t,regi,enty,rlf)$(coal_sup_regiPlusCHA(regi) AND sameas(enty,"pecoal"));
    vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_dem_regiPlusCHA(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_dem_regiPlusCHA(regi) AND sameas(entyPe,"pecoal"));

$elseif.coalRegiPol %cm_coalExitRegi% == "supplyanddemPlusIND"
    vm_fuExtr.fx(t,regi,enty,rlf)$(coal_sup_regiPlusIND(regi) AND sameas(enty,"pecoal")) = 
        p47_coalExtr600(t,regi,enty,rlf)$(coal_sup_regiPlusIND(regi) AND sameas(enty,"pecoal"));
    vm_demPe.fx(t,regi,entyPe,entySe,te)$(coal_dem_regiPlusIND(regi) AND sameas(entyPe,"pecoal")) = 
        p47_coalDem600(t,regi,entyPe,entySe,te)$(coal_dem_regiPlusIND(regi) AND sameas(entyPe,"pecoal"));

$endif.coalRegiPol

display vm_demPe.l, vm_fuExtr.l, vm_Mport.l, vm_Xport.l;

*** EOF ./modules/47_regipol/regiCoalExit/bounds.gms
