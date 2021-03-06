# Application: Differential changes in Traffic by Income & Race/Ethnicity 
# Due to the Covid-19 Pandemic - Census Tracts
# Project: Acquisition and Analysis of Crowd-Sourced Traffic Data at Varying Spatial Scales
# Script Authors: Jenni A. Shearston and Sebastian T. Rowland
# Updated: 04/21/2022

####***********************
#### Table of Contents #### 
####***********************

# N: Notes
# 0: Preparation 
# 1: Load & Prepare Congestion Data
# 2: Load & Prepare Census Demographic Data
# 3: Compare CCC Before vs During Stay-at-home Orders (Table 2)
# 4: Create Map Showing Most Congested CCC by ICE Vars (Fig 5)

####**************
#### N: Notes ####
####**************

# Na Description
# In this script we demonstrate the value of using larger spatial units, such as
# census tracts, to evaluate variation in changes in traffic after policy 
# implementation by SES characteristics. We analyze changes in traffic
# at census tracts in the South Bronx of New York City, before and after
# announcement of COVID-19 related stay-at-home orders, by varying levels of
# income and racial/ethnic privilege. 

# Nb Index of Concentration at the Extremes Calculation
# ICEi = (Ai-Pi)/Ti
# where, say, in the case of the ICE for income,
# Ai is equal to the number of affluent persons in unit of analysis i 
# (e.g., in the 80th income percentile), 
# Pi is equal to the number of poor persons in unit of analysis i 
# (e.g., in the 20th income percentile), 
# Ti is equal to the total population with known income in unit of analysis i
# Citation: Nancy Krieger, Pamela D. Waterman, Jasmina Spasojevic, Wenhui Li, 
# Gil Maduro, Gretchen Van Wye, “Public Health Monitoring of Privilege and 
# Deprivation With the Index of Concentration at the Extremes”, American Journal 
# of Public Health 106, no. 2 (February 1, 2016): pp. 256-263.

####********************
#### 0: Preparation #### 
####********************

# 0a Specify needed packages
packages <- c('tidyverse', 'raster', 'rgdal', 'terra', 'sf', 'here', 'doParallel',
              'tictoc', 'png', 'fst', 'lubridate', 'stringr', 'parallel', 
              'foreach', 'ggpattern')

# 0b Load or install and load all packages
lapply(packages, FUN = function(x){
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)}
})
rm(packages)

####***************************************
#### 1: Load & Prepare Congestion Data #### 
####***************************************

# 1a Load timeseries data
#    Note: This timeseries was created using the 
#          'tutorial_create_timeseries_polygons.R' with a polygon
#          shapefile input 'bronx_census_tracts', both
#          available in the github repository. All needed data is
#          included in the repository to re-create this file.
census_tracts <- read_fst(here::here('outputs', 'Rtutorials', 
                                     'bronx_polygons_example_timeseries.fst'))

# 1b Convert captured_datetime var to posixct, convert poly_id to character, and 
#    create stay-at-home variable
#    Note: March 20th is the day New York's stay-at-home order (NY on PAUSE)
#          was announced by the governor, although it did not go into effect until
#          March 22
census_tracts <- census_tracts %>% 
  mutate(captured_datetime = lubridate::mdy_hm(captured_datetime, 
                                               tz = 'America/New_York'),
         poly_id = as.character(poly_id),
         sah_announce = factor(ifelse(captured_datetime >= '2020-03-20 00:30:00', 
                                      'post_ann', 'pre_ann')))

# 1c Create continuous congestion color code (CCC) variable
#    Note: In this case we use the ratio of green / all colors, multiplied
#          by 100, to give us a percent free-flowing traffic as the CCC value
census_tracts <- census_tracts %>% 
  mutate(streets = gt_pixcount_green + gt_pixcount_orange + 
           gt_pixcount_red + gt_pixcount_maroon + gt_pixcount_gray,
         CCC = (gt_pixcount_green/streets)*100)

####***********************************************
#### 2: Load & Prepare Census Demographic Data #### 
####***********************************************

# 2a Load & tidy race/ethnicity data
race <- read_csv(here::here('data', 'census', 'census_race_ethnicity_tracts.csv')) %>% 
  filter(GISJOIN != "GIS Join Match Code") %>% 
  dplyr::select(GISJOIN, STATEA, COUNTYA, TRACTA, ALUKE001, ALUKE003, 
                ALUKE004, ALUKM001, ALUKM003, ALUKM004) %>% 
  rename(fips_code = GISJOIN, state_code = STATEA, county_code = COUNTYA,
         tract_code = TRACTA, all_est = ALUKE001, nhwhite_est = ALUKE003,
         nhblack_est = ALUKE004, all_moe = ALUKM001, nhwhite_moe = ALUKM003,
         nhblack_moe = ALUKM004) %>% 
  filter(state_code == "36" & county_code == "005") %>% 
  mutate(all_est = as.numeric(all_est),
         nhwhite_est = as.numeric(nhwhite_est),
         nhblack_est = as.numeric(nhblack_est),
         join_id = paste0(state_code, county_code, tract_code))
 
# 2b Load & tidy US household income percentiles
#    Notes: 20% percentile upper limit =  $25,766
#           80% percentile upper limit = $126,609
us_income_percentiles <- read_csv(here::here('data', 'census', 
                                             'census_hhincome_nation.csv')) %>% 
  filter(GISJOIN != "GIS Join Match Code") %>% 
  rename(q20_upper_est = AMEJE001, q40_upper_est = AMEJE002, q60_upper_est = AMEJE003,
         q80_upper_est = AMEJE004, q95_lower_est = AMEJE005, q20_upper_moe = AMEJM001,
         q40_upper_moe = AMEJM002, q60_upper_moe = AMEJM003, q80_upper_moe = AMEJM004,
         q95_lower_moe = AMEJM005) %>% 
  dplyr::select(-GISJOIN, -STUSAB, -NATION, -NATIONA, -AIHHTLI,  -AITS, -MEMI,
                -UR, -PCI, -NAME_E, -NAME_M)

# 2c Load & tidy household income data
#    Notes: Only keeping the income categories closest to the 20th percentile
#           (and below) and closest to the 80th percentile (and above), as these
#           will be used to create the extreme groups for the income ICE variable
#           $24,999 and less; $125,000 and more
hhincome <- read_csv(here::here('data', 'census', 'census_hhincome_tracts.csv')) %>% 
  filter(GISJOIN != "GIS Join Match Code") %>% 
  dplyr::select(GISJOIN, STATEA, COUNTYA, TRACTA, ALW0E001:ALW0E005, 
                ALW0E015:ALW0E017, ALW0M001:ALW0M005, ALW0M015:ALW0M017) %>% 
  rename(fips_code = GISJOIN, state_code = STATEA, county_code = COUNTYA,
         tract_code = TRACTA, all_est = ALW0E001, iless10_est = ALW0E002,
         i10000to14999_est = ALW0E003, i15000to19999_est = ALW0E004, 
         i20000to24999_est = ALW0E005, i125000to149999_est = ALW0E015, 
         i150000to199999_est = ALW0E016, i200000plus_est = ALW0E017,
         all_moe = ALW0M001, iless10_moe = ALW0M002,
         i10000to14999_moe = ALW0M003, i15000to19999_moe = ALW0M004, 
         i20000to24999_moe = ALW0M005, i125000to149999_moe = ALW0M015, 
         i150000to199999_moe = ALW0M016, i200000plus_moe = ALW0M017) %>% 
  mutate(across(all_est:i200000plus_moe, ~as.numeric(.x))) %>% 
  filter(state_code == "36" & county_code == "005") %>% 
  mutate(join_id = paste0(state_code, county_code, tract_code)) 

# 2d Create index of concentration at the extremes (ICE) variable for race/ethnicity
#    Notes: We set as the extreme groups persons who self-identified as 
#           non-Hispanic White versus non-Hispanic Black
ice_race <- race %>%  
  mutate(ice_race = round((nhwhite_est - nhblack_est)/all_est, digits = 2)) %>% 
  dplyr::select(join_id, ice_race)

# 2e Create ICE variable for income
#    Notes: We set as the extreme groups the income categories closest to the
#           national 20th and 80% categories, here corresponding to 24,999 and less
#           and 125000 and more
#           First we sum the categories above and below the cutpoints
ice_hhincome <- hhincome %>% 
  mutate(lower_extreme = iless10_est + i10000to14999_est + i15000to19999_est +
           i20000to24999_est,
         higher_extreme = i125000to149999_est + i150000to199999_est + i200000plus_est,
         ice_hhincome = round((higher_extreme - lower_extreme)/all_est, digits = 2)) %>% 
  dplyr::select(join_id, ice_hhincome)

# 2f Merge with traffic data
census_tracts <- census_tracts %>% 
  left_join(ice_race, by = c('poly_id' = 'join_id'))
census_tracts <- census_tracts %>% 
  left_join(ice_hhincome, by = c('poly_id' = 'join_id'))

####******************************************************************
#### 3: Compare CCC Before vs During Stay-at-home Orders (Table 2) #### 
####******************************************************************

# 3a Break ICE variables into quintiles
# 3a.i Determine range of ICE vars and total number of counties
summary(census_tracts$ice_hhincome)
summary(census_tracts$ice_race)
length(unique(census_tracts$poly_id))
# 3a.ii Create quintile cutoffs
ice_race_quintile_cuts = quantile(census_tracts$ice_race, probs = c(0:5/5), 
                                  na.rm = T)
ice_hhincome_quintile_cuts = quantile(census_tracts$ice_hhincome, probs = c(0:5/5), 
                                      na.rm = T)
# 3a.iii Create quintile variables
census_tracts <- census_tracts %>% 
  mutate(ice_race_quint = cut(ice_race, ice_race_quintile_cuts, 
                              include.lowest = T, 
                              labels = c('Low Privilege', 'Low-Med', 'Med',  
                                         'Med-High', 'High Privilege')),
         ice_hhincome_quint = cut(ice_hhincome, ice_hhincome_quintile_cuts, 
                                  include.lowest = T, 
                                  labels = c('Low Privilege', 'Low-Med', 'Med',  
                                             'Med-High', 'High Privilege')))

# 3b Compare CCC values before vs during stay-at-home orders, by quintiles
# 3b.i Race/ethnicity
sah_comparison_race <- census_tracts %>% 
  group_by(sah_announce, ice_race_quint) %>% 
  summarise(ccc_mean = round(mean(CCC, na.rm = T), digits = 2),
            ccc_sd = round(sd(CCC, na.rm = T), digits = 2))
# 3b.ii Household income 
sah_comparison_hhincome <- census_tracts %>% 
  group_by(sah_announce, ice_hhincome_quint) %>% 
  summarise(ccc_mean = round(mean(CCC, na.rm = T), digits = 2),
            ccc_sd = round(sd(CCC, na.rm = T), digits = 2))

# 3c Calculate difference between before vs during for each quintile
# 3c.i Race/ethnicity
sah_difference_race <- sah_comparison_race %>% 
  dplyr::select(-ccc_sd) %>% 
  pivot_wider(names_from = sah_announce, values_from = ccc_mean) %>% 
  mutate(difference_race_quint = post_ann - pre_ann) %>% 
  rename(post_ann_race_quint = post_ann,
         pre_ann_race_quint = pre_ann)
# 3c.ii Household income
sah_difference_hhincome <- sah_comparison_hhincome %>% 
  dplyr::select(-ccc_sd) %>% 
  pivot_wider(names_from = sah_announce, values_from = ccc_mean) %>% 
  mutate(difference_hhincome_quint = post_ann - pre_ann) %>% 
  rename(post_ann_hhincome_quint = post_ann,
         pre_ann_hhincome_quint = pre_ann)

# 3d Join difference variables to original dataframe
census_tracts <- census_tracts %>% 
  left_join(sah_difference_race, by = 'ice_race_quint') %>% 
  left_join(sah_difference_hhincome, by = 'ice_hhincome_quint')

####******************************************************************
#### 4: Create Map Showing Most Congested CCC by ICE Vars (Fig 5) #### 
####******************************************************************

# 4a Calculate lowest 10 percentile of CCC for mapping
mean_ccc_ct = census_tracts %>% 
  group_by(poly_id) %>% 
  summarise(mean_ccc = mean(CCC, na.rm = T)) 
ccc_bottom_10 = quantile(mean_ccc_ct$mean_ccc, probs = .1, na.rm = T)

# 4b Calculate mean CCC for each census tract, create least free-flowing variable
#    Note: A census tracts will be assigned 'least free-flowing' if its mean CCC
#          value is at or below the 10th percentile
census_tracts <- census_tracts %>% 
  group_by(poly_id) %>% 
  mutate(mean_ccc = mean(CCC, na.rm = T),
         least_freeflow = ifelse(mean_ccc <= ccc_bottom_10, 'TRUE', NA)) %>% 
  ungroup()

# 4c Convert to long format, tidy ice var names for plotting
census_tracts <- census_tracts %>%  
  pivot_longer(ice_race_quint:ice_hhincome_quint, names_to = "ice_var", 
               values_to = "ice_value") %>% 
  mutate(ice_var = case_when(
    ice_var == "ice_race_quint" ~ "Race/Ethnicity",
    ice_var == "ice_hhincome_quint" ~ "Household Income"))

# 4d Load census tracts geometry file
ct_geo <- st_read(here::here('data', 'polygons_of_interest', 'bronx_census_tracts',
                             'bronx.shp')) %>% 
  dplyr::select(geoid, geometry)

# 4e Join census tracts geometry file to main dataframe
census_tracts <- census_tracts %>% 
  left_join(ct_geo, by = c('poly_id' = 'geoid'))

# 4f Create dataframe of only the least free-flowing census tracts for plotting
least_freeflow <- census_tracts %>% 
  filter(!is.na(least_freeflow))

# 4g Create faceted chloropleth map for ICE variables and least free-flowing traffic
ice_congestion_map <- 
  ggplot() +
  geom_sf(data = census_tracts,
          aes(geometry = geometry, fill = ice_value), lwd = 0.25) +
  scale_fill_viridis_d(option = 'viridis',
                       name = '') +
  geom_sf(data = least_freeflow, color = 'black', lwd = 1,
          inherit.aes = FALSE, fill = NA, aes(geometry = geometry)) + 
  facet_grid(~ice_var) +
  theme_void() +
  theme(panel.grid = element_line(color = "transparent"),
        text = element_text(size = 20))
ice_congestion_map

# 4h Save map
tiff(here::here('outputs', 'applications', 'manuscript_fig5_ice_congestion_map.tif'),
     units = "in", width = 12, height = 7, res = 300)
ice_congestion_map
dev.off()




