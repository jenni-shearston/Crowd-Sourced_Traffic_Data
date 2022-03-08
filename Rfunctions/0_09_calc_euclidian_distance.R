# Function: Calculate Euclidian Distance
# Project: Acquisition and Analysis of Crowd-Sourced Traffic Data at Varying Spatial Scales
# Script Authors: Sebastian T. Rowland and Jenni A. Shearston 
# Updated: 03/07/2022

####***********************
#### Table of Contents #### 
####***********************

# N: Notes
# 1: Function to Calculate Euclidian Distance

####**************
#### N: Notes #### 
####**************

# This function calculates Euclidian distance. Inputs can be given either as
# lat / lon (e.g., units = degrees) or as y / x (e.g., units = pixels)

####*************************************************
#### 1: Function to Calculate Euclidian Distance #### 
####*************************************************

# BEGIN FUNCTION 

eucl_dist <- function(point1, point2) {
  
  # Sample values
  #point1 <- list(lat = 40.700578, lon = -74.011350)
  #point2 <- list(lat = 40.872149, lon = -73.897445)
  
  # 1a If latitude and longitude are given (e.g., units = degrees)
  if(sum(str_detect(names(point1), 'lat')) == 1){
    eucl_dist <- sqrt((point1$lat - point2$lat)^2 + 
                        (point1$lon - point2$lon)^2)
  }
  
  # 1b If y and x are given (e.g., units = pixels)
  if(sum(str_detect(names(point1), 'y')) == 1){
    eucl_dist <- sqrt((point1$y - point2$y)^2 + 
                        (point1$x - point2$x)^2)
  }
  
  # 1c Return results of calculation
  return(eucl_dist)
  
}

# END FUNCTION



