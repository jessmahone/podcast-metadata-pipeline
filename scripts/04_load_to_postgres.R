# 04_load_to_postgres.R

# Load packages.
library(RPostgres)
library(DBI)

# Connect to podcast_pipeline database.
con <- dbConnect(
  RPostgres::Postgres(),
  dbname   = "podcast_pipeline",
  host     = "localhost",
  port     = 5432,
  user     = Sys.getenv("USER")
)

# Read in raw CSV
feeds_raw <- read.csv("data/trending_feeds_raw.csv", stringsAsFactors = FALSE)

# Write to raw schema in Postgres
dbWriteTable(
  conn      = con,
  name      = Id(schema = "raw", table = "trending_feeds"),
  value     = feeds_raw,
  append    = TRUE,
  overwrite = FALSE
)

# Check data in Postgres
dbGetQuery(con, "SELECT COUNT(*) FROM raw.trending_feeds;")