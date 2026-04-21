# 03_podcast_index_api.R
# Purpose: Authenticate and make calls to the Podcast Index API to collect data from recent/trending
# Dependencies: httr2, digest

library(httr2)
library(digest)

# Load credentials from .Renviron
api_key <- Sys.getenv("PODCAST_INDEX_KEY")
api_secret <- Sys.getenv("PODCAST_INDEX_SECRET")

# Build authentication headers.
# Podcast Index uses a time-based hash rather than a simple bearer token
unix_time <- as.integer(Sys.time())

# Concatenate key + secret + timestamp, then hash with SHA-1
auth_hash <- digest(
  paste0(api_key, api_secret, unix_time),
  algo = "sha1",
  serialize = FALSE
)

# Set categories
categories <- c(
  "Arts",
  "Business",
  "Comedy",
  "Education",
  "Fiction",
  "Government",
  "History",
  "Health",
  "Kids",
  "Leisure",
  "Music",
  "News",
  "Religion",
  "Science",
  "Society",
  "Sports",
  "Technology",
  "True Crime",
  "TV"
)

# Create an empty list to collect results from all categories
all_feeds <- list()

for (cat in categories) {
  unix_time <- as.integer(Sys.time())
  auth_hash <- digest(
    paste0(api_key, api_secret, unix_time),
    algo = "sha1",
    serialize = FALSE
  )
  
  response <- request("https://api.podcastindex.org/api/1.0/podcasts/trending") |>
    req_url_query(max = 250, cat = cat) |>
    req_headers(
      "X-Auth-Key" = api_key,
      "X-Auth-Date" = as.character(unix_time),
      "Authorization" = auth_hash,
      "User-Agent" = "PodcastPortfolioProject/1.0"
    ) |>
    req_perform()
  
  parsed <- response |> resp_body_json()
  
  # Add a field to each feed recording which category we queried
  # This is important because a podcast can appear in multiple categories
  feeds_with_cat <- lapply(parsed$feeds, function(feed) {
    feed$queried_category <- cat
    feed
  })
  
  # Append this category's results to the master list
  all_feeds <- c(all_feeds, feeds_with_cat)
  
  # Log progress so you know what's happening
  cat("Fetched", length(parsed$feeds), "feeds for category:", cat, "\n")
  
  Sys.sleep(1)
}

# Convert each feed to a flat data frame row, handling the nested categories field
feeds_df <- do.call(rbind, lapply(all_feeds, function(feed) {
  data.frame(
    id                    = feed$id,
    title                 = feed$title,
    url                   = feed$url,
    description           = feed$description,
    author                = feed$author,
    language              = feed$language,
    itunes_id             = ifelse(is.null(feed$itunesId), NA, feed$itunesId),
    trend_score           = feed$trendScore,
    newest_item_publish_time = feed$newestItemPublishTime,
    queried_category      = feed$queried_category,
    # Collapse the categories list into a comma-separated string
    categories            = paste(unlist(feed$categories), collapse = ", "),
    stringsAsFactors = FALSE
  )
}))

# Check for duplicate podcast IDs
sum(duplicated(feeds_df$id))

# Save data frame to csv
write.csv(feeds_df, "data/trending_feeds_raw.csv", row.names = FALSE)