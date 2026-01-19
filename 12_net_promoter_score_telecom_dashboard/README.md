# Tvorba dashboardu o NPS telekomunikační společnosti – Tableau vizualizace
Cíl projektu: Na základě výsledků průzkumů klientů telekomunikační společnosti se zjištěním skutečné úrovně NPS (zákaznická věrnost) analyzovat, jak se NPS mění v závislosti na uživatelských charakteristikách. Respondentům byla položena otázka: "Ohodnoťte na škále 1–10 pravděpodobnost, že byste firmu doporučili přátelům". Hodnocení bylo rozděleno do tří skupin: 9–10 bodů — promotéři (příznivci), 7–8 bodů — pasivní, 0–6 bodů — kritici.


## Data
- Zdroj: databáze SQLite
- Obsahují: data o uživatelích (NPS skóre, pohlaví, věk, země, město, typ zařízení, objem datového provozu, stav klienta apod.)

## Technologie
- Tableau (Actions, Sets, Parametry, Top-N, filtry, různé typy grafů, prezentace)
- Python (SQLAlchemy, NumPy, Pandas)
- SQL (dotaz do SQLite)

## Postup a výsledky – prezentace „Analytika NPS telekomunikační firmy“, která obsahuje:
- Dashboard "Analýza uživatelů podle charakteristik": věk, pohlaví, kombinace věk × pohlaví, typ zařízení, města, objem datového provozu, stav klienta.
- Dashboard "Hodnocení NPS podle různých kritérií": výpočet NPS, průměrné NPS skóre; rozložení uživatelů podle NPS skupin; NPS podle věku, pohlaví, města.
- Dashboard "Analýza promotérů (příznivců) podle charakteristik": počet promotérů a jejich průměrné NPS skóre; rozložení promotérů podle věku, pohlaví, typu zařízení; procento promotérů podle měst.

# Prezentace je dostupná na tom [odkazu](https://public.tableau.com/views/NPSproject_17151924148380/NPS?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link) 
