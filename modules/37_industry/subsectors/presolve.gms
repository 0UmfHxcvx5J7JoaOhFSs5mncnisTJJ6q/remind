*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/presolve.gms

*' The process emissions from cement production are calculated using a fixed
*' CO2-to-clinker ratio (0.5262 kg CO2/kg clinker), region-specific
*' clinker-to-cement ratios, and the cement production from the production
*' function.
*' Last iteration's cement production value is used, since the MAC mechanism is
*' outside of the optimisation loop.
if (cm_co2cement_process_by_equation eq 0,
  vm_emiIndBase.fx(ttot,regi,"co2cement_process","cement")$( ttot.val ge 2005 )
    = s37_clinker_process_CO2
    * p37_clinker_cement_ratio(ttot,regi)
    * vm_cesIO.l(ttot,regi,"ue_cement")
    / sm_c_2_co2;
else
  vm_emiIndBase.lo(ttot,regi,"co2cement_process","cement") = 0;
  vm_emiIndBase.up(ttot,regi,"co2cement_process","cement") = Inf;
);

*** EOF ./modules/37_industry/subsectors/presolve.gms
