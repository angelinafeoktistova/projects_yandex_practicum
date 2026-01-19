# Zkoumání inzerátů na prodej bytů

Cílem projektu je prozkoumat data online servisu prodeje nemovitostí za několik let a identifikovat problémy se zápisem dat. Výsledky analýzy mohou být využity při konstrukci automatizovaného systému pro sledování anomálií a podvodných aktivit.


## Data
- CSV soubor
- Obsahuje: data z inzerátů o prodeji bytů (adresa, užitná plocha, plocha kuchyně, počet pokojů, blízkost k veřejným zařízením)

## Technologie
- Python: Pandas, Matplotlib, Numpy
- Jupyter Notebook


## Postup analýzy 
- Čištění a zpracování dat: práce s outliery a anomalií, doplnění chybejicích hodnot u jednotlivých charakteristik
- Analýza rozložení dat, včetně vizualizace
- Zkoumání vlivu parametrů bytu na cenu


## Výsledky
- Připravený a očištěný dataset pro analýzu, odstraněny anomálie a vyplněny chybějící hodnoty
- Připravená analýza prodeje bytů podle času a délky prodeje 
- Určeny hlavní faktory ovlivňující cenu bytu
- Zjištěny trendy v čase
- Stanoveny průměrné ceny za m² v nejpopulárnějších lokalitách
- Závěr: doporučení pro vylepšení systému sběru dat


