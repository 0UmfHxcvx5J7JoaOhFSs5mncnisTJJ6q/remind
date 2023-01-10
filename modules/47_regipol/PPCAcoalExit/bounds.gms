*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/PPCAcoalExit/bounds.gms

* Execute_Loadpoint 'input_ref' p47_prodCouple = pm_prodCouple;
* Execute_Loadpoint 'input_ref' p47_prodFe = vm_prodFe.l;
* Execute_Loadpoint 'input_ref' p47_co2CCS = vm_co2CCS.l;

Execute_Loadpoint 'input_ref' p47_prodSe = vm_prodSe.l;

$ifthen.cond %cm_REdir_mobil% == "hi_oecd_cond"
Execute_Loadpoint 'input_bau' p47_costTeCapital_bau = vm_costTeCapital.l;
Execute_Loadpoint 'input_bau' p47_prodSe_bau = vm_prodSe.l;
Execute_Loadpoint 'input_bau' p47_deltaCap_bau = vm_deltaCap.l;

display p47_deltaCap_bau, p47_prodSe_bau, p47_costTeCapital_bau;
$endif.cond

$ifthen.ref not "%cm_PPCA_size%" == "current"
Execute_Loadpoint 'input_ref' p47_cap = vm_cap.l;

$ifthen.cov_coal not %cm_COVID_coal_scen% == "none"
vm_cap.l("2025",regi,"pc",rlf) = p47_cap("2025",regi,"pc",rlf);
vm_cap.l("2025",regi,"coalchp",rlf) = p47_cap("2025",regi,"coalchp",rlf);
vm_cap.l("2025",regi,"igcc",rlf) = p47_cap("2025",regi,"igcc",rlf);
vm_cap.up("2025",regi,"pc",rlf) = p47_cap("2025",regi,"pc",rlf);
vm_cap.up("2025",regi,"coalchp",rlf) = p47_cap("2025",regi,"coalchp",rlf);
vm_cap.up("2025",regi,"igcc",rlf) = p47_cap("2025",regi,"igcc",rlf);

* vm_cap.fx("2030",regi,"pc",rlf)$(p47_deltaCap_REsub("2030",regi) ge 1e-3) = p47_cap("2030",regi,"pc",rlf);
* vm_cap.fx("2030",regi,"coalchp",rlf)$(p47_deltaCap_REsub("2030",regi) ge 1e-3) = p47_cap("2030",regi,"coalchp",rlf);
* vm_cap.fx("2030",regi,"igcc",rlf)$(p47_deltaCap_REsub("2030",regi) ge 1e-3) = p47_cap("2030",regi,"igcc",rlf);

$endif.cov_coal

$ifthen.REdirect %cm_pubfinex_pol% == "REdirect"
vm_cap.lo("2025",regi,teRe(te),rlf) = 0.99*p47_cap("2025",regi,te,rlf);
vm_cap.lo("2025",regi,teNoTransform(te),rlf) = 0.99*p47_cap("2025",regi,te,rlf);

vm_cap.lo("2025",regi,teRe(te),rlf) = 0.99*p47_cap("2025",regi,te,rlf);
vm_cap.lo("2025",regi,teNoTransform(te),rlf) = 0.99*p47_cap("2025",regi,te,rlf);

v_costInvTeDir.lo("2025",regi,teRe(te)) = 0.99*p47_ref_costInvTeDir_RE("2025",regi,te);
v_costInvTeDir.lo("2025",regi,teNoTransform(te)) = 0.99*p47_ref_costInvTeDir_RE("2025",regi,te);

v_costInvTeAdj.lo("2025",regi,teRe(te)) = 0.99*p47_ref_costInvTeAdj_RE("2025",regi,te);
v_costInvTeAdj.lo("2025",regi,teNoTransform(te)) = 0.99*p47_ref_costInvTeAdj_RE("2025",regi,te);

Execute_Loadpoint 'input_ref' p47_REdirect = v47_REdirect.l;

if(cm_startyear > 2025,
    v47_REdirect.fx(regi) = p47_REdirect(regi);
);

$ifthenE.himob sameas("%cm_REdir_mobil%","hi_oecd_2030")or(sameas("%cm_REdir_mobil%","hi_oecd_cond"))
vm_cap.lo("2030",regi,teRe(te),rlf) = 0.99*p47_cap("2030",regi,te,rlf);
vm_cap.lo("2030",regi,teNoTransform(te),rlf) = 0.99*p47_cap("2030",regi,te,rlf);

vm_cap.lo("2030",regi,teRe(te),rlf) = 0.99*p47_cap("2030",regi,te,rlf);
vm_cap.lo("2030",regi,teNoTransform(te),rlf) = 0.99*p47_cap("2030",regi,te,rlf);

v_costInvTeDir.lo("2030",regi,teRe(te)) = 0.99*p47_ref_costInvTeDir_RE("2030",regi,te);
v_costInvTeDir.lo("2030",regi,teNoTransform(te)) = 0.99*p47_ref_costInvTeDir_RE("2030",regi,te);

v_costInvTeAdj.lo("2030",regi,teRe(te)) = 0.99*p47_ref_costInvTeAdj_RE("2030",regi,te);
v_costInvTeAdj.lo("2030",regi,teNoTransform(te)) = 0.99*p47_ref_costInvTeAdj_RE("2030",regi,te);

$endif.himob

$endif.REdirect

$ifthen.EVRE %cm_EVRE% == "EV"
vm_cap.lo(t,regi,"apCarElT",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"apCarElT",rlf);
$elseif.EVRE %cm_EVRE% == "RE"
vm_cap.lo(t,regi,"spv",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"spv",rlf);
vm_cap.lo(t,regi,"wind",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"wind",rlf);
* vm_cap.lo(t,regi,"csp",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"csp",rlf);
* vm_cap.lo(t,regi,"solhe",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"solhe",rlf);
vm_cap.lo(t,regi,"storspv",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"storspv",rlf);
vm_cap.lo(t,regi,"storwind",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"storwind",rlf);
* vm_cap.lo(t,regi,"storcsp",rlf)$(t.val ge cm_startyear) = p47_cap(t,regi,"storcsp",rlf);
$endif.EVRE
$endif.ref

* $ifthen.policy %cm_PPCA_pol% == "demand"


* $endif.policy


** EOF ./modules/47_regipol/PPCAcoalExit/bounds.gms