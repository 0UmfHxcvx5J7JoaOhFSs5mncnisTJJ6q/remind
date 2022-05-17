*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/bounds.gms

* Execute_Loadpoint 'input_ref' p47_prodCouple = pm_prodCouple;
* Execute_Loadpoint 'input_ref' p47_prodSe = vm_prodSe.l;
* Execute_Loadpoint 'input_ref' p47_prodFe = vm_prodFe.l;
* Execute_Loadpoint 'input_ref' p47_co2CCS = vm_co2CCS.l;


$ifthen.ref not "%cm_PPCA_size%" == "current"
Execute_Loadpoint 'input_ref' p47_cap = vm_cap.l;

* Set upper bound on all technologies to 4x reference scenario to prevent corner solutions
* loop(t$(t.val ge cm_startyear),
*     loop(regi,
*         loop(te,
*             if( (p47_cap(t,regi,te,"1") gt 1e-4 and vm_cap.up(t,regi,te,"1") gt (10 * p47_cap(t,regi,te,"1")) ),
*                 vm_cap.up(t,regi,te,"1") = 10 * p47_cap(t,regi,te,"1");
*             elseif(p47_cap(t,regi,te,"1") le 1e-4 and vm_cap.up(t,regi,te,"1") gt (1e3 * p47_cap(t,regi,te,"1")) ),
*                 vm_cap.up(t,regi,te,"1") = 1e3 * p47_cap(t,regi,te,"1");
*             );
*         );
*     );
* );

$ifthen.cov_coal not %cm_COVID_coal_scen% == "none"
vm_cap.fx("2025",regi,"pc",rlf) = p47_cap("2025",regi,"pc",rlf);
vm_cap.fx("2025",regi,"coalchp",rlf) = p47_cap("2025",regi,"coalchp",rlf);
vm_cap.fx("2025",regi,"igcc",rlf) = p47_cap("2025",regi,"igcc",rlf);

vm_cap.fx("2030",regi,"pc",rlf)$(p47_deltaCap_REsub("2030",regi) ge 1e-3) = p47_cap("2030",regi,"pc",rlf);
vm_cap.fx("2030",regi,"coalchp",rlf)$(p47_deltaCap_REsub("2030",regi) ge 1e-3) = p47_cap("2030",regi,"coalchp",rlf);
vm_cap.fx("2030",regi,"igcc",rlf)$(p47_deltaCap_REsub("2030",regi) ge 1e-3) = p47_cap("2030",regi,"igcc",rlf);

$endif.cov_coal

$ifthen.RE_sub %cm_pubfinex_pol% == "RE_sub"
vm_deltaCap.lo("2025",regi,teLearn(te),rlf)$(p47_deltaCap_REsub("2025",regi) ge 1e-3) = p47_deltaCap("2025",regi,te,rlf);
vm_deltaCap.lo("2030",regi,teLearn(te),rlf)$(p47_deltaCap_REsub("2030",regi) ge 1e-3) = p47_deltaCap("2030",regi,te,rlf);
$endif.RE_sub

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

* Fix sector shares to reference levels to prevent wild fluctuations due to coal phaseout
* Execute_Loadpoint 'input_ref' p11_share_sector = p11_share_sector;
* Execute_Loadpoint 'input_ref' p47_demPe = vm_demPe.l;


$endif.policy


** EOF ./modules/47_regipol/PPCAcoalExit/bounds.gms