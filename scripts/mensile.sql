--Analisi rischio e rendimento mensile--

WITH rendimento_medio_effettivo AS (
SELECT *, 
LAG(CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date) AS prev_close,
ROUND(
(CAST(s.close AS REAL) - LAG(CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date)) * 1.0 / LAG (CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date), 4) 
AS rendimento_medio_effettivo,
strftime('%Y-%m', date) AS mese
FROM stocks s
WHERE "Adj Close" <> '' OR close <> '' OR high <> '' OR low <> '' OR open <> '' OR volume <> ''
),
volatilita_effettiva AS (
SELECT mese, symbol, CAST(rendimento_medio_effettivo AS REAL) AS rendimento_medio_effettivo, 
POWER(AVG(CAST(rendimento_medio_effettivo AS REAL)) OVER (PARTITION BY symbol, mese) - CAST(rendimento_medio_effettivo AS REAL),2) AS diff2 
FROM rendimento_medio_effettivo
),
volatilita_mensile AS(
SELECT mese, symbol,
SQRT(AVG(diff2) OVER (PARTITION BY symbol, mese)) AS volatilita_mensile, --dev.standard--
AVG(CAST(rendimento_medio_effettivo AS REAL)) OVER (PARTITION BY symbol, mese) AS rendimento_medio_mensile
FROM volatilita_effettiva
)
SELECT mese, symbol, volatilita_mensile, rendimento_medio_mensile, 
CASE
	WHEN rendimento_medio_mensile > 0 THEN 'profitto'
	WHEN rendimento_medio_mensile < 0 THEN 'perdita'
	ELSE 'nessun valore'
END AS profitto_or_not
FROM volatilita_mensile
GROUP BY symbol,mese;

--quali aziende hanno il rendiemnto più alto? fai grafico per settore--
WITH rendimento_medio_effettivo AS (
SELECT *, 
LAG(CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date) AS prev_close,
ROUND(
(CAST(s.close AS REAL) - LAG(CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date)) * 1.0 / LAG (CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date), 4) 
AS rendimento_medio_effettivo,
strftime('%Y-%m', date) AS mese
FROM stocks s
WHERE "Adj Close" <> '' OR close <> '' OR high <> '' OR low <> '' OR open <> '' OR volume <> ''
),
volatilita_effettiva AS (
SELECT mese, symbol, CAST(rendimento_medio_effettivo AS REAL) AS rendimento_medio_effettivo, 
POWER(AVG(CAST(rendimento_medio_effettivo AS REAL)) OVER (PARTITION BY symbol, mese) - CAST(rendimento_medio_effettivo AS REAL),2) AS diff2
FROM rendimento_medio_effettivo
),
volatilita_mensile AS(
SELECT mese, symbol,
SQRT(AVG(diff2) OVER (PARTITION BY symbol, mese)) AS volatilita_mensile, --de.standard--
AVG(CAST(rendimento_medio_effettivo AS REAL)) OVER (PARTITION BY symbol, mese) AS rendimento_medio_mensile
FROM volatilita_effettiva
),
union_tabelle AS (
SELECT *
FROM volatilita_mensile
JOIN companies ON volatilita_mensile.symbol = companies.symbol
GROUP BY volatilita_mensile.symbol,mese
)
SELECT mese, symbol, volatilita_mensile, rendimento_medio_mensile, sector
FROM union_tabelle 
ORDER BY rendimento_medio_mensile DESC
LIMIT 3;

--ci sono settori che hanno rendimenti (mensili) costantemente superiori alla media dell'indice?--
WITH rendimento_medio_effettivo AS (
SELECT *, 
LAG(CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date) AS prev_close,
(CAST(s.close AS REAL) - LAG(CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date)) * 1.0 / LAG (CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date)
AS rendimento_medio_effettivo,
strftime('%Y-%m', date) AS mese
FROM stocks s
WHERE "Adj Close" <> '' OR close <> '' OR high <> '' OR low <> '' OR open <> '' OR volume <> ''
),
sp AS(
SELECT mese, symbol, 
AVG(rendimento_medio_effettivo) OVER (PARTITION BY symbol, mese) AS rendimento_medio_mensile, 
AVG(rendimento_medio_effettivo) OVER (PARTITION BY mese) AS rendimento_medio_globale
FROM rendimento_medio_effettivo 
),
union_tabelle AS (
SELECT *
FROM sp 
JOIN companies ON sp.symbol = companies.symbol
),
posizione AS (
SELECT mese,symbol,rendimento_medio_mensile,rendimento_medio_globale, sector, shortname, 
CASE 
	WHEN rendimento_medio_mensile < rendimento_medio_globale THEN 'underperforming'
	WHEN rendimento_medio_mensile > rendimento_medio_globale THEN 'overperforming'
	WHEN rendimento_medio_mensile = rendimento_medio_globale THEN 'coerente'
	ELSE 'nulla'
END AS posizione_rendimento_azienda
FROM union_tabelle 
)
SELECT sector, COUNT(DISTINCT mese) AS mesi_overperformanti ,
ROUND((COUNT(DISTINCT mese) * 1.0 / (SELECT COUNT(DISTINCT mese) FROM posizione))*100, 2) AS percentuale_mesi, posizione_rendimento_azienda
FROM posizione 
WHERE posizione_rendimento_azienda = 'overperforming'
GROUP BY sector