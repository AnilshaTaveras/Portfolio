# Market Analysis Data Warehouse: Correlating Market Performance with Content Success

An end-to-end PostgreSQL data warehouse that combines film data (IMDb, TMDB) with historical stock prices (Alpaca Markets) to explore whether the success of Disney's content lines up with its market activity (ticker: DIS).

*Group project for the M.S. in Data Analytics Engineering at Northeastern University (Aug 2025 – Dec 2025).*

## Team & Contributions

| Person | Contribution |
| --- | --- |
| **Anilsha Taveras** | Database design (OLTP and OLAP schemas), data sourcing and integration (IMDb, TMDB API, Alpaca Markets), Talend ETL pipelines, SQL implementation, and the OLAP operations |
| **Deepikashini Balamurali** | Final report and Tableau KPI dashboards (shared with Gabriel Santini) |
| **Gabriel Santini** | Final report and Tableau KPI dashboards (shared with Deepikashini Balamurali) |

This repository contains the parts I built. The final written report and the Tableau dashboard visuals were completed by my teammates and are not reproduced here.

## The Question

Does a company's media success relate to its stock performance? This project builds the data infrastructure to ask that question, focusing on The Walt Disney Company and subsidiaries such as Pixar, Marvel Studios, Lucasfilm, and 20th Century Studios.

## What I Built

**1. Data integration**
- Film titles and ratings from the IMDb non-commercial datasets (ratings as of Sept 22, 2025)
- Disney-related titles and release dates identified through the TMDB API by querying Disney production companies
- Monthly-to-daily stock price history (open, high, low, close, volume) pulled from the Alpaca Markets API with a Python script, covering 1990–2025

**2. OLTP database (PostgreSQL, `disney_movies_db`)**
- Normalized relational schema: `Movie`, `Genre`, `Language`, `Region`, `Rating`, `ProductionCompany`, `ParentCompany`, `Stock`
- Bridge tables for many-to-many relationships (`MovieGenre`, `MovieLanguage`, `MovieRegion`, `MovieProduction`)

**3. OLAP data warehouse (PostgreSQL, `disney_movies_dw`)**
- Snowflake-schema model with `fact_movie` as the central fact table; ratings were folded into the fact table
- Surrogate keys, plus effective start/end dates and a current-record flag on production company and parent company dimensions, to track subsidiaries over time (slowly changing dimension handling)
- Date dimension covering about 20,000 days, generated in Talend

**4. ETL (Talend)**

The full Talend project export is in `/etl` (credentials and local paths removed), with two job folders:

*`Disney_DB`: OLTP load*
- Jobs that read the prepared IMDb/TMDB CSV and the Disney stock CSV and load `disney_movies_db`: movies and ratings, genres and the movie-genre bridge, regions and languages with their bridges, production and parent companies with the movie-production bridge, and stock prices
- A master job (`Load_DB_Jobs`) that runs the loads in order

*`Disney_DW`: OLAP load*
- A master job (`Load_DW_Jobs`) that triggers the jobs in sequence: date, genre, language, region, parent company, and production company dimensions, then the movie fact table, the genre, language, region, and production bridge tables, and the stock dimension
- The date dimension is generated in Talend with a `tRowGenerator` component
- `tMap` transformations and lookups to resolve surrogate keys
- Insert-or-update loading, so the pipeline can be rerun without truncating tables

**5. OLAP operations**
Nine analytical operations specified over the warehouse in shorthand OLAP notation (see `/docs/olap_operations.md`):
- Average rating by genre, and by genre and release year
- Slice by genre (for example Action) and by release year (for example 2022)
- Rollup of trading volume by month
- Cube of trading volume across year, quarter, month, and day
- Moving average of opening price
- Ranking of companies by trading volume
- Drill-down of trading volume from year to month to day

## Scale

| Item | Count |
| --- | --- |
| Movies in `fact_movie` | 922 |
| Daily stock records | 9,011 |
| Production companies | 58 |
| Genres | 22 |

## What the Analysis Showed

These observations came from the team's Tableau dashboards, which were built on the OLAP operations above:

- Documentary and Biography were among the highest-rated genres on average.
- Some genres moved noticeably from year to year.
- Stock trading volume spikes often coincided with strong content release periods.

## Limitations

- These are observations, not tested relationships. The project does not show that movie releases cause stock movement, and a statistical test of the volume and release link was not performed.
- Stock data is tied to the parent company, so individual movies cannot be isolated from other news that affects the stock.
- IMDb ratings are a snapshot from Sept 22, 2025.

## Tech Stack

PostgreSQL 18, pgAdmin, Talend (ETL), SQL, Python (data collection), Tableau (team dashboards), IMDb datasets, TMDB API, Alpaca Markets API

## Repository Contents

```
/etl        Talend project export: OLTP and OLAP load jobs (credentials removed)
/sql        OLAP create statements
/docs       OLAP operations in shorthand notation
/diagrams   ER, relational, and OLAP schema diagrams
README.md
```

Raw IMDb data files, database passwords, and API keys are not included.

## Data Attribution

Information courtesy of IMDb (https://www.imdb.com). Used with permission. IMDb non-commercial datasets: https://datasets.imdbws.com/

This product uses the TMDB API but is not endorsed or certified by TMDB. https://developer.themoviedb.org/
