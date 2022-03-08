# Function: Convert Points to sf Object with Buffer 
# Project: Acquisition and Analysis of Crowd-Sourced Traffic Data at Varying Spatial Scales
# Script Authors: Sebastian T. Rowland and Jenni A. Shearston 
# Updated: 03/07/2022

####***********************
#### Table of Contents #### 
####***********************

# N: Notes
# 1: Function to Convert Points to sf Object w Buffer

####**************
#### N: Notes #### 
####**************

# This function converts points and point IDs to a sf object with a buffer of 
# radius.deg radius (in decimal degrees) around each point. At least a small buffer
# must be used. 

####*********************************************************
#### 1: Function to Convert Points to sf Object w Buffer #### 
####*********************************************************

# BEGIN FUNCTION 

point_to_sf_wbuffer <- function(point_lats = bronx_points_lats, 
                                point_lons = bronx_points_lons,
                                point_ids = bronx_point_ids,
                                radius.deg = 0.000075,
                                dir_output = 'bronx_example_points',
                                name_output = 'bronx_example_points.shp') {
  
  # 1a Create dataframe 
  point_df <- data.frame(point_id = point_ids,
                         lon = point_lons,
                         lat = point_lats) 
  
  # 1b Convert to simple feature
  point_sf <- point_df %>%  sf::st_as_sf(coords = c('lon', 'lat'))
  
  # 1c Add buffer
  point_sf <- st_buffer(x = point_sf, dist = radius.deg) 

  # 1d Save shapefile
  point_sf %>%
    sf::st_write(here::here('outputs', 'Rtutorials', 
                            dir_output, name_output), 
                 delete_layer = TRUE)
  
  # 1e Return shapefile
  return(point_sf)
  
}

# END FUNCTION



