library(rgdal)
library(leaflet)
library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)


setwd("~/Documents/GitHub/WA-rental-prices")


##### Get the data from Zillow

# Seattle zillow rent index 
# Median ZRI $/sq.ft
# http://files.zillowstatic.com/research/public/Neighborhood/Neighborhood_ZriPerSqft_AllHomes.csv

dir.create("data")
setwd("data")
dir.create("price-data")
setwd("price-data")
zillow_data_url <- "http://files.zillowstatic.com/research/public/Neighborhood/Neighborhood_ZriPerSqft_AllHomes.csv"
download.file(zillow_data_url, "zri_sqft.csv")
zri_sqft <- read_csv("zri_sqft.csv")

setwd(..)

# Seattle neighbourhood shapes
# http://www.zillow.com/static/shp/ZillowNeighborhoods-WA.zip

dir.create("geo-data")
setwd("geo-data")

zillow_nhood_wa_url <- "http://www.zillow.com/static/shp/ZillowNeighborhoods-WA.zip"
download.file(zillow_nhood_wa_url,"ZillowNeighborhoods-WA.zip")
unzip("ZillowNeighborhoods-WA.zip", exdir = "ZillowNeighborhoods-WA")

nhood_wa <-readOGR(dsn = "ZillowNeighborhoods-WA", layer = "ZillowNeighborhoods-WA") #Uses the rgdal library

# Let's take a quick look at this shape file. Base R plot is great for quickly evaluating spatial data like shape files. 

plot(nhood_wa)

# Clearly there's a few areas beyond our scope of interest. We can look at the hierarchical geographic data in the shape file pretty easily.

glimpse(nhood_wa@data)

# We have a State, a County, a City, a Neighbourhood name, and a RegionID. 

table(nhood_wa@data$COUNTY)

# Let's limit ourselves to neighbourhoods in King County so we can focus on Seattle.

nhood_kc <- nhood_wa[nhood_wa@data$COUNTY=="King",]
plot(nhood_kc)

# Visualizing this in Leaflet

sea <- leaflet(nhood_kc) %>% 
  addPolygons(
    stroke = TRUE,
    weight = 0.5,
    color = "grey",
    fillOpacity = 0.25,
    fillColor = "blue",
    popup = nhood_kc$NAME
  )

# Add a basemap to help contextualize. More info on third-party basemaps in Leaflets can he found here: https://github.com/leaflet-extras/leaflet-providers

sea <- sea %>% addProviderTiles("CartoDB.Positron")

sea


# Let's bring in our rent data and merge with our spatial data.
# First, let's take a look at the structure of the rent data.
glimpse(zri_sqft)

# It's in a neat but wide format, useful for loading into a spreadsheet and doing cell-calculations. Unfortunately, this is not particularly tidy data for R and its various visualization and analysis libraries. Fortunately, there's a useful library called tidyr that helps make reshaping a breeze. 

zri_sqft_tidy <- gather(zri_sqft, key = ym, value = price_sqft, `2010-11`:`2016-05`)

zri_sqft_tidy <- zri_sqft_tidy[zri_sqft_tidy$CountyName=="King",]

zri_sqft_tidy %>% 
  ggvis(~price_sqft,~ym) %>%
  





#nhood_kc <- merge(nhood_kc,zri_sqft, by.all = "RegionId")