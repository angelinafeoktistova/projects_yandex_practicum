# Rozhodování v byznysu: Prioritizace hypotéz a A/B testování
Ve spolupráci s marketingovým oddělením byl připraven seznam hypotéz pro zvýšení tržeb velkého e-shopu. Cílem projektu bylo prioritizovat hypotézy pomocí frameworků ICE a RICE, analyzovat výsledky A/B testů a rozhodnout, zda v testování pokračovat, nebo test ukončit a zavést vítěznou variantu.


## Data
- Tři CSV soubory: hypotézy, objednávky, uživatelé
- Obsah: hypotézy (ICE/RICE), data o objednávkách a návštěvách s rozdělením do A/B skupin

## Technologie
- Python (Pandas, NumPy, Matplotlib, SciPy)
- Jupyter Notebook

## Postup analýzy 

- Prioritizace hypotéz pomocí ICE a RICE
- Kontrola kvality dat
- Příprava a analýza kumulativních dat
- Analýza outlierů a anomálií
- Testování statistické významnosti v metrikách podle skupin
- Rozhodnutí na základě výsledků A/B testů

## Výsledky
- Prioritizované hypotézy (ICE a RICE)
- Analyzovány výsledky A/B testu
- Vizualizace: kumulativní tržby, průměrné hodnoty objednávek a konverze podle skupin
- Statisticky významné rozdíly v konverzi; u průměrné hodnoty objednávky výsledky závisely na práci s outliery
- Doporučení ukončit testování a zavést vítěznou variantu
