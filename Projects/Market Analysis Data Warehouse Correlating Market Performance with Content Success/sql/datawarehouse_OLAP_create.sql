-- Date Dimension
CREATE TABLE dim_date (
    date_key        SERIAL PRIMARY KEY,
    full_date       DATE NOT NULL,
    year            INT,
    quarter         INT,
    month           INT,
    day             INT,
    day_of_week     INT,
    month_name      VARCHAR(20),
    day_name        VARCHAR(20),
    is_weekend      BOOLEAN
);

-- Insert a dummy date record for unknown dates
INSERT INTO dim_date
(date_key, full_date, year, quarter, month, day, day_of_week, month_name, day_name, is_weekend)
VALUES
(1, DATE '1900-01-01', 1900, 1, 1, 1, 1, 'January', 'Monday', false)
ON CONFLICT (date_key) DO NOTHING;

-- Genre Dimension
CREATE TABLE dim_genre (
    genre_key   SERIAL PRIMARY KEY,
    genre_id    INT,
    genre_name  VARCHAR(20) UNIQUE NOT NULL
);

-- Region Dimension
CREATE TABLE dim_region (
    region_key   SERIAL PRIMARY KEY,
    region_id    INT,
    region_name  VARCHAR(60) UNIQUE NOT NULL
);

-- Language Dimension
CREATE TABLE dim_language (
    language_key   SERIAL PRIMARY KEY,
    language_id    INT,
    language_name  VARCHAR(20) UNIQUE NOT NULL
);

-- Parent Company Dimension (SCD TYPE 2)
CREATE TABLE dim_parentcompany (
    parent_key           SERIAL PRIMARY KEY,
    parent_id            INT,
    parent_name          VARCHAR(50) NOT NULL,
    ticker               VARCHAR(5),
    effective_start_date DATE NOT NULL,
    effective_end_date   DATE NOT NULL DEFAULT '9999-12-31',
    current_flag         CHAR(1) NOT NULL DEFAULT 'Y'
);

-- Production Company Dimension (SCD TYPE 2)
CREATE TABLE dim_productioncompany (
    company_key           SERIAL PRIMARY KEY,
    company_id            INT,
    company_name          TEXT NOT NULL,
    parent_key            INT REFERENCES dim_parentcompany(parent_key),
    effective_start_date  DATE NOT NULL,
    effective_end_date    DATE NOT NULL DEFAULT '9999-12-31',
    current_flag          CHAR(1) NOT NULL DEFAULT 'Y'
);

-- Movie Fact Table
CREATE TABLE fact_movie (
    imdb_id          VARCHAR(20) PRIMARY KEY,     -- Natural key
    titleType        VARCHAR(10),
    primaryTitle     TEXT,
    originalTitle    TEXT,
    isAdult          BOOLEAN,
    releaseYear      INT,
    runtimeMinutes   INT,
    averageRating    NUMERIC(3,1),
    numVotes         INT,
    date_key         INT REFERENCES dim_date(date_key)
);

-- BRIDGE TABLES (M:N LINKS)

CREATE TABLE bridge_moviegenre (
    imdb_id    VARCHAR(20) REFERENCES fact_movie(imdb_id) ON DELETE CASCADE,
    genre_key  INT REFERENCES dim_genre(genre_key),
    genre_id   INT,
    PRIMARY KEY (imdb_id, genre_key)
);

CREATE TABLE bridge_movieregion (
    imdb_id    VARCHAR(20) REFERENCES fact_movie(imdb_id) ON DELETE CASCADE,
    region_key INT REFERENCES dim_region(region_key),
    region_id  INT,
    PRIMARY KEY (imdb_id, region_key)
);

CREATE TABLE bridge_movielanguage (
    imdb_id      VARCHAR(20) REFERENCES fact_movie(imdb_id) ON DELETE CASCADE,
    language_key INT REFERENCES dim_language(language_key),
    language_id  INT,
    PRIMARY KEY (imdb_id, language_key)
);

CREATE TABLE bridge_movieproduction (
    imdb_id      VARCHAR(20) REFERENCES fact_movie(imdb_id) ON DELETE CASCADE,
    company_key INT REFERENCES dim_productioncompany(company_key),
    company_id  INT,
    PRIMARY KEY (imdb_id, company_key)
);

CREATE TABLE dim_stock (
    stock_key SERIAL PRIMARY KEY,
    open DECIMAL(10,2),
    close DECIMAL(10,2),
    high DECIMAL(10,2),
    low DECIMAL(10,2),
    volume BIGINT,
    date_key INT,
    parent_key INT,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key) ON DELETE CASCADE,
    FOREIGN KEY (parent_key) REFERENCES dim_parentcompany(parent_key) ON DELETE CASCADE
);