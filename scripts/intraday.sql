--Analisi rischio e rendimento intraday--

WITH rendimento_intraday AS (
    SELECT 
        date,
        symbol,
        CAST(open AS REAL) AS open,
        CAST(close AS REAL) AS close,
        CAST(volume AS REAL) AS volume,
        CAST(high AS REAL) AS high,
        CAST(low AS REAL) AS low,
        ROUND(((CAST(close AS REAL) - CAST(open AS REAL)) * 1.0 / CAST(open AS REAL)), 4) AS rendimento_intraday,
        CASE 
            WHEN ROUND(((CAST(close AS REAL) - CAST(open AS REAL)) * 1.0 / CAST(open AS REAL)),4) < 0 THEN 'perdita intraday'
            WHEN ROUND(((CAST(close AS REAL) - CAST(open AS REAL)) * 1.0 / CAST(open AS REAL)),4) IS NULL THEN 'nessun valore intraday'
            ELSE 'profitto intraday'
        END AS profitto_or_not_intraday 
    FROM stocks s 
WHERE "Adj Close" <> '' OR close <> '' OR high <> '' OR low <> '' OR open <> '' OR volume <> ''
),
volatilita_intraday_parte1 AS(
SELECT date, symbol, CAST(rendimento_intraday AS REAL) AS rendimento_intraday, profitto_or_not_intraday,
POWER(AVG(CAST(rendimento_intraday AS REAL)) OVER (PARTITION BY symbol) - CAST(rendimento_intraday AS REAL), 2) AS diff2_intraday
FROM rendimento_intraday 
),
volatilita_intraday_finale AS(
SELECT date, symbol,
SQRT(AVG(diff2_intraday)  OVER (PARTITION BY symbol, date)) AS volatilita_intraday, --DEV.STANDARD-- 
rendimento_intraday ,profitto_or_not_intraday
FROM volatilita_intraday_parte1 
)
SELECT * FROM volatilita_intraday_finale 

--rendimento piu alto e volatilita piu alta--
WITH rendimento_intraday AS (
    SELECT 
        date,
        symbol,
        CAST(open AS REAL) AS open,
        CAST(close AS REAL) AS close,
        CAST(volume AS REAL) AS volume,
        CAST(high AS REAL) AS high,
        CAST(low AS REAL) AS low,
        ROUND(((CAST(close AS REAL) - CAST(open AS REAL)) * 1.0 / CAST(open AS REAL)), 4) AS rendimento_intraday,
        CASE 
            WHEN ROUND(((CAST(close AS REAL) - CAST(open AS REAL)) * 1.0 / CAST(open AS REAL)),4) < 0 THEN 'perdita intraday'
            WHEN ROUND(((CAST(close AS REAL) - CAST(open AS REAL)) * 1.0 / CAST(open AS REAL)),4) IS NULL THEN 'nessun valore intraday'
            ELSE 'profitto intraday'
        END AS profitto_or_not_intraday 
    FROM stocks s 
WHERE "Adj Close" <> '' OR close <> '' OR high <> '' OR low <> '' OR open <> '' OR volume <> ''
),
volatilita_intraday_parte1 AS(
SELECT date, symbol, CAST(rendimento_intraday AS REAL) AS rendimento_intraday, profitto_or_not_intraday,
POWER(AVG(CAST(rendimento_intraday AS REAL)) OVER (PARTITION BY symbol) - CAST(rendimento_intraday AS REAL), 2) AS diff2_intraday
FROM rendimento_intraday 
),
volatilita_intraday_finale AS(
SELECT date, symbol,
SQRT(AVG(diff2_intraday)  OVER (PARTITION BY symbol, date)) AS volatilita_intraday, --DEV.STANDARD-- 
rendimento_intraday ,profitto_or_not_intraday
FROM volatilita_intraday_parte1 
),
union_tabelle AS (
SELECT *
FROM volatilita_intraday_finale 
JOIN companies ON volatilita_intraday_finale.symbol = companies.symbol
)
SELECT date, symbol, volatilita_intraday, rendimento_intraday, sector
FROM union_tabelle
ORDER BY rendimento_intraday DESC
LIMIT 3;