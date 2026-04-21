# 02_podcast_index_api.R
# Purpose: Authenticate and make exploratory calls to the Podcast Index API
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

# Refresh auth
unix_time <- as.integer(Sys.time())
auth_hash <- digest(
  paste0(api_key, api_secret, unix_time),
  algo = "sha1",
  serialize = FALSE
)

# Single test call to trending
response_test <- request("https://api.podcastindex.org/api/1.0/podcasts/trending") |>
  req_url_query(max = 5, cat = "Technology") |>
  req_headers(
    "X-Auth-Key" = api_key,
    "X-Auth-Date" = as.character(unix_time),
    "Authorization" = auth_hash,
    "User-Agent" = "PodcastPortfolioProject/1.0"
  ) |>
  req_perform()

parsed_test <- response_test |> resp_body_json()
str(parsed_test, max.level = 2)

str(parsed_test$feeds[[1]])

# Refresh auth
unix_time <- as.integer(Sys.time())
auth_hash <- digest(
  paste0(api_key, api_secret, unix_time),
  algo = "sha1",
  serialize = FALSE
)

# Look up a single feed by ID
response_feed <- request("https://api.podcastindex.org/api/1.0/podcasts/byfeedid") |>
  req_url_query(id = 6369321) |>
  req_headers(
    "X-Auth-Key" = api_key,
    "X-Auth-Date" = as.character(unix_time),
    "Authorization" = auth_hash,
    "User-Agent" = "PodcastPortfolioProject/1.0"
  ) |>
  req_perform()

parsed_feed <- response_feed |> resp_body_json()
str(parsed_feed$feed)

# Refresh auth
unix_time <- as.integer(Sys.time())
auth_hash <- digest(
  paste0(api_key, api_secret, unix_time),
  algo = "sha1",
  serialize = FALSE
)

# Get category list
response_cats <- request("https://api.podcastindex.org/api/1.0/categories/list") |>
  req_headers(
    "X-Auth-Key" = api_key,
    "X-Auth-Date" = as.character(unix_time),
    "Authorization" = auth_hash,
    "User-Agent" = "PodcastPortfolioProject/1.0"
  ) |>
  req_perform()

parsed_cats <- response_cats |> resp_body_json()

# Flatten to a readable data frame
cats_df <- do.call(rbind, lapply(parsed_cats$feeds, function(x) {
  data.frame(id = x$id, name = x$name, stringsAsFactors = FALSE)
}))

View(cats_df)

# Refresh auth
unix_time <- as.integer(Sys.time())
auth_hash <- digest(
  paste0(api_key, api_secret, unix_time),
  algo = "sha1",
  serialize = FALSE
)

# Test low-volume categories
categories_to_test <- c("Government", "History", "Fiction", "Hinduism", "Mathematics")

for (cat in categories_to_test) {
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
  cat(cat, ":", parsed$count, "\n")
  Sys.sleep(1)
}