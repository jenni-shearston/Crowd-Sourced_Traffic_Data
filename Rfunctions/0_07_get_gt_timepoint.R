# Function: Obtain gt_timeseries for a captured_datetime
# Project: Acquisition and Analysis of Crowd-Sourced Traffic Data at Varying Spatial Scales
# Script Authors: Sebastian T. Rowland and Jenni A. Shearston 
# Updated: 03/07/2022

####***********************
#### Table of Contents #### 
####***********************

# N: Notes
# 1: Function to create the gt_timeseries for a captured_datetime

####**************
#### N: Notes #### 
####**************

# This function counts gt_cat values (e.g., values from gt_image_cat files)
# for the entire traffic map area for a single inputted captured_datetime.

####***************************************************************************
#### 1: Function to create the gt_timeseries for one captured_datetime #### 
####***************************************************************************

# BEGIN FUNCTION 
get_gt_timepoint <- function(captured_datetime_filename, 
                             gt_dir) {
  
  # Example value 
  #captured_datetime_filename = 'CCC_01_10_20__00:30.png'

  # 1a Pull datetime from filename
  captured_datetime <- captured_datetime_filename %>% 
    stringr::str_remove_all('.png') %>%
    stringr::str_remove_all('[A-z]') %>%
    stringr::str_replace('[[:punct:]]', '') 
    
  # 1b Determine the available gt_image_cats 
  available_files <- list.files(gt_dir)
  
  # 1c If the gt_image_cat is available:
  if (sum(captured_datetime_filename == available_files) == 1) {
    
    # 1c.i Read the gt_image_cat.png as a matrix
    gt_matrix_cat <- png::readPNG(here::here(gt_dir, captured_datetime_filename))
    
    # 1c.ii Recover original gt values
    #    Note: Because gt_matrix_cat was read into R as a png, the values
    #          of each pixel were divided by 256 (the max value for a png), so that 
    #          all values were between 0 and 1.
    gt_matrix_cat <- round(gt_matrix_cat * 256, 1)
    
    # 1c.iii Create the gt_timeseries
    #    Note: We count the number of pixels of each type for the entire traffic 
    #          map area. For example: gt_cat == 2 evaluates whether the pixel
    #          value is equal to 2 (red color code), yielding a 1 if the 
    #          pixel value is 2 and a 0 if not. Thus the sum is a sum of
    #          true/false statements and yields the number of pixels of that type.
    #          Finally, a variable for captured_datetime is added.
    gt_timepoint <- 
      data.frame(gt_cat = as.vector(gt_matrix_cat)) %>% 
      dplyr::summarize(gt_pixcount_maroon       = sum(gt_cat == 1),
                       gt_pixcount_red          = sum(gt_cat == 2),
                       gt_pixcount_orange       = sum(gt_cat == 3),
                       gt_pixcount_green        = sum(gt_cat == 4),
                       gt_pixcount_gray         = sum(gt_cat == 5),
                       gt_pixcount_construction = sum(gt_cat == 6),
                       gt_pixcount_emergency    = sum(gt_cat == 7),
                       gt_pixcount_notsampled   = sum(gt_cat == 8),
                       gt_pixcount_background   = sum(gt_cat == 9),
                       gt_pixcount_tot          = n()) %>% 
      dplyr::mutate(captured_datetime = captured_datetime) %>% 
      dplyr::select(captured_datetime, everything())
    
  # 1d If the gt_image_cat is NOT available:
  } else if (sum(captured_datetime_filename == available_files) == 0) {
    
    # 1d.i Generate NA if the gt_image_cat file for the captured_datetime is not available
    gt_timepoint <- data.frame(gt_pixcount_maroon          = NA,
                               gt_pixcount_red             = NA,
                               gt_pixcount_orange          = NA,
                               gt_pixcount_green           = NA,
                               gt_pixcount_gray            = NA,
                               gt_pixcount_construction    = NA,
                               gt_pixcount_emergency       = NA,
                               gt_pixcount_notsampled      = NA,
                               gt_pixcount_background      = NA,
                               gt_pixcount_tot             = NA) %>% 
      mutate(captured_datetime = captured_datetime) %>% 
      dplyr::select(captured_datetime, everything())
      
  }
  
  # 1e Return dataframe of aggregated timeseries 
  return(gt_timepoint)
}

# END FUNCTION 


