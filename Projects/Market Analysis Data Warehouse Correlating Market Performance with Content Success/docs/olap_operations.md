# OLAP Operations

Nine analytical operations defined over the Disney data warehouse (`disney_movies_dw`), written in shorthand OLAP notation. `fact_movie` is the central fact table; `dim_stock` holds daily stock measures.

| # | Operation | Description | Shorthand notation |
| --- | --- | --- | --- |
| 1 | Aggregate | Average rating by genre | `AVG(fact_movie, averagerating) BY dim_genre → genre_name` |
| 2 | Slice | Ratings by movie in a specific genre | `SLICE(fact_movie, dim_genre.genre_name = 'Action')` |
| 3 | Slice | Ratings from movies released in a specific year | `SLICE(fact_movie, dim_date.Year = 2022)` |
| 4 | Rollup | Sum of trading volume by month | `ROLLUP(dim_stock, dim_date → Month, SUM(volume))` |
| 5 | Cube | Sum of trading volume across the time dimension | `CUBE(dim_stock, [dim_date → (Year, Quarter, Month, Day)], SUM(volume))` |
| 6 | Moving average | Moving average of opening price | `MOVING_AVG(dim_stock, open) BY dim_date → Day` |
| 7 | Rank | Rank companies by total trading volume | `RANK(dim_stock, SUM(volume)) BY dim_parentcompany → parent_name` |
| 8 | Drill-down | Trading volume by date hierarchy | `DRILLDOWN(dim_stock, [dim_date → (Year → Month → Day)], SUM(volume))` |
| 9 | Dice | Average rating by genre and release year | `AVG(fact_movie, averagerating) BY dim_genre → genre_name, dim_date → Year` |
