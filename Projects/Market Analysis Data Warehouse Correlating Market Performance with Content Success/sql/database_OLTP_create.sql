-- Drop the database if it already exists
DROP DATABASE IF EXISTS disney_movies_db;

-- Create a fresh database
CREATE DATABASE disney_movies_db;

-- Connect to it (for psql or pgAdmin)
\c disney_movies_db;

-- TABLE DROPS (to safely re-run this script)
DROP TABLE IF EXISTS MovieLanguage CASCADE;
DROP TABLE IF EXISTS MovieRegion CASCADE;
DROP TABLE IF EXISTS MovieGenre CASCADE;
DROP TABLE IF EXISTS MovieProduction CASCADE;
DROP TABLE IF EXISTS Rating CASCADE;
DROP TABLE IF EXISTS Genre CASCADE;
DROP TABLE IF EXISTS Language CASCADE;
DROP TABLE IF EXISTS Region CASCADE;
DROP TABLE IF EXISTS ProductionCompany CASCADE;
DROP TABLE IF EXISTS ParentCompany CASCADE;
DROP TABLE IF EXISTS Stock CASCADE;
DROP TABLE IF EXISTS Movie CASCADE;

-- Movie Entity

CREATE TABLE Movie (
    imdb_id VARCHAR(20) PRIMARY KEY,
    titleType VARCHAR(10),
    primaryTitle TEXT NOT NULL,
    originalTitle TEXT,
    isAdult BOOLEAN,
    releaseYear INT,
    runtimeMinutes INT,
    release_date DATE
);

-- Dimension Tables

CREATE TABLE Genre (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Region (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(60) NOT NULL
);

CREATE TABLE Language (
    language_id SERIAL PRIMARY KEY,
    language_name VARCHAR(20) NOT NULL
);

CREATE TABLE Rating (
    imdb_id VARCHAR(20) PRIMARY KEY, 
    averageRating NUMERIC(3,1),
    numVotes INT,
    FOREIGN KEY (imdb_id) REFERENCES Movie(imdb_id) ON DELETE CASCADE
);

CREATE TABLE ParentCompany (
    parent_id SERIAL PRIMARY KEY,
    parent_name VARCHAR(50) NOT NULL,
    ticker VARCHAR(5)
);

CREATE TABLE ProductionCompany (
    company_id SERIAL PRIMARY KEY,
    company_name TEXT UNIQUE NOT NULL,
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES ParentCompany(parent_id) ON DELETE SET NULL
);

-- Bridge tables

CREATE TABLE MovieGenre (
    imdb_id VARCHAR(20) NOT NULL,
    genre_id INT NOT NULL, 
    PRIMARY KEY (imdb_id, genre_id),
    FOREIGN KEY (imdb_id) REFERENCES Movie(imdb_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id) ON DELETE CASCADE
);

CREATE TABLE MovieRegion (
    imdb_id VARCHAR(20) NOT NULL,
    region_id INT NOT NULL,
    PRIMARY KEY (imdb_id, region_id),
    FOREIGN KEY (imdb_id) REFERENCES Movie(imdb_id) ON DELETE CASCADE,
    FOREIGN KEY (region_id) REFERENCES Region(region_id) ON DELETE CASCADE,
);

CREATE TABLE MovieLanguage (
    imdb_id VARCHAR(20) NOT NULL,
    language_id INT NOT NULL,
    PRIMARY KEY (imdb_id, language_id),
    FOREIGN KEY (imdb_id) REFERENCES Movie(imdb_id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES Language(language_id) ON DELETE CASCADE
);

CREATE TABLE MovieProduction (
    imdb_id VARCHAR(20), 
    company_id INT,
    PRIMARY KEY (imdb_id, company_id),
    FOREIGN KEY (imdb_id) REFERENCES Movie(imdb_id) ON DELETE CASCADE,
    FOREIGN KEY(company_id) REFERENCES ProductionCompany(company_id) ON DELETE CASCADE
);

-- Stock Price (DIS)

CREATE TABLE Stock (
    stock_date TIMESTAMPTZ PRIMARY KEY,
    open DECIMAL(10,2),
    close DECIMAL(10,2),
    high DECIMAL(10,2),
    low DECIMAL(10,2),
    volume BIGINT,
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES ParentCompany(parent_id) ON DELETE CASCADE
);