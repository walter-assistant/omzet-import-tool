# Bonarchief en productie

Productie staat los van omzet. PDF en paginabrontekst worden lokaal in IndexedDB bewaard. SHA-256 voorkomt herhaling van dezelfde PDF; andere bonnen van hetzelfde werk vereisen handmatige overlapcontrole. Alleen gecontroleerde uitvoeringsaantallen tellen per uitvoeringsjaar. Geen OCR; scans vragen handmatige invoer.

Cloud: voer bonarchief-migration.sql uit in project zkocfksybffyokzafwbd. Zorg voor een eigen app-account onder Authentication / Users voor het aangewezen beheerdersadres, met email/wachtwoord. De Supabase-dashboardlogin is geen app-account. Log in bij Bonarchief, synchroniseer en controleer op een tweede apparaat. Cloud is nog niet live bewezen. Bestaande omzettoegang blijft ongewijzigd.

Zonder cloud: alleen lokale bewaring; download een archiefback-up inclusief PDF. Conflicten tussen apparaten blokkeren synchronisatie met behoud van lokale data. Herstel overschrijft bestaande lokale bonnen niet.

Tests: node --test tests/production-core.test.cjs. Browser gecontroleerd: PDF-extractie, controleformulier, totalen, duplicaten, herladen en back-up.
