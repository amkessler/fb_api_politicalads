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
                      "search_terms='california'", "&",
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


#convert dataframe columns to list columns
content_df$impressions <- as.list(content_df$impressions)


#trying to unnest the list columns into their own adjacent columns on same row ####
mydf <- content_df %>% 
  select(ad_creative_link_title, demographic_distribution) %>% 
  head(4) %>% 
  as_tibble()

#row id to column?
mydf

mydf <- mydf %>% 
  tibble::rowid_to_column("tempID")

#unnest
mydf_unnested <- mydf %>%
  unnest(demographic_distribution) 

#testing out one ad only
test <- mydf_unnested %>%
  filter(tempID == 1)

test$percentage <- as.numeric(test$percentage)

sum(test$percentage)

test %>% 
  group_by(tempID, gender) %>% 
  summarise(sum(percentage))

test %>% 
  group_by(tempID, age) %>% 
  summarise(sum(percentage)) 


#example:

# mydf %>%
#   unnest(weird_col) %>%
#   group_by(regular_col, normal_col) %>%
#   mutate(
#     weird_col = flatten_chr(weird_col),
#     weird_colname = str_c("weirdo_", row_number())
#   ) %>% # or just as.character
#   spread(weird_colname, weird_col)







#inspect the list column named "candidates" for one record
str(content_df$candidates[[1]], max.level = 1) 
#unnest
z <- content_df %>%
  unnest()
result <- z

z <- content_df %>%
  select(ad_creation_time, region_distribution) %>% 
  unnest()







#FUNCTION FOR BUILDING CALL TO GRAB 

pullhouseresults <- function(x) {
  base <- "https://data.cnn.com/ELECTION/2018November6/"
  endpoint_h <- paste0("full/", x, ".json")
  call1 <- paste0(base,endpoint_h)
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
  this.content[[3]] #the data itself, or so it appears to be!
  #dataframe from JUST the 3 content 
  content3_df <- as.data.frame(this.content[[3]])
  #inspect the list column named "candidates" for one record
  str(content3_df$candidates[[1]], max.level = 1) 
  #unnest
  z <- content3_df %>%
    unnest()
  result <- z
  return(result)
}

