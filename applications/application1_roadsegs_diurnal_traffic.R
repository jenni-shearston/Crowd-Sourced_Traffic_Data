# Application: Diurnal Traffic at Three Road Segments
# Project: Acquisition and Analysis of Crowd-Sourced Traffic Data at Varying Spatial Scales
# Script Authors: Jenni A. Shearston and Sebastian T. Rowland
# Updated: 06/08/2022

####***********************
#### Table of Contents #### 
####***********************

# N: Notes
# 0: Preparation 
# 1: Load & Prepare Data
# 2:

####**************
#### N: Notes ####
####**************

# Na Description
# In this script we demonstrate that time series of traffic maps can be used to 
# characterize traffic at high spatio-temporal resolution. We show diurnal traffic
# plots for three street segments in the South Bronx of New York City.

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

####****************************
#### 1: Load & Prepare Data #### 
####****************************

# 1a Load time series data
#    Note: This time series was created using the 
#          'tutorial_create_timeseries_polygons.R' with a polygon
#          shapefile input 'bronx_3_street_segments_buffered', both
#          available in the github repository. All needed data is
#          included in the repository to re-create this file.
road_segs <- read_fst(here::here('outputs', 'Rtutorials', 
                                 'bronx_streetsegs_example_timeseries.fst'))

# 1b Convert captured_datetime var to posixct, create label for poly_id variable
road_segs <- road_segs %>% 
  mutate(captured_datetime = lubridate::mdy_hm(captured_datetime, 
                                               tz = 'America/New_York'),
         poly_name = case_when(poly_id == 59544 ~ 'Site C',
                               poly_id == 95009 ~ 'Site B',
                               poly_id == 101209 ~ 'Site A'))

# 1c Create ordinal congestion color code (CCC) variable
#    Note: The mode is used to create the CCC value for each unique polygon/
#          captured_datetime combination -- corresponding to the color
#          (green=4, orange=3, red=2, maroon=1) that was assigned the most pixels
#          A road segment is assigned NA if it had 0 green, orange, red, and 
#          maroon pixels
road_segs <- road_segs %>% 
  pivot_longer(cols = gt_pixcount_maroon:gt_pixcount_green,
               names_to = 'gt_cat',
               values_to = 'gt_value') %>% 
  group_by(captured_datetime, poly_id) %>% 
  filter(gt_value == max(gt_value)) %>%
  ungroup() %>% 
  mutate(gt_cat = ifelse(gt_value == 0, NA, gt_cat)) %>% 
  distinct() %>% 
  mutate(CCC = stringr::str_replace(gt_cat, 'gt_pixcount_', ''),
         CCC = case_when(CCC == 'maroon' ~ 1,
                         CCC == 'red' ~ 2,
                         CCC == 'orange' ~ 3,
                         CCC == 'green' ~ 4),
         CCC = as.numeric(CCC))

# 1d Select day of interest
#    Note: Because the time period overlaps the implementation of COVID-19
#          related stay-at-home orders, we select one day before the 
#          orders were implemented.
road_segs <- road_segs %>% 
  mutate(date = lubridate::date(captured_datetime),
         hour = lubridate::hour(captured_datetime)) %>% 
  filter(date == '2020-03-17') %>% dplyr::select(poly_name, CCC, hour)


####**************************************************************
#### 2: Create diurnal plots for each road segment (Figure 4) #### 
####**************************************************************

# 2a Add points halfway between observations to make line colors
#    split bewteen observations
mid_points <- road_segs %>% 
  mutate(hour = hour + 1.5) %>% 
  group_by(poly_name) %>% 
  mutate(CCC2 = (CCC + dplyr::lead(CCC))/2,
         color = factor(case_when(
          lead(CCC) == 1 ~ 1,
          lead(CCC) == 2 ~ 2,
          lead(CCC) == 3 ~ 3,
          lead(CCC) == 4 ~ 4
         ))) %>% 
  ungroup() %>% dplyr::select(-CCC) %>% rename(CCC = CCC2)

# 2b Merge mid points with real observations for plotting
road_segs_for_lineplot <- road_segs %>% 
  mutate(color = factor(CCC)) %>% 
  bind_rows(mid_points) %>% 
  mutate(CCC = factor(CCC)) %>% 
  filter(!is.na(CCC))
  
# 2c Set color palette
CCC_colors <- c('red', 'orange', 'green')

# 2d Create line plot
road_segs_lineplot <- road_segs_for_lineplot %>% 
  ggplot(aes(x = hour, y = CCC)) + 
  geom_line(aes(color = color, group = 1)) + 
  facet_wrap(vars(poly_name), nrow = 1, ncol = 3) +
  theme_bw() + 
  xlab('Hour of Day') +
  theme(text=element_text(size=16), legend.position="none") + 
  scale_color_manual(values = CCC_colors) +
  scale_y_discrete(breaks = c(2, 3, 4))
road_segs_lineplot

# 2b Save plot
tiff(here::here('outputs', 'applications', 'manuscript_fig4_road_segs_diurnalplot.tif'),
     units = "in", width = 12, height = 7, res = 300)
road_segs_lineplot
dev.off()



