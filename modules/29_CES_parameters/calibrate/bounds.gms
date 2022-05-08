*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/calibrate/bounds.gms

vm_cesIO.fx(t0,regi_dyn29(regi),in_industry_dyn37(in))$( 
                                              NOT sameas(in,"en_otherInd_hth") )
  = pm_cesdata(t0,regi,in,"quantity");

*' Reduce the lower limit on the CES function to accommodate less utilised
*' production factors in (energetically) small regions.  (Example: gas heating
*' in Sub-Sahara Africa -- SSA/enhgab).

if (smax((t,regi_dyn29(regi),ipf)$(    t.val gt 2005 
                                  AND NOT ue_industry_dyn37(ipf) ),
      vm_cesIO.lo(t,regi,ipf)
    - (0.95 * pm_cesdata(t,regi,ipf,"quantity"))) gt 0,

  put logfile, ">>> Modifyipfg vm_cesIO lower bounds <<<" /;
  loop ((regi_dyn29(regi),ipf,t)$(    t.val gt 2005 
                                  AND NOT ue_industry_dyn37(ipf) ),
    if (vm_cesIO.lo(t,regi,ipf) gt 0.95 * pm_cesdata(t,regi,ipf,"quantity"),
      put "vm_cesIO.lo(", t.tl, ",", regi.tl, ",", ipf.tl, ")   ";
      put vm_cesIO.lo(t,regi,ipf), " -> ";
      put (0.95 * pm_cesdata(t,regi,ipf,"quantity")) /;
  
      vm_cesIO.lo(t,regi,ipf)
      = min(
          vm_cesIO.lo(t,regi,ipf),
          ( pm_cesdata(t,regi,ipf,"quantity")
          * 0.95
          ));
    );
  );

  putclose logfile, " " /;
);

*** EOF ./modules/29_CES_parameters/calibrate/bounds.gms

