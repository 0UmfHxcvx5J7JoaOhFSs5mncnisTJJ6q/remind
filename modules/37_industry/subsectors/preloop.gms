*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/preloop.gms

*** initialize captured CO2 parameter
pm_IndstCO2Captured(t,regi,entySe,entyFe,secInd37,emiMkt) = 0;

*' calculate carbon content of feedstock for chemicals subsector as difference between
*' combustion emissions factor of FE and industrial process emissions factor
*' of feedstocks
p37_FeedstockCarbonContent(ttot,regi,entyFe)
  = sum(se2fe(entySeFos,entyFe,te),
      pm_emifac(ttot,regi,entySeFos,entyFe,te,"co2") 
    - pm_emifacNonEnergy(ttot,regi,entySeFos,entyFe,"indst","co2")
    );

*** initialise indstry biomass, synfuels, and H2 shares
v37_demFeIndst_biomass_share.l(t,regi,entyFE,emiMkt)$(
                                       sum(entySeBio, sefe(entySeBio,entyFE)) 
                                   AND sector2emiMkt("indst",emiMkt)          )
  = sum(sefe(entySeBio,entyFe),
      p37_demFeSector_afterTax_baseline(t,regi,entySeBio,entyFe,"indst",emiMkt)
    )
  / ( sum(sefe(entySe,entyFe),
        p37_demFeSector_afterTax_baseline(t,regi,entySe,entyFe,"indst",emiMkt)
      )
    + sm_eps
    );

v37_demFeIndst_hydrogen_share.l(t,regi,entyFe,emiMkt)$(
                                      sector2emiMkt("indst",emiMkt) 
                                  AND entyFe2Sector(entyFe,"indst")
                                  AND sum(entySeSyn, sefe(entySeSyn,entyFe)) )
  = sum(sefe(entySeAllH2(entySe),entyFe),
      vm_demFeSector_afterTax.l(t,regi,entySe,entyFe,"indst",emiMkt)
    )
  / ( sum(sefe(entySe,entyFe),
        vm_demFeSector_afterTax.l(t,regi,entySe,entyFe,"indst",emiMkt)
      )
    + sm_eps
    );

v37_demFeIndst_feh2_share.l(t,regi,emiMkt)$( sector2emiMkt("indst",emiMkt) )
  = sum(sefe(entySe,"feh2s"),
      vm_demFeSector_afterTax.l(t,regi,entySe,"feh2s","indst",emiMkt)
    )
  / ( sum((sefe(entySe,entyFe),entyFe2Sector(entyFe,"indst")),
        vm_demFeSector_afterTax.l(t,regi,entySe,entyFe,"indst",emiMkt)
      )
    + sm_eps
    );

*** EOF ./modules/37_industry/subsectors/preloop.gms
