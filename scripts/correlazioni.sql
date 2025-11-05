--ANALISI CORRELAZIONE TRA SETTORI--

WITH rendimento_medio_effettivo AS (
    SELECT *, 
           LAG(CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date) AS prev_close,
           ROUND(
               (CAST(s.close AS REAL) - LAG(CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date)) * 1.0
               / LAG(CAST(s.close AS REAL)) OVER (PARTITION BY s.symbol ORDER BY date), 4
           ) AS rendimento_medio_effettivo,
           strftime('%Y-%m', date) AS mese
    FROM stocks s
    JOIN companies c ON s.Symbol = c.Symbol 
    WHERE "Adj Close" <> '' OR close <> '' OR high <> '' OR low <> '' OR open <> '' OR volume <> ''
),
rend_medio_mensile AS (
    SELECT mese, Symbol, sector, rendimento_medio_effettivo,
           AVG(CAST(rendimento_medio_effettivo AS REAL)) OVER (PARTITION BY symbol, mese) AS rendimento_medio_mensile
    FROM rendimento_medio_effettivo 
    WHERE rendimento_medio_effettivo IS NOT NULL
    GROUP BY mese, Symbol, sector
),
rend_settore_mensile AS (
    SELECT mese, sector, rendimento_medio_mensile,
           AVG(rendimento_medio_mensile) AS rendimento_settore
    FROM rend_medio_mensile
    GROUP BY mese, sector
),
coppie AS (
    SELECT 
        a.mese,
        a.sector AS sector1,
        b.sector AS sector2,
        a.rendimento_settore AS rms1,
        b.rendimento_settore AS rms2
    FROM rend_settore_mensile a
    JOIN rend_settore_mensile b 
         ON a.mese = b.mese
        AND a.sector < b.sector  
),
stats AS (
    SELECT *,
           AVG(rms1) OVER (PARTITION BY sector1, sector2) AS mean_rms1,
           AVG(rms2) OVER (PARTITION BY sector1, sector2) AS mean_rms2
    FROM coppie
),
cov_calc AS (
    SELECT sector1, sector2,
           SUM((rms1 - mean_rms1) * (rms2 - mean_rms2)) AS cov,
           SUM(POWER(rms1 - mean_rms1, 2)) AS var1,
           SUM(POWER(rms2 - mean_rms2, 2)) AS var2
    FROM stats
    GROUP BY sector1, sector2
)
SELECT sector1, sector2,
       cov / (SQRT(var1) * SQRT(var2)) AS indice_pearson
FROM cov_calc
ORDER BY indice_pearson DESC;
