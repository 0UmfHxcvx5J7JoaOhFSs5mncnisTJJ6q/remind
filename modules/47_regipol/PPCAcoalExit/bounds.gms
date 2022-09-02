*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/bounds.gms

** Fix each unabated coal generation technology in each PPCA run to the  
** 2025 capacities in the NPi root of the DPE cascade 
$ifthen.ref not "%cm_PPCA_size%" == "none"
Execute_Loadpoint 'input_ref' p47_cap = vm_cap.l;

$ifthen.cov_coal not %cm_COVID_coal_scen% == "none"
vm_cap.fx("2025",regi,"pc",rlf) = p47_cap("2025",regi,"pc",rlf);
vm_cap.fx("2025",regi,"coalchp",rlf) = p47_cap("2025",regi,"coalchp",rlf);
vm_cap.fx("2025",regi,"igcc",rlf) = p47_cap("2025",regi,"igcc",rlf);
$endif.cov_coal

** Test constraints that fix EV and RE capacities to NPi levels
** Not active in final scenarios - used to confirm the retardation of EV
** and RE penetration caused by PPCA
$ifthen.EVRE %cm_EVRE% == "EV"
vm_cap.lo(t,regi,"apCarElT",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"apCarElT",rlf);
$elseif.EVRE %cm_EVRE% == "RE"
vm_cap.lo(t,regi,"spv",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"spv",rlf);
vm_cap.lo(t,regi,"wind",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"wind",rlf);
vm_cap.lo(t,regi,"csp",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"csp",rlf);
vm_cap.lo(t,regi,"solhe",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"solhe",rlf);
vm_cap.lo(t,regi,"storspv",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"storspv",rlf);
vm_cap.lo(t,regi,"storwind",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"storwind",rlf);
vm_cap.lo(t,regi,"storcsp",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"storcsp",rlf);
$endif.EVRE
$endif.ref

$ifthen.policy %cm_PPCA_pol% == "demand"


$endif.policy


** EOF ./modules/47_regipol/PPCAcoalExit/bounds.gms