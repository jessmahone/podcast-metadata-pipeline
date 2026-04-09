# 01_test_api.R
# Purpose: Test authentication and make a first call to the Podcast Index API
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

# Build and send test request
# Searching for podcasts by title as a simple first test
response <- request("https://api.podcastindex.org/api/1.0/search/byterm") |>
  req_headers(
    `X-Auth-Key` = api_key,
    `X-Auth-Date` = unix_time,
    `Authorization` = auth_hash,
    `User-Agent` = "portfolio-project/1.0"
  ) |>
  req_url_query(q = "technology") |>
  req_perform()

# Parse the JSON response body into an R list
parsed <- response |>
  resp_body_json()

# See the top-level structure
str(parsed, max.level = 1)

# Look at the structure of a single feed
str(parsed$feeds[[1]])

auth_time <- as.character(unix_time)

response_cats <- request("https://api.podcastindex.org/api/1.0/categories/list") |>
  req_headers(
    "X-Auth-Key" = api_key,
    "X-Auth-Date" = auth_time,
    "Authorization" = digest(
      paste0(api_key, api_secret, auth_time),
      algo = "sha1", serialize = FALSE
    ),
    "User-Agent" = "PodcastPortfolioProject/1.0"
  ) |>
  req_perform()

parsed_cats <- response_cats |> resp_body_json()
parsed_cats

# Flatten the category list into a readable data frame
cats_df <- do.call(rbind, lapply(parsed_cats$feeds, function(x) {
  data.frame(id = x$id, name = x$name, stringsAsFactors = FALSE)
}))

# View it
View(cats_df)