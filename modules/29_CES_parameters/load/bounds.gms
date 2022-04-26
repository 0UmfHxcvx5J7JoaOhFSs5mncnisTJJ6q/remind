*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/29_CES_parameters/load/bounds.gms

* Apply fixings from offset quantities
vm_cesIO.fx(t,regi,in)$( pm_cesdata(t,regi,in,"fx") )
  = pm_cesdata(t,regi,in,"fx");

*** EOF ./modules/29_CES_parameters/load/bounds.gms

