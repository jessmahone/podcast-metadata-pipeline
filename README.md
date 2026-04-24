# Podcast Metadata Pipeline
An end-to-end analytics engineering pipeline that transforms raw podcast metadata 
from the Podcast Index API into structured analytical datasets for two business 
consumers: content strategy and market opportunity analysis.

## Overview
This project demonstrates a full analytics engineering workflow — API extraction, 
data loading, and dbt modeling — built on the open Podcast Index dataset. It is 
designed to answer business-relevant questions about the podcast landscape across 
19 top-level categories.

**Content Strategy:** Which podcasts are consistent, mature, and brand-safe? This 
mart supports teams evaluating podcasts for acquisition, advertising, or partnership 
decisions.

**Market Opportunity:** Where is the podcast market crowded, and where are the gaps? 
This mart supports teams analyzing category saturation, language distribution, and 
publisher dominance.

## Status
- ✅ Extraction complete — 4,750 rows across 19 categories loaded into PostgreSQL
- ✅ Staging models complete — `stg_podcasts` and `stg_podcast_categories`
- 🔄 Mart models in progress — `mart_market_opportunity` and `mart_content_strategy`

## Pipeline Architecture
1. **Extract:** R scripts query the Podcast Index API for trending podcasts across 
19 categories, then enrich each result with full feed metadata
2. **Load:** Raw data lands in the `raw` schema in PostgreSQL
3. **Stage:** dbt staging models clean, deduplicate, and type-cast raw data into 
two models:
   - `stg_podcasts` — one row per unique podcast (3,404 records), with normalized 
   language codes and parsed publish dates
   - `stg_podcast_categories` — one row per podcast-category relationship, 
   preserving the many-to-many structure
4. **Mart:** dbt mart models (in progress) organize outputs by business consumer

## Data Modeling Decisions
**Deduplication:** Raw data contains expected duplicates — podcasts appearing in 
multiple queried categories. Staging separates podcast attributes (`stg_podcasts`) 
from category relationships (`stg_podcast_categories`), deduplicating to 3,404 
unique podcasts from 4,750 raw rows.

**Language normalization:** Raw language codes included regional variants (`en-us`, 
`en-gb`, `en-US`). Staging normalizes to base language codes (`en`) for consistent 
aggregation downstream.

**Timestamp handling:** Raw `newest_item_publish_time` (Unix timestamp) is cast to 
date in staging. Time-of-day precision is not meaningful for this analysis.

## Tech Stack
- **Extraction:** R (`httr2`, `digest`)
- **Storage:** PostgreSQL
- **Transformation:** dbt Core
- **Data Source:** Podcast Index API
- **Version Control:** GitHub

## Data Coverage
- 19 top-level categories (Apple Podcasts taxonomy)
- Up to 250 trending podcasts per category
- Enriched with full feed metadata via `podcasts/byfeedid` endpoint

## License
Shield: [![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa]

This work is licensed under a
[Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa].

[![CC BY-SA 4.0][cc-by-sa-image]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-image]: https://licensebuttons.net/l/by-sa/4.0/88x31.png
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg