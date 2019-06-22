library(tidyverse)
library(janitor)
library(httr)
library(jsonlite)
library(magrittr)
options(scipen = 999)
options(stringsAsFactors = FALSE)

#import API key from REnviron
myfbkey <- Sys.getenv("FACEBOOK_AD_API_KEY")

base <- "https://graph.facebook.com/v3.1/ads_archive?"

# available fields: ad_creation_time,ad_creative_body,ad_creative_link_caption,ad_creative_link_description,ad_creative_link_title,ad_delivery_start_time,ad_delivery_stop_time,ad_snapshot_url,currency,demographic_distribution,funding_entity,impressions,page_id,page_name,region_distribution,spend

fields <- "fields=ad_creation_time,ad_creative_body,ad_creative_link_caption,ad_creative_link_description,ad_creative_link_title,ad_delivery_start_time,ad_delivery_stop_time,ad_snapshot_url,currency,demographic_distribution,funding_entity,impressions,page_id,page_name,region_distribution,spend&"

endpoint_h <- paste0(
                      "search_terms='biden'", "&",
                     "ad_type=POLITICAL_AND_ISSUE_ADS", "&",
                     "ad_reached_countries=['US']", "&",
                     "access_token=", myfbkey
                    )
                     
                     # ".json")


call1 <- paste0(base, fields, endpoint_h)
call1

get_hkeyraces <- GET(call1)

get_hkeyraces$status_code
get_hkeyraces$content
#convert from raw to characters
this.raw.content <- rawToChar(get_hkeyraces$content)
#count how many characters
nchar(this.raw.content)
#look at first 100
substr(this.raw.content, 1, 100)
#parse this json?
this.content <- fromJSON(this.raw.content)
#returns a list?
class(this.content)
#how long is the list
length(this.content)
this.content[[1]] #the first element - should be states if working
this.content[[2]] #the data itself, or so it appears to be!
#dataframe from JUST the 3 content 
content_df <- as.data.frame(this.content[[1]])

glimpse(content_df)




#trying to unnest the list columns into their own adjacent columns on same row ####
mydf <- content_df %>% 
  select(ad_creative_link_title, region_distribution) %>% 
  head(4) %>% 
  as_tibble()

#row id to column?
mydf

mydf <- mydf %>% 
  tibble::rowid_to_column("tempID")

#unnest
mydf_unnested <- mydf %>%
  unnest(region_distribution) 

mydf_unnested$percentage <- as.numeric(mydf_unnested$percentage)

mydf_unnested %>% 
  group_by(region) %>% 
  summarise(sum(percentage))

mydf_unnested %>% 
  group_by(ad_creative_link_title, region) %>% 
  summarise(sum(percentage))


#testing out one ad only
test <- mydf_unnested %>%
  filter(tempID == 2)

test$percentage <- as.numeric(test$percentage)

sum(test$percentage)


#inspect the list column named "candidates" for one record
# str(content_df$candidates[[1]], max.level = 1) 
# #unnest
# z <- content_df %>%
#   unnest()
# result <- z

y <- content_df %>%
  select(ad_creation_time, region_distribution) %>% 
  unnest()


content_df_tibble <- as_tibble(content_df)

sampleforbpi <- head(content_df_tibble, 2)

z <- sampleforbpi %>% 
  unnest(demographic_distribution)


sampleforbpi %>% 
  write_csv("sampleforbpi.csv")
  