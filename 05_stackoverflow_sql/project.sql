/* 1 Spočítejte počet otázek, které získaly více než 300 bodů nebo byly alespoň 100krát přidány do „Záložek“. */

SELECT  COUNT(*)
FROM stackoverflow.post_types AS pt
JOIN stackoverflow.posts AS po ON pt.id = po.post_type_id 
WHERE pt.type = 'Question' AND (po.score > 300 OR po.favorites_count >= 100)

/* 2 Kolik otázek bylo v průměru položeno každý den od 1. do 18. listopadu 2008? Výsledek zaokrouhlete na celé číslo. */

WITH cnt AS (
            SELECT  COUNT(po.id) AS cnt_per_day
            FROM stackoverflow.post_types AS pt
            JOIN stackoverflow.posts AS po ON pt.id = po.post_type_id
            WHERE pt.type = 'Question' AND po.creation_date::date BETWEEN '2008-11-01' AND '2008-11-18'
            GROUP BY po.creation_date::date)
SELECT  ROUND(AVG(cnt_per_day))
FROM cnt;

/* 3 Kolik uživatelů získalo odznaky hned v den registrace? Zobrazte počet unikátních uživatelů. */

SELECT  COUNT(DISTINCT u.id) AS users_with_badge
FROM stackoverflow.badges AS b
INNER JOIN stackoverflow.users AS u ON b.user_id = u.id
WHERE u.creation_date::date = b.creation_date::date;

/* 4 Kolik unikátních příspěvků uživatele jménem Joel Coehoorn získalo alespoň jeden hlas? */

SELECT  COUNT(DISTINCT post_id)
FROM stackoverflow.votes AS v
JOIN stackoverflow.posts AS p ON v.post_id = p.id
JOIN stackoverflow.users AS u ON p.user_id = u.id
WHERE u.display_name = 'Joel Coehoorn'

/* 5 Vypište všechna pole z tabulky vote_types. Přidejte sloupec rank, který bude obsahovat pořadí záznamů v opačném pořadí. Tabulka má být seřazena podle id. */


SELECT  *,
        ROW_NUMBER() OVER(ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id;


/* 6 Vyberte 10 uživatelů, kteří dali nejvíce hlasů typu „Close“. Zobrazte tabulku se dvěma poli: ID uživatele a počet hlasů. Seřaďte podle počtu hlasů sestupně a pak podle ID uživatele sestupně. */

SELECT  u.id AS user_id,
        COUNT (v.id) AS cnt_vote
FROM stackoverflow.users AS u
INNER JOIN stackoverflow.votes AS v ON u.id = v.user_id
INNER JOIN stackoverflow.vote_types AS vt ON v.vote_type_id = vt.id
WHERE vt.name = 'Close'
GROUP BY u.id
ORDER BY COUNT(v.id) DESC, user_id DESC
LIMIT 10;


/* 7 Vyberte 10 uživatelů podle počtu odznaků získaných mezi 15. listopadem a 15. prosincem 2008. Zobrazte: ID uživatele, počet odznaků a místo v žebříčku (více odznaků = vyšší místo). U uživatelů se stejným počtem odznaků dejte stejné místo. Seřaďte podle počtu odznaků sestupně, pak podle ID vzestupně. */

WITH agg AS (
            SELECT  bd.user_id, 
                    COUNT(*) AS cnt_bd
            FROM stackoverflow.badges AS bd
            WHERE bd.creation_date::date BETWEEN '2008-11-15' AND  '2008-12-15'
            GROUP BY bd.user_id), 

     ranks AS (
            SELECT  user_id, cnt_bd,
                    DENSE_RANK() OVER (ORDER BY cnt_bd DESC) AS rank
            FROM agg
            )

SELECT  user_id, 
        cnt_bd, 
        rank 
FROM ranks
ORDER BY cnt_bd DESC, user_id ASC
LIMIT 10;


/* 8 Kolik bodů průměrně získá příspěvek každého uživatele? Zobrazte: název příspěvku, ID uživatele, počet bodů příspěvku a průměrný počet bodů uživatele na příspěvek (zaokrouhlený na celé číslo). Nezahrnujte příspěvky bez názvu nebo s nulovým počtem bodů. */

SELECT  title,
        user_id,
        score AS cnt_score,
        ROUND(AVG(score) OVER (PARTITION BY user_id)) AS avg_scope
FROM stackoverflow.posts 
WHERE title IS NOT NULL
AND score != 0;

/* 9 Zobrazte názvy příspěvků, které napsali uživatelé s více než 1000 odznaky. Příspěvky bez názvu vynechejte. */

WITH sc AS (
            SELECT  user_id,
                    COUNT(user_id) AS cnt_badges
      FROM stackoverflow.badges
      GROUP BY user_id)
                
SELECT  title
FROM stackoverflow.posts AS po
JOIN sc ON sc.user_id=po.user_id
WHERE title IS NOT NULL
AND sc.cnt_badges > 1000;


/* 10 Vypište uživatele z Kanady a rozdělte je do 3 skupin podle počtu zobrazení profilu: Skupina 1: zobrazení ≥ 350, Skupina 2: 100 ≤ zobrazení < 350, Skupina 3: zobrazení < 100. 
Zobrazte 
- ID uživatele, 
- počet zobrazení 
- a skupinu. 
Uživatelé se záporným nebo nulovým počtem zobrazení se nepočítají. */

SELECT  id,
        views,
        CASE
            WHEN views >= 350 THEN 1
            WHEN views >= 100 THEN 2
            ELSE 3
        END AS user_group
FROM stackoverflow.users
WHERE location LIKE '%Canada%'
      AND views > 0;

/* 11 Upravený předchozí úkol: zobrazte lídry každé skupiny (uživatele s nejvyšším počtem zobrazení v dané skupině). Zobrazte ID, skupinu a počet zobrazení. Seřaďte podle počtu zobrazení sestupně a ID vzestupně. */

WITH views_canada AS(
                    SELECT  id AS user_id,
                            views AS profile_views,
                            CASE
                            WHEN views >= 350 THEN 1
                            WHEN views >= 100 THEN 2
                            ELSE 3
                            END AS user_group
                    FROM stackoverflow.users
                    WHERE   location LIKE '%Canada%'
                            AND views > 0),      
      leader AS (
                    SELECT *,
                            MAX(profile_views) OVER (PARTITION BY user_group) AS max_views
                    FROM views_canada)
SELECT  user_id,
        user_group,
       profile_views
FROM leader
WHERE profile_views = max_views
ORDER BY profile_views DESC, user_id ASC;


/* 12 Spočítejte denní přírůstek nových uživatelů v listopadu 2008. Tabulka má obsahovat: den v měsíci, počet registrovaných uživatelů a kumulativní součet. */

WITH daily_users AS (
    SELECT  EXTRACT(DAY FROM creation_date::date) AS day_number,
            COUNT(id) AS cnt_new_users
    FROM stackoverflow.users
    WHERE creation_date::date BETWEEN '2008-11-01' AND '2008-11-30'
    GROUP BY EXTRACT(DAY FROM creation_date::date)
)
SELECT  day_number,
        cnt_new_users,
        SUM(cnt_new_users) OVER (ORDER BY day_number) AS cum_sum_users
FROM daily_users
ORDER BY day_number;


/* 13 Pro každého uživatele, který napsal alespoň jeden příspěvek, zjistěte rozdíl mezi datem registrace a vytvořením prvního příspěvku. Zobrazte ID uživatele a časový rozdíl mezi registrací a prvním příspěvkem. */

SELECT u.id AS id,
       MIN(p.creation_date) - u.creation_date AS difference
FROM stackoverflow.users AS u
INNER JOIN  stackoverflow.posts AS p ON u.id = p.user_id
GROUP BY u.id, u.creation_date;

/* 14 Zobrazte celkový součet zhlédnutí u příspěvků publikovaných v jednotlivých měsících roku 2008. Pokud pro nějaký měsíc v databázi nejsou data, můžete ho vynechat. Výsledek seřaďte podle celkového počtu zhlédnutí sestupně. */

SELECT CAST(DATE_TRUNC('month', creation_date) AS date) AS month,
       SUM(views_count) AS sum_views
FROM stackoverflow.posts
WHERE EXTRACT(YEAR FROM creation_date::date) = 2008
GROUP BY CAST(DATE_TRUNC('month', creation_date) AS date)
ORDER BY sum_views DESC;

/* 15 Zobrazte jména těch uživatelů, kteří během prvního měsíce po registraci (včetně dne registrace) dohromady zveřejnili více než 100 odpovědí. Otázky, které tito uživatelé položili, se do počtu nezapočítávají. Pro každé zobrazené jméno uveďte počet unikátních hodnot user_id, které tomuto jménu odpovídají. Výsledek seřaďte podle jmen v lexikografickém (abecedním) pořadí.*/

SELECT u.display_name AS name,
       COUNT(DISTINCT p.user_id) AS cnt_user_id  
FROM stackoverflow.users AS u
JOIN stackoverflow.posts AS p ON u.id = p.user_id
WHERE p.post_type_id = 2
AND p.creation_date::date >= u.creation_date::date
AND p.creation_date::date <= u.creation_date::date + INTERVAL '1 month'
GROUP BY u.display_name
HAVING COUNT(p.id) > 100;

/* 16 Zobrazte počet příspěvků za rok 2008 podle jednotlivých měsíců.
Vyberte pouze příspěvky od uživatelů, kteří se zaregistrovali v září 2008 a v prosinci téhož roku zveřejnili alespoň jeden příspěvek.
Výsledek seřaďte podle měsíce sestupně (od nejnovějšího k nejstaršímu).*/

WITH sep_users AS (
                  SELECT u.id
                  FROM stackoverflow.users AS u
                  JOIN stackoverflow.posts AS p ON u.id = p.user_id
                  WHERE DATE_TRUNC('month', u.creation_date::date) = '2008-09-01'
                  AND DATE_TRUNC('month', p.creation_date::date) = '2008-12-01')
SELECT DATE_TRUNC('month', creation_date)::date AS month,
       COUNT(id) AS cnt_posts
FROM stackoverflow.posts
WHERE user_id IN (SELECT id
                  FROM sep_users)
       AND EXTRACT(YEAR FROM creation_date::date) = 2008
GROUP BY month
ORDER BY month DESC;

/* 17 Použitím dat o příspěvcích zobrazte tato pole:
- ID uživatele, který příspěvek napsal;
- datum vytvoření příspěvku;
- počet zhlédnutí aktuálního příspěvku;
- kumulativní součet zhlédnutí všech příspěvků daného autora (akumulovaně).*/

SELECT user_id,
       creation_date,
       views_count AS current_views,
       SUM(views_count) OVER (PARTITION BY user_id ORDER BY creation_date) AS cum_sum_views
FROM stackoverflow.posts
ORDER BY user_id, creation_date;

/* 18 Kolik dní v průměru uživatelé v období od 1. do 7. prosince 2008 (včetně) interagovali s platformou? Pro každého uživatele zohledněte pouze dny, ve kterých publikoval alespoň jeden příspěvek. Výsledkem má být jedno celé číslo — výsledek zaokrouhlete.*/

WITH cnt_days AS (SELECT DISTINCT user_id,
                         COUNT(DISTINCT DATE_TRUNC('day', creation_date::date)) AS cnt_active_days
        FROM stackoverflow.posts
        WHERE DATE_TRUNC('day', creation_date::date) BETWEEN '2008-12-01' AND '2008-12-07'
        GROUP BY user_id)
        
 SELECT ROUND(AVG(cnt_active_days), 0) 
 FROM cnt_days

/* 19 O kolik procent se měnil měsíční počet příspěvků v období od 1. září do 31. prosince 2008? Vypište tabulku se sloupci:
- číslo měsíce,
- počet příspěvků za daný měsíc,
- procentuální změna počtu příspěvků v aktuálním měsíci oproti předchozímu měsíci.
Pokud je počet příspěvků nižší než v předchozím měsíci, má být procento záporné; pokud vyšší — kladné. Procentuální změnu zaokrouhlete na dvě desetinná místa.*/

WITH total_posts AS (SELECT EXTRACT(MONTH FROM creation_date::date) AS months_number,
                            COUNT(id) AS cnt_posts_per_month
                    FROM stackoverflow.posts
                    WHERE creation_date::date BETWEEN '2008-09-01' AND '2008-12-31'
                    GROUP BY EXTRACT(MONTH FROM creation_date::date))

SELECT *,
       ROUND(((cnt_posts_per_month::numeric / LAG(cnt_posts_per_month) OVER (ORDER BY months_number) - 1) *100), 2) AS percent
FROM total_posts;


/* 20 Najděte uživatele, který od své registrace publikoval celkově nejvíce příspěvků. Pro tohoto uživatele zobrazte jeho aktivitu za říjen 2008 v následující podobě:
- číslo týdne,
- datum a čas posledního příspěvku publikovaného v tom týdnu.*/

WITH top_user AS (
                 SELECT user_id,
                        COUNT (DISTINCT id) AS total_posts
                 FROM stackoverflow.posts
                 GROUP BY user_id
                 ORDER BY COUNT (id) DESC
                 LIMIT 1),
       dates AS (SELECT p.user_id,
                        p.creation_date,
                        EXTRACT(WEEK FROM p.creation_date) AS week
                 FROM stackoverflow.posts AS p
                 JOIN top_user AS tu ON tu.user_id = p.user_id
                 WHERE DATE_TRUNC('month', p.creation_date) = '2008-10-01'
                 )

SELECT DISTINCT
       week,
       MAX(creation_date) OVER (PARTITION BY week) AS last_post_in_week
FROM dates
ORDER BY week;
