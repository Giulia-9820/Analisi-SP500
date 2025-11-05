# Analisi dell'indice S&P 500 (2014 - 2024)

Questo progetto ha l'obiettivo di analizzare la composizione, il rischio, la performance e la struttura settoriale dell'indice **S&P 500**, principale benchmark del mercato azionario statunitense.

L’analisi è stata condotta utilizzando dati provenienti da **FRED** e **Yahoo Finance**, nel periodo **dicembre 2014 – dicembre 2024**, aggregati sia su base **intraday** che **mensile**.

---

## Obiettivi del progetto

- Analizzare la **composizione settoriale** dell'indice
- Valutare il **rischio** e il **rendimento** delle singole aziende e dei settori
- Identificare i titoli e settori **dominanti** per capitalizzazione e influenza
- Esaminare la **correlazione** tra settori al fine di ottimizzare la **diversificazione di portafoglio**

---

## Struttura del progetto

| Cartella/Sezione | Descrizione |
|------------------|-------------|
| `/scripts`       | Codice SQL utilizzato per processamento |
| `/metriche`      | Documentazione dettagliata sulle tre analisi principali |
| `Report SP500.docx` | Report completo dell’analisi |

---

## Metriche analizzate

| Metrica | Obiettivo | File documentazione |
|--------|-----------|--------------------|
| **Analisi Intraday** | Identificare aziende con più alta performance e rischio nel brevissimo periodo | `metriche/intraday.md` |
| **Analisi Mensile** | Misurare volatilità e rendimento su orizzonte di lungo periodo | `metriche/mensile.md` |
| **Correlazione Settoriale** | Individuare settori più o meno diversificanti | `metriche/correlazioni.md` |

---

## Tecnologie e strumenti

- **SQL** per estrazione e struttura dati
- **Google Sheet** per visualizzazioni
- **Yahoo Finance API / FRED API**
- Indice di **Correlazione di Pearson**

---

## Autore

**Giulia Garraffo**  
Financial Data Analyst  
LinkedIn: *https://www.linkedin.com/in/giulia-garraffo-a7231a1a8/*

---
