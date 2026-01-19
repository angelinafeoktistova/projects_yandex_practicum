/* 1 Zobrazte všechny záznamy z tabulky company pro společnosti, které byly uzavřeny. */

SELECT *
FROM company
WHERE status = 'closed';

/* 2 Zobrazte množství získaných prostředků pro americké zpravodajské společnosti. Použijte data z tabulky company. Seřaďte tabulku podle pole funding_total sestupně. */

SELECT funding_total
FROM company
WHERE category_code = 'news'
      AND country_code = 'USA'
ORDER BY funding_total DESC;

/* 3 Najděte celkovou sumu akvizic (koupené společnosti) v dolarech. Zahrňte pouze akvizice, které byly provedeny v hotovosti v letech 2011–2013. */

SELECT  SUM(price_amount)
FROM acquisition
WHERE   EXTRACT(YEAR FROM acquired_at) BETWEEN 2011 AND 2013
        AND term_code = 'cash';

/* 4 Zobrazte jméno, příjmení a názvy účtů v poli network_username, jejichž názvy začínají na 'Silver'. */

SELECT  first_name,
        last_name,
        network_username
FROM people
WHERE network_username LIKE 'Silver%';

/* 5 Zobrazte všechny informace o lidech, jejichž názvy účtů v poli network_username obsahují podřetězec 'money' a příjmení začíná na 'K'. */

SELECT *
FROM people
WHERE network_username LIKE '%money%'
  AND last_name LIKE 'K%';

/* 6 Pro každou zemi zobrazte celkovou sumu investic, které získaly společnosti registrované v dané zemi. Zemi lze určit podle kódu země. Seřaďte výsledky podle sumy sestupně. */

SELECT  country_code, 
        SUM(funding_total) AS total_funding
FROM company
GROUP BY country_code
ORDER BY total_funding DESC;

/* 7 Sestavte tabulku s datem investičního kola a minimální a maximální hodnotou investice v tomto datu. Zahrňte pouze záznamy, kde minimální investice není nulová a nerovná se maximální hodnotě. */

WITH mm AS (
            SELECT  funded_at,
                    MIN(raised_amount) AS m_min,
                    MAX(raised_amount) AS m_max
            FROM funding_round
            GROUP BY funded_at)

SELECT  funded_at,
        m_min,
        m_max
FROM mm
WHERE mm.m_min <> 0
  AND mm.m_min <> mm.m_max

/* 8 Vytvořte pole s kategoriemi:
- Pro fondy, které investují do 100 a více společností, přiřaďte kategorii high_activity.
- Pro fondy, které investují od 20 do 99 společností, přiřaďte kategorii middle_activity.
- Pokud fond investuje do méně než 20 společností, přiřaďte kategorii low_activity.
Zobrazte všechna pole tabulky fund a nové pole s kategoriemi. */

SELECT *,
       CASE
           WHEN invested_companies >= 100 THEN 'high_activity'
           WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
           WHEN invested_companies < 20 THEN 'low_activity'
       END AS activity_category
FROM fund;


/* 9 Pro každou kategorii z předchozího úkolu spočítejte průměrný počet investičních kol, do kterých fondy zasahovaly, zaokrouhlený na celé číslo. Zobrazte kategorii a průměrný počet kol. Seřaďte tabulku podle průměru vzestupně. */

WITH cat AS (
            SELECT  *,
                    CASE
                        WHEN invested_companies>=100 THEN 'high_activity'
                        WHEN invested_companies>=20 THEN 'middle_activity'
                        ELSE 'low_activity'
                    END AS activity
            FROM fund)

SELECT  activity, 
        ROUND (AVG(investment_rounds)) AS avg_rounds
FROM cat
GROUP BY activity
ORDER BY avg_rounds;

/* 10 Analyzujte země, ve kterých se nacházejí fondy, které nejčastěji investují do startupů. 
Pro každou zemi spočítejte minimální, maximální a průměrný počet společností, do kterých fondy založené v letech 2010–2012 investovaly. 
Vyloučte země, kde minimální počet investovaných společností je nula. 
Zobrazte deset nejaktivnějších zemí podle průměrného počtu investovaných společností sestupně, a pak podle kódu země vzestupně. */

WITH c AS (
            SELECT  country_code,
                    MIN (invested_companies) AS min_invested,
                    MAX (invested_companies) AS max_invested,
                    AVG (invested_companies) AS avg_invested
            FROM fund
            WHERE EXTRACT(YEAR FROM CAST(founded_at AS timestamp)) BETWEEN 2010 AND 2012
            GROUP BY country_code)

SELECT  c.country_code,
        c.min_invested,
        c.max_invested,
        c.avg_invested
FROM c
WHERE c.min_invested != 0
ORDER BY avg_invested DESC, country_code
LIMIT 10

/* 11 Zobrazte jméno a příjmení všech zaměstnanců startupů. Přidejte pole s názvem školy, kterou zaměstnanec absolvoval, pokud je tato informace dostupná. */

SELECT  p.first_name,
        p.last_name,
        e.instituition
FROM people AS p
LEFT JOIN education AS e ON e.person_id  = p.id;

/* 12 Pro každou společnost spočítejte počet škol, které absolvovali její zaměstnanci. Zobrazte název společnosti a počet unikátních škol. Sestavte top 5 společností podle počtu škol. */

SELECT  DISTINCT c.name,
        COUNT(DISTINCT(e.instituition)) AS cnt_inst
FROM company AS c
LEFT JOIN people AS p ON c.id = p.company_id
JOIN education AS e ON p.id= e.person_id
GROUP BY c.name
ORDER BY cnt_inst DESC
LIMIT 5;

/* 13 Sestavte seznam unikátních názvů uzavřených společností, jejichž první investiční kolo bylo zároveň posledním. */

SELECT  DISTINCT (c.name)
FROM company AS c
INNER JOIN funding_round AS fr ON c.id = fr.company_id
WHERE   c.status = 'closed'
        AND fr.is_first_round = 1
        AND fr.is_last_round = 1;

/* 14 Sestavte seznam unikátních čísel zaměstnanců, kteří pracují ve společnostech vybraných v předchozím úkolu. */

WITH cn AS (
    SELECT DISTINCT c.name,
           c.id
    FROM company AS c
    INNER JOIN funding_round AS fr ON c.id = fr.company_id
    WHERE c.status = 'closed'
      AND fr.is_first_round = 1
      AND fr.is_last_round = 1
)
SELECT DISTINCT p.id
FROM people AS p
INNER JOIN cn ON cn.id = p.company_id;

/* 15 Sestavte tabulku obsahující unikátní dvojice čísel zaměstnanců z předchozího úkolu a školu, kterou zaměstnanec absolvoval. */

WITH cn AS (
    SELECT DISTINCT c.name,
           c.id
    FROM company AS c
    INNER JOIN funding_round AS fr ON c.id = fr.company_id
    WHERE c.status = 'closed'
      AND fr.is_first_round = 1
      AND fr.is_last_round = 1),
  
    peo AS (
        SELECT DISTINCT (p.id)
        FROM people AS p
        INNER JOIN cn ON cn.id = p.company_id)

SELECT  DISTINCT (peo.id),
        e.instituition
FROM education AS e 
INNER JOIN peo ON peo.id = e.person_id

/* 16 Spočítejte počet škol pro každého zaměstnance z předchozího úkolu. Zahrňte i opakované absolvování stejné školy. */

WITH cn AS (
    SELECT DISTINCT c.name,
           c.id
    FROM company AS c
    INNER JOIN funding_round AS fr ON c.id = fr.company_id
    WHERE c.status = 'closed'
      AND fr.is_first_round = 1
      AND fr.is_last_round = 1),
  
    peo AS (
        SELECT DISTINCT (p.id)
        FROM people AS p
        INNER JOIN cn ON cn.id = p.company_id)
  
SELECT DISTINCT(peo.id),
       COUNT(e.instituition)
FROM education AS e 
INNER JOIN peo ON peo.id = e.person_id
GROUP BY peo.id

/* 17 Doplněním předchozího úkolu zobrazte průměrný počet škol (včetně všech, ne jen unikátních), které absolvovali zaměstnanci různých společností. Zobrazte pouze jeden záznam, skupinování není potřeba. */

WITH cn AS (
    SELECT  DISTINCT (c.name),
            c.id
    FROM company AS c
    INNER JOIN funding_round AS fr ON c.id = fr.company_id
    WHERE   c.status = 'closed'
            AND fr.is_first_round = 1
            AND fr.is_last_round = 1),
       
    peo AS (
    SELECT  DISTINCT(p.id)
    FROM people AS p
    INNER JOIN cn ON cn.id = p.company_id),

    ins AS (
        SELECT  peo.id,
                COUNT(e.instituition) AS cnt
       FROM education AS e 
       INNER JOIN peo ON peo.id = e.person_id
       GROUP BY peo.id)
       
SELECT AVG(ins.cnt)
FROM ins;

/* 18 Napište podobný dotaz: zobrazte průměrný počet škol (včetně všech) absolvovaných zaměstnanci Socialnet. */

WITH cn AS (
        SELECT  DISTINCT (c.name),
                c.id
        FROM company AS c
        INNER JOIN funding_round AS fr ON c.id = fr.company_id
        WHERE c.name = 'Socialnet'),
       
    peo AS (
        SELECT  DISTINCT(p.id)
        FROM people AS p
        INNER JOIN cn ON cn.id = p.company_id),

    ins AS (
        SELECT  peo.id,
                COUNT(e.instituition) AS cnt
        FROM education AS e 
        INNER JOIN peo ON peo.id = e.person_id
        GROUP BY peo.id)
       
SELECT AVG(ins.cnt)
FROM ins;

/* 19 Sestavte tabulku s poli:
- name_of_fund — název fondu;
- name_of_company — název společnosti;
- amount — výše investice, kterou společnost získala.
Zahrňte společnosti, které měly více než šest důležitých kol a investiční kola proběhla v letech 2012–2013. */

WITH c AS (
        SELECT  c.name AS name_of_company,
                c.id  
        FROM company AS c
        WHERE c.milestones > 6),
      
    fr AS (
        SELECT  fr.raised_amount AS amount,
                fr.id,
                fr.company_id
        FROM funding_round AS fr
        WHERE EXTRACT(YEAR FROM CAST(fr.funded_at AS timestamp)) BETWEEN 2012 AND 2013),
       
    f AS (
        SELECT  f.name AS name_of_fund,
                f.id
        FROM fund AS f)

SELECT  f.name_of_fund,
        c.name_of_company,
        fr.amount
FROM f
INNER JOIN investment AS inv ON inv.fund_id = f.id
INNER JOIN fr ON inv.funding_round_id = fr.id
INNER JOIN c ON fr.company_id = c.id      

/* 20 Zobrazte tabulku obsahující:
- název kupující společnosti;
- částku transakce;
- název kupované společnosti;
- částku investic vložených do kupované společnosti;
- poměr, který ukazuje, kolikrát částka nákupu převyšuje investice, zaokrouhlený na celé číslo.
Nezahrnujte transakce s nulovou částkou nákupu. Pokud investice do společnosti jsou nulové, vynechejte takovou společnost. Seřaďte podle částky transakce sestupně a podle názvu kupované společnosti vzestupně. Omezení na prvních 10 záznamů. */

SELECT   b.name AS acquiring_company_name,
        ac.price_amount AS price,
        s.name AS acquired_company_name, 
        s.funding_total, 
        ROUND(ac.price_amount / s.funding_total)
FROM acquisition AS ac
JOIN company AS b ON b.id = ac.acquiring_company_id 
JOIN company AS s ON s.id = ac.acquired_company_id  
WHERE   ac.price_amount > 0
        AND s.funding_total > 0
ORDER BY  ac.price_amount DESC, 
          s.name 
LIMIT 10;

/* 21 Zobrazte tabulku s názvy společností z kategorie social, které získaly financování v letech 2010–2013. Zkontrolujte, že investice nejsou nulové. Zobrazte také číslo měsíce, kdy kolo proběhlo. */

SELECT  c.name,
        EXTRACT(MONTH FROM CAST (fr.funded_at AS timestamp)) AS month
FROM company AS c
INNER JOIN funding_round AS fr ON c.id = fr.company_id
WHERE   EXTRACT(YEAR FROM CAST (fr.funded_at AS timestamp)) BETWEEN 2010  AND 2013 
    AND c.category_code = 'social'
    AND fr.raised_amount > 0;

/* 22 Vyberte data podle měsíců od 2010 do 2013, kdy proběhla investiční kola. 
Seskupte podle čísla měsíce a zobrazte:
- číslo měsíce;
- počet unikátních fondů z USA, které investovaly v tomto měsíci;
- počet společností, které byly koupeny;
- celkovou sumu transakcí koupených společností. */

WITH inv AS (
        SELECT  EXTRACT(MONTH FROM fr.funded_at) AS month, 
                COUNT(DISTINCT f.id) AS count_fund
        FROM investment AS i 
        LEFT JOIN funding_round AS fr ON fr.id = i.funding_round_id
        LEFT JOIN fund AS f ON f.id = i.fund_id
        WHERE   f.country_code = 'USA'
                AND EXTRACT(YEAR FROM CAST(fr.funded_at AS timestamp)) BETWEEN 2010 AND 2013
        GROUP BY month), 


    a AS (
        SELECT  EXTRACT(MONTH FROM a.acquired_at) AS month,
                COUNT(a.acquired_company_id) AS count_company_usa, 
                SUM(a.price_amount) AS sum_price_amount 
        FROM acquisition AS a 
        WHERE   EXTRACT(YEAR FROM CAST(a.acquired_at AS timestamp)) BETWEEN 2010 AND 2013
        GROUP BY month) 
      
      
SELECT  inv.month, 
        inv.count_fund, 
        a.count_company_usa,
        a.sum_price_amount
FROM inv
LEFT JOIN a ON a.month = inv.month;

/* 23.
Sestavte kontingenční tabulku a zobrazte průměrnou sumu investic podle zemí, kde jsou startupy registrované v letech 2011, 2012 a 2013. Data pro každý rok v samostatném sloupci. Seřaďte tabulku podle průměrné investice za rok 2011 sestupně. */

WITH i_11 AS (
            SELECT  c.country_code,
                    AVG(c.funding_total) AS inv_2011
            FROM company AS c
            WHERE EXTRACT(YEAR FROM CAST(founded_at AS timestamp)) = 2011
            GROUP BY c.country_code),


    i_12 AS (
            SELECT  c.country_code,
                    AVG(c.funding_total) AS inv_2012
            FROM company AS c
            WHERE EXTRACT(YEAR FROM CAST(founded_at AS timestamp)) = 2012
            GROUP BY c.country_code),

    i_13 AS (
            SELECT  c.country_code,
                    AVG(c.funding_total) AS inv_2013
            FROM company AS c
            WHERE EXTRACT(YEAR FROM CAST(founded_at AS timestamp)) = 2013
            GROUP BY c.country_code)

SELECT  i_11.country_code,
        i_11.inv_2011,
        i_12.inv_2012,
        i_13.inv_2013
FROM i_11
INNER JOIN i_12 ON i_11.country_code = i_12.country_code
INNER JOIN i_13 ON i_12.country_code = i_13.country_code
ORDER BY i_11.inv_2011 DESC;
