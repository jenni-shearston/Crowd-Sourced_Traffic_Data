# Tutorial: Create Google Traffic Timeseries: Spatial Polygons
# Project: Acquisition and Analysis of Crowd-Sourced Traffic Data at Varying Spatial Scales
# Script Authors: Jenni A. Shearston and Sebastian T. Rowland
# Updated: 03/11/2022

####***********************
#### Table of Contents #### 
####***********************

# N: Notes
# 0: Preparation 
# 1: Set Function Inputs
# 2: Prepare Polygon and Raster Inputs
# 3: Prepare Vectors of captured_datetimes of Interest
# 4: Create Google Traffic Timeseries: Polygons

####**************
#### N: Notes ####
####**************

# Na Description
# In this script we present a tutorial for creating a time series from processed
# Google Traffic images, for spatial polygons. As an example, we include one week of 
# processed data for a subset of the NYC area (every 3-hrs, n=56 images), and create a time
# series aggregated to South Bronx census tracts for the time periods of March 17, 2020 
# through March 24, 2020. Users can edit the function inputs described below to 
# complete their own analysis with differing traffic map areas, time periods,
# and spatial polygons. We strongly recommend you clone this repository before running
# the tutorial to ensure you have the same file structure and subfolders as used in
# the tutorial. For definitions of variables created in the timeseries output, see Rglossary.

# Nb Function input definitions
#     polygons_of_interest_path: the file path (directory) for the shapefile containing 
#       polygons that congestion color information will be aggregated within. This 
#       polygon shapefile must include a variable that uniquely identifies each polygon
#       and is coercible to numeric
#     poly_id_var: the name of the variable that uniquely identifies each polygon 
#       in polygons_of_interest
#     gt_geo_projected_path: the file path (directory) for a traffic map image (gt_image_cat)
#       that has been georeferenced and projected in WGS84, preferably as a geotiff
#     gt_image_cat_path: the file path (directory) for a processed traffic map image 
#       (gt_image_cat) of the desired traffic map area, of arbitrary datetime
#     poly_matrix_output_path: the file path (directory) to store the matrix with the 
#       dimensions and resolution of a traffic map image (gt_image_cat), with values
#       corresponding to poly_ids. This is the output of function create_polygon_matrix
#     base_date: the base or start datetime for your timeseries
#     end_date: the end datetime for your timeseries. Only end_date OR sampling_quantity_units_direction
#       should be set
#     sampling_quantity_units_direction: a parameter for calculating an end date based
#       on time units, e.g.: '3 days forward'. The parameter is specified with an 
#       underscore between the quantity, unit, and direction, e.g., 
#       sampling_quantity_units_direction = '3_weeks_forward'. Quantity must be specified
#       as an integer. Available unit options include 'hours', 'days', 'weeks', 
#       'months', and 'years'; available direction options include 'forward' and 
#       'backward'. Only end_date OR sampling_quantity_units_direction should be set
#     timezone = the timezone included in the filenames of the traffic map images 
#       (gt_image_cat filenames)
#     gt_dir: the file path where processed traffic map images (gt_image_cats) are stored
#     captured_datetime_vector: the name of the vector that holds the output of the 
#       make_captured_datetime_vector function; this should not need to be changed
#     gt_agg_timeseries_output_path: the file path (directory) where the .fst file
#       containing the aggregated time series will be saved. This is the output of
#       function get_gt_agg_timeseries
#     method: one of either 'parallel' or 'forloop'; determines which method to loop
#       over all traffic map images in the captured_datetime_vector. 'parallel' uses
#       parallelization (n-1 cores) whereas 'forloop' uses a for loop and a single core
#     captured_datetime_vector_filename: the name of the vector that holds the formatted
#       vector of gt_image_cat filenames. This is the output of the function 
#       reformat_captured_datetime_vector; this should not need to be changed
#     poly_matrix: the matrix with the dimensions and resolution of a traffic map 
#       image (gt_image_cat), with values corresponding to poly_ids. This is the 
#       output of function create_polygon_matrix; this should not need to be changed

# Nc
# In the use case of aggregating within the entire traffic map area, there is no need to
# create a shapefile representing the entire traffic map area in a single polygon.
# Instead, do not run section 2 (the create_polygon_matrix function) and 
# set poly_matrix to 1 (poly_matrix = 1) in section 4 (the get_gt_agg_timeseries function) 

####********************
#### 0: Preparation #### 
####********************

# 0a Specify needed packages
packages <- c('tidyverse', 'raster', 'rgdal', 'terra', 'sf', 'here', 'doParallel',
              'tictoc', 'png', 'fst', 'lubridate', 'stringr', 'parallel', 'foreach')

# 0b Load or install and load all packages
lapply(packages, FUN = function(x){
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)}
  })
rm(packages)

# 0c Source our functions
# 0c.i Get the names of all of the scripts that are functions
myFunctions <- list.files(path = here::here('areal_timeseries','Rfunctions'))

# 0c.ii Define function to run sources 
source_myFunction <- function(FunctionName){
  source(here::here('areal_timeseries', 'Rfunctions', FunctionName))
}

# 0c.iii Source all the function scripts
#        Note: We don't actually need the assignment, it just 
#              removes annoying output generated by the sourcing code. 
#              Since we are just sourcing these, we can use map. 
a <- purrr::map(myFunctions, source_myFunction)
rm(a, myFunctions)

####*****************************
#### 1: Set Function Inputs #### 
####****************************

# Definitions of each function input are provided in Nb above and in the Rglossary.

# 1a Set inputs for function that prepares polygon and raster files
polygons_of_interest_path = here::here('data', 'polygons_of_interest', 'bronx_census_tracts', 'bronx.shp')
poly_id_var = 'geo_id'
gt_geo_projected_path = here::here('data', 'gt_refs', 'gt_geo_projected.tif')
gt_image_cat_path = here::here('data', 'gt_image_cat', 'CCC_01_01_18__02_00.png')
poly_matrix_output_path = here::here('outputs', 'areal_timeseries_tutorial', 'poly_matrix_nyc.rds')

# 1b Set inputs for functions that prepare vectors of datetimes of interest
#    Note: One of either end_date or sampling_quantity_units_direction should be set as 'none' 
#            (both should not have actual values)
#          captured_datetime_vector is already set; it is the name of the vector that holds
#            the output of the make_captured_datetime_vector function
base_date = '2020/03/17 00:30'
end_date = '2020/03/24 21:30'
sampling_quantity_units_direction = 'none'
timezone = 'America/New_York'
gt_dir = here::here('data', 'gt_image_cat', 'bronx_example')

# 1c Set inputs for function that creates a timeseries of traffic data aggregated to polygon ids
#    Note: captured_datetime_vector_filename is already set; it is the name of the vector
#            that holds the output of the reformat_captured_datetime_vector function
#          gt_dir was set in section 1b above
#          poly_matrix is already set; it is the name of the matrix that holds the output of 
#            the create_polygon_matrix function
gt_agg_timeseries_output_path = here::here('outputs/areal_timeseries_tutorial', 'bronx_polygons_example_timeseries.fst')
method = 'parallel'

####*******************************************
#### 2: Prepare Polygon and Raster Inputs #### 
####*******************************************

# 2a Convert polygon shapefile to a matrix with the dimensions and resolution
#    of a traffic map image (create poly_matrix)
#    Note: Rather than using a spatial join to connect polygon ID information to 
#          traffic map image information, we convert both the polygon shapefile and
#          the traffic map image to matrices with the same dimensions and resolution,
#          such that matrix location (matrix index) contains the spatial information;
#          e.g., a point in index[1,2] is at the same spatial location in both the 
#          polygon and traffic matrices. This function saves poly_matrix as well.
tictoc::tic('creates poly_matrix for south bronx census tracts')
poly_matrix <- 
  create_polygon_matrix(polygons_of_interest_path = polygons_of_interest_path,
                        poly_id_var = poly_id_var,
                        gt_geo_projected_path = gt_geo_projected_path,
                        gt_image_cat_path = gt_image_cat_path,
                        poly_matrix_output_path = poly_matrix_output_path)
tictoc::toc()

####**********************************************************
#### 3: Prepare Vectors of captured_datetimes of Interest #### 
####**********************************************************

# 3a Create vector of captured_datetimes of interest
#    Note: The function will fill an NA for any datetimes between the base_date and 
#          end_date that gt_image_cats are not available for
captured_datetime_vector <- make_captured_datetime_vector(
  base_date = base_date,
  end_date = end_date,
  sampling_quantity_units_direction = sampling_quantity_units_direction,
  timezone = timezone)

# 3b Reformat vector of captured_datetimes of interest as gt_image_cat filenames
captured_datetime_vector_formatted <- reformat_captured_datetime_vector(
  captured_datetime_vector = captured_datetime_vector, 
  gt_dir = gt_dir)

####***************************************************
#### 4: Create Google Traffic Timeseries: Polygons #### 
####***************************************************

# 4a Run function to aggregate Google Traffic images to polygons
#    Note: It is highly recommended that you first run the function for one 
#          week of time, to get a sense of how long it will take to run
#          your full datetime vector. A year's worth of analysis for a large
#          city at hourly resolution may take ~ 10-15 hours.
tictoc::tic('completes 1 week of bronx tracts')
gt_timeseries <- 
  get_gt_agg_timeseries(captured_datetime_vector_filename = captured_datetime_vector_formatted, 
                        gt_agg_timeseries_output_path = gt_agg_timeseries_output_path,
                        gt_dir = gt_dir,
                        method = method,
                        poly_matrix = poly_matrix)
tictoc::toc()



