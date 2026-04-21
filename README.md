# Podcast Metadata Pipeline
An end-to-end analytics engineering pipeline that transforms raw podcast metadata from the Podcast Index API into structured analytical datasets for two business consumers: content strategy and market opportunity analysis.

## Overview
This project demonstrates a full analytics engineering workflow — API extraction, data loading, and dbt modeling — built on the open Podcast Index dataset. It is designed to answer business-relevant questions about the podcast landscape across 19 top-level categories.

**Content Strategy:** Which podcasts are consistent, mature, and brand-safe? This mart supports teams evaluating podcasts for acquisition, advertising, or partnership decisions.

**Market Opportunity:** Where is the podcast market crowded, and where are the gaps? This mart supports teams analyzing category saturation, language distribution, and publisher dominance.

## Status
Extraction layer complete. dbt staging and mart models in progress.

## Pipeline Architecture
1. **Extract:** R scripts query the Podcast Index API for trending podcasts across 19 categories, then enrich each result with full feed metadata
2. **Load:** Raw data lands in PostgreSQL
3. **Transform:** dbt staging models clean and deduplicate; mart models organize outputs by business consumer

## Tech Stack
- **Extraction:** R (`httr2`, `digest`)
- **Storage:** PostgreSQL
- **Transformation:** dbt
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
