# Application: Changes in Traffic Due to the Covid-19 Pandemic - Road Segments
# Project: Acquisition and Analysis of Crowd-Sourced Traffic Data at Varying Spatial Scales
# Script Authors: Jenni A. Shearston and Sebastian T. Rowland
# Updated: 03/25/2022

####***********************
#### Table of Contents #### 
####***********************

# N: Notes
# 0: Preparation 
# 1: Load & Prepare Data
# 2: Compare CCC Before vs During Stay-at-home Orders (Table 1)
# 3: Create Ordinal Timeseries Plot (Figure 4)

####**************
#### N: Notes ####
####**************

# Na Description
# In this script we demonstrate that timeseries of traffic maps can be used to 
# detect and characterize changes in traffic. We analyze changes in traffic
# at three street segments in the South Bronx of New York City, before and after
# announcement of COVID-19 related stay-at-home orders. 

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

# 1a Load timeseries data
#    Note: This timeseries was created using the 
#          'tutorial_create_timeseries_polygons.R' with a polygon
#          shapefile input 'bronx_3_street_segments_buffered', both
#          available in the github repository. All needed data is
#          included in the repository to re-create this file.
road_segs <- read_fst(here::here('outputs', 'Rtutorials', 
                                 'bronx_streetsegs_example_timeseries.fst'))

# 1b Convert captured_datetime var to posixct, create stay-at-home variable,
#    create label for poly_id variable
#    Note: March 20th is the day New York's stay-at-home order (NY on PAUSE)
#          was announced by the governor, although it did not go into effect 
#          until March 22
road_segs <- road_segs %>% 
  mutate(captured_datetime = lubridate::mdy_hm(captured_datetime, 
                                               tz = 'America/New_York'),
         sah_announce = factor(ifelse(captured_datetime >= '2020-03-20 00:30:00', 
                                      'post_ann', 'pre_ann')),
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

####******************************************************************
#### 2: Compare CCC Before vs During Stay-at-home Orders (Table 1) #### 
####******************************************************************

# 2a Compare CCC values before vs during stay-at-home orders
sah_comparison <- road_segs %>% 
  group_by(poly_name, sah_announce) %>% 
  summarise(ccc_mean = round(mean(CCC, na.rm = T), digits = 2),
            ccc_sd = round(sd(CCC, na.rm = T), digits = 2)) 

# 2b Calculate difference between before vs during
sah_difference <- sah_comparison %>% 
  dplyr::select(-ccc_sd) %>% 
  pivot_wider(names_from = sah_announce, values_from = ccc_mean) %>% 
  mutate(difference = post_ann - pre_ann)

####**************************************************
#### 3: Create Ordinal Timeseries Plot (Figure 4) #### 
####**************************************************

# 3a Create dataframe to specify facet for stay-at-home label
label <- tribble(~captured_datetime, ~CCC, ~poly_name,
                 lubridate::ymd_hms('2020-03-20 00:30:00'), 4.5, 'Site A')

# 3b Create timeseries plot
road_segs_timeplot <- road_segs %>% 
  mutate(CCC = as.integer(CCC)) %>% 
  filter(!is.na(CCC)) %>% 
  ggplot(aes(x = captured_datetime, y = CCC)) + 
  geom_line(aes(color = CCC)) + 
  facet_wrap(vars(poly_name), nrow = 3, ncol = 1) + 
  geom_text(aes(label = poly_name, x = lubridate::ymd_hms('2020-03-24 15:30:00'), 
                y = 2.2), check_overlap = TRUE) +
  geom_vline(aes(xintercept = lubridate::ymd_hms('2020-03-20 00:30:00')),
             linetype = 'dashed') + 
  geom_text(data = label, aes(label = 'Stay-at-home Order Announced'), y = 4.4,
            x = lubridate::ymd_hms('2020-03-20 00:30:00'), hjust = 0) + 
  coord_cartesian(ylim = c(2, 4), clip = 'off') +
  theme_bw() + 
  xlab('') + 
  theme(legend.position="none", strip.background = element_blank(),
        strip.text.x = element_blank(), text=element_text(size=16)) + 
  scale_y_continuous(breaks = c(2, 3, 4)) + 
  scale_color_gradient(low = 'red', high = 'green')

# 3c Save plot
tiff(here::here('outputs', 'applications', 'manuscript_fig4_road_segs_timeplot.tif'),
     units = "in", width = 12, height = 7, res = 300)
road_segs_timeplot
dev.off()



