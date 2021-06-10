
# load used packages
library(package = "tidyverse")




#------------------------------------------------------------------------------*
#' Get OpenStreetMap data for the CUNOC campus area ----
#------------------------------------------------------------------------------*

# rough bounding box
cunoc_bbox <- sf::st_bbox(
  c(
    xmin = -91.53954170631214, xmax = -91.53018616149876,
    ymin = 14.841982763478367, ymax = 14.848474835926678
  ),
  crs = 4326
)

# Get OSM data only if no snapshot available
if(
  !(
    file.exists("data/snapshots/cunoc_raw.rds") &&
    file.exists("data/snapshots/cunoc_roads.rds")
  )
){
  # Needed if downloading OSM data
  # devtools::install_github("ropensci/osmdata")
  library(package = "osmdata")
  
  # raw OSM data
  cunoc <- osmdata::opq(bbox = cunoc_bbox) %>%
    osmdata_sf()
  
  cunoc_roads <- osmdata::opq(bbox = cunoc_bbox) %>%
    # get highways
    osmdata::add_osm_feature(key = "highway") %>%
    osmdata_sf()
  
  # write snapshots
  write_rds(cunoc, file = "data/snapshots/cunoc_raw.rds")
  write_rds(cunoc_roads, file = "data/snapshots/cunoc_roads.rds")
} else {
  # read available snapshots
  cunoc <- read_rds(file = "data/snapshots/gt_raw.rds")
  cunoc_roads <- read_rds(file = "data/snapshots/gt_roads.rds")
}




cunoc %>%
  magrittr::extract2("osm_polygons") %>%
  filter(grepl("San Carlos", name)) %>%
  ggplot() +
  geom_sf(
    data = cunoc_roads %>%
      magrittr::extract2("osm_lines")
  ) +
  geom_sf(
    color = "red"
  )
