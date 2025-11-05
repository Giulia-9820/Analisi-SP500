--Analisi Esplorativa--

SELECT * FROM companies c 


SELECT COUNT(shortname) as num_company FROM companies c 

SELECT shortname, sector, country , COUNT (shortname) AS numero_aziende 
FROM companies 
GROUP BY shortname
HAVING numero_aziende  >= 2;
ORDER BY numero_aziende DESC;

SELECT * 
FROM companies c 
WHERE shortname IN ('Alphabet Inc.', 'Fox Corporation', 'News Corporation')
ORDER BY shortname ASC;

--Analisi per settore--

SELECT sector, COUNT (sector) AS num_settori
FROM companies c 
GROUP BY sector


SELECT * FROM companies c 
WHERE 
    exchange IS NULL OR exchange = '' OR
    symbol IS NULL OR symbol = '' OR
    shortname IS NULL OR shortname = '' OR
    longname IS NULL OR longname = '' OR
    sector IS NULL OR sector = '' OR
    industry IS NULL OR industry = '' OR
    currentprice IS NULL OR currentprice = '' OR
    marketcap IS NULL OR marketcap = '' OR
    ebitda IS NULL OR ebitda = '' OR
    Revenuegrowth  IS NULL OR Revenuegrowth  = '' OR
	city  IS NULL OR city  = '' OR
	state IS NULL OR state = '' OR
	country IS NULL OR country = '' OR 
	Fulltimeemployees IS NULL OR Fulltimeemployees = '';

SELECT *
FROM companies c 
WHERE 
    Currentprice  < 0 OR    
    Fulltimeemployees < 0;

SELECT sector, count (symbol) AS num_aziende
FROM companies c 
GROUP BY c.Sector 

--ANALISI PER CAPITALIZZAZIONE--

SELECT sector, Marketcap 
FROM companies 
WHERE sector = "Basic Materials";

SELECT sector, AVG(c.Marketcap ) AS capitalizzazione_media, AVG(c.Currentprice ) AS prezzo_medio
FROM companies c 
GROUP BY sector
ORDER BY capitalizzazione_media desc;

SELECT sector, symbol, shortname, MAX(c.Marketcap) AS maggiore_capitalizzazione
FROM companies c 
GROUP BY sector
ORDER BY maggiore_capitalizzazione DESC;
