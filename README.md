# Crowd-Sourced_Traffic_Data

In this repository, we provide scripts, tutorials, sample data, and applications for acquiring, processing, and analyzing time series of real-time, crowd-sensed traffic data, at user-specified spatial scales. 

Please see the accompanying manuscript for descriptions and details:
ADD AUTHORS. A reproducible method for acquisition, processing, and analysis of crowd-sensed traffic data at user-specified spatial scales. 

**TABLE OF CONTENTS**

**Method Scripts**

*Acquiring crowd-sensed traffic data (acquisition folder)*
1. Load_Traffic_Map.html
2. Download_Traffic_Map_Array 
3. Load_Traffic_Map_Array.m

*Image segmentation of crowd-sensed traffic data (image_segmentation folder)*
1. Determine_ActiveStreets.m 
2. Analyze_Time_Series.m 
3. View_CCC.m 

*Creating a time series of crowd-sensed traffic data (areal_timeseries folder)*
1. tutorial_create_timeseries_polygons.R
1. timeseries1_get_gt_agg_timeseries.R (in Rfunctions folder)
2. timeseries2_get_gt_agg_timepoint.R (in Rfunctions folder)
3. timeseries3_make_captured_datetime_vector.R (in Rfunctions folder)
4. timeseries4_reformat_datetime_vector.R (in Rfunctions folder)
5. timeseries5_two_digit_pad.R (in Rfunctions folder)
6. timeseries6_create_polygon_matrix.R (in Rfunctions folder)

**Applications (applications folder)**
1. application1_roadsegs_diurnal_traffic.R 
2. application2_traffic_covid_censustracts.R 

**Data**
1. census_hhincome_nation.csv (in data/census folder)
2. census_hhincome_tracts.csv (in data/census folder)
3. census_race_ethnicity_tracts.csv (in data/census folder)
4. bronx_example (in data/gt_image_cat folder)
5. CCC_01_01_18__02_00.png (in data/gt_image_cat folder)
6. gt_geo_projected.tif (in data/gt_refs folder)
7. bronx_3_street_segments_buffered shapefile (in data/polygons_of_interest/bronx_3_street_segments_buffered folder)
8. bronx_census_tracts shapefile (in data/polygons_of_interest/bronx_census_tracts folder)
9. manuscript_fig4_road_segs_timeplot.tif (in outputs/applications folder)
10. manuscript_fig5_ice_congestion_map.tif (in outputs/aplications folder)
11. bronx_polygons_example_timeseries.fst (in outputs/areal_timeseries_tutorial folder)
12. bronx_streetsegs_example_timeseries.fst (in outputs/areal_timeseries_tutorial folder)

**Documentation**
1. Rglossary

**METHOD SCRIPTS DESCRIPTION**

*Acquiring crowd-sensed traffic data*

1. Load_Traffic_Map.html 

HTML script for displaying a traffic map of arbitrary coordinates and zoom level for debugging scripts and defining the region of interest.

2. Download_Traffic_Map_Array 

C shell script for downloading an array of traffic maps and saving them to image (png) files.

3. Load_Traffic_Map_Array.m

Matlab script for stitching together individual traffic map tiles into one image to display them on a computer monitor and confirm the download covered the region of interest. 

*Image segmentation of crowd-sensed traffic data*

1. Determine_ActiveStreets.m 

Matlab script for determining the active street network in the region of interest.

2. Analyze_Time_Series.m 

Matlab script for performing image segmentation and assigning CCC values for each downloaded image. 

3. View_CCC.m 

Matlab script containing code for mapping colors to a segmented traffic image (gt_image_cat) to view it.

*Creating a time series of crowd-sensed traffic data*

1. tutorial_create_timeseries_polygons.R

In this script we present a tutorial for creating a time series from segmented Google Traffic images, for spatial polygons. As an example, we include eight days of segmented data for a subset of the NYC area (the South Bronx, every 3-hrs, n=64 images), and create a time series aggregated to South Bronx census tracts. Users can edit the parameters described in the tutorial to complete their own analysis with differing regions of interest, time periods, and spatial polygons, or can run the script as-is to recreate the dataset bronx_polygons_example_timeseries.fst. We strongly recommend users clone this repository to ensure matching with the file structure and subfolders used in this tutorial. For definitions of variables created in the time series output, see Rglossary.

2. timeseries1_get_gt_agg_timeseries.R (in Rfunctions folder)

This function loops function timeseries2_get_gt_agg_timepoint over all segmented traffic map images (gt_image_cat filenames - see Rglossary) included in a specified vector of datetimes (captured_datetime_vector - see Rglossary), creating a time series of segmented traffic map data aggregated by unique polygon ids (poly_id - see Rglossary) in the shapefile provided.

3. timeseries2_get_gt_agg_timepoint.R (in Rfunctions folder)

This function aggregates pixel values from segmented traffic map images (gt_cat values - see Rglossary - which correspond to traffic colors and other parameters) by unique polygon ids for a single inputted datetime.

4. timeseries3_make_captured_datetime_vector.R (in Rfunctions folder)

This function creates a vector of datetimes to be included in the time series.

5. timeseries4_reformat_datetime_vector.R (in Rfunctions folder)

This function reformats the vector of datetimes created by analysis3_make_captured_datetime_vector.R to match the filenames of segmented traffic map images (gt_image_cat files - see Rglossary).

6. timeseries5_two_digit_pad.R (in Rfunctions folder)

This function adds two zeroes to the left of the input. 

7. timeseries6_create_polygon_matrix.R (in Rfunctions folder)

This function converts a polygon shapefile (polygons of interest) to a matrix with the dimensions and resolution of a matrix of a traffic image (gt_image_cat), and both writes and outputs the matrix to an R object called poly_matrix.

**APPLICATION DESCRIPTION**

1. application1_roadsegs_diurnal_traffic.R 

In this application we include code for reproducing the diurnal road segment application described in the accompanying manuscript (Section 6.2 of the manuscript). We describe diurnal patterns in CCC in three street segment polygons in the South Bronx of New York City (US). All data for replicating the analysis is included in this repository.  

2. application2_traffic_covid_censustracts.R

In this application we include code for reproducing the census tract application described in the accompanying manuscript (Section 6.3 of the manuscript). We compare the percent free-flowing traffic in census tracts in the South Bronx of New York City (US), before and after the announcement of COVID-19 related stay-at-home orders. We also separate analyses by quintile of census tract level household income and race/ethnicity. All data for replicating the analysis are included in this repository.

**DATA DESCRIPTION**
1. census_hhincome_nation.csv (in data/census folder)

American Community Survey, 5 year averages, 2015-2019, containing estimates and margin of errors for US national household income quintile upper limits (whole nation). Obtained from NHGIS.
Citation: Steven Manson, Jonathan Schroeder, David Van Riper, Tracy Kugler, and Steven Ruggles. 
          IPUMS National Historical Geographic Information System: Version 16.0 
          [dataset]. Minneapolis, MN: IPUMS. 2021. 
          http://doi.org/10.18128/D050.V16.0

2. census_hhincome_tracts.csv (in data/census folder)

American Community Survey, 5 year averages, 2015-2019, containing estimates and margin of errors for census tract level household income in the past 12 months (in 2019 inflation-adjusted dollars). Obtained from NHGIS.
Citation: Steven Manson, Jonathan Schroeder, David Van Riper, Tracy Kugler, and Steven Ruggles. 
          IPUMS National Historical Geographic Information System: Version 16.0 
          [dataset]. Minneapolis, MN: IPUMS. 2021. 
          http://doi.org/10.18128/D050.V16.0

3. census_race_ethnicity_tracts.csv (in data/census folder)

American Community Survey, 5 year averages, 2015-2019, containing estimates and margin of errors for US census tract level population race/ethnicity. Obtained from NHGIS.
Citation: Steven Manson, Jonathan Schroeder, David Van Riper, Tracy Kugler, and Steven Ruggles. 
          IPUMS National Historical Geographic Information System: Version 16.0 
          [dataset]. Minneapolis, MN: IPUMS. 2021. 
          http://doi.org/10.18128/D050.V16.0

4. bronx_example (in data/gt_image_cat folder)

Folder containing eight days of processed Google Traffic images for a subset of the New York City (US) area (the South Bronx). Images were obtained every 3 hours, for a total of n=64 images. Datetimes in the file names correspond to US/Eastern timezone (including daylight savings). 

5. CCC_01_01_18__02_00.png (in data/gt_image_cat folder)

A processed Google Traffic image (gt_image_cat - see Rglossary) used in the tutorials and applications to prepare a crosswalk file between a shapefile (polygons_of_interest - see Rglossary) and a processed Google Traffic image. The datetime of the filename corresponses to Eastern Standard Time (EST).

6. gt_geo_projected.tif (in data/gt_refs folder)

A geotiff of the NYC area subset used in the tutorial. This geotiff has been georeferenced using four points and projected in WGS84.

7. bronx_3_street_segments_buffered shapefile (in data/polygons_of_interest/bronx_3_street_segments_buffered folder)

A shapefile containing polygons for three street segments in the South Bronx. This shapefile was made by creating 0.00015 decimal degree buffers around three selected street segments on a city-issued street centerline shapefile.

8. bronx_census_tracts shapefile (in data/polygons_of_interest/bronx_census_tracts folder)

A shapefile of US census tracts in Bronx County of New York City (US). This shapefile was created by filtering a shapefile of all of New York City census tracts, obtained using the R package nycgeo: https://nycgeo.mattherman.info

9. manuscript_fig4_road_segs_diurnalplot.tif (in outputs/applications folder)

Figure 4 in the accompanying manuscript: diurnal pattern of congestion color code (CCC) for three road segments in the South Bronx: Site A, an interstate off-ramp; Site B, a small one-way street; and Site C, a two-way road, on March 17. Line colors indicate the color of the road segments displayed in the traffic congestion maps. Lower values represent decreased speed and increased congestion.

10. manuscript_fig5_ice_congestion_map.tif (in outputs/aplications folder)

Figure 5 in the accompanying manuscript: map showing the index of concentration at the extremes for household income (left panel) and race/ethnicity (right panel) for census tracts in the South Bronx of New York City. Colors indicate relative level of privilege, with dark purple indicating least privilege and yellow indicating most privilege. For household income, households with income of $24,999 or less were set as the least privileged group, while households with income of $125,000 or more were set as the most privileged group. For race/ethnicity, Non-Hispanic Black race/ethnicity was set as the least privileged group, while Non-Hispanic White race/ethnicity was set as the most privileged group. Census tracts outlined in black fell in the 10th percentile of mean free-flowing traffic from March 17 to March 24, 2020, i.e., the census tracts with the least proportion of mean free-flowing traffic during this time period. 

11. bronx_polygons_example_timeseries.fst (in outputs/Rtutorials folder)

An example time series output from the tutorial for the South Bronx area of New York City, for March 17 to March 24, 2020. Each row corresponds to a unique polygon/datetime observation. In this example, polygons are census tracts. For a description of all columns in the dataset, see Rglossary. 

12. bronx_streetsegs_example_timeseries.fst (in outputs/Rtutorials folder)

A time series output created using the tutorial, with the polygon shapefile input 'bronx_3_street_segments_buffered', for March 17 to March 24, 2020. Each row corresponds to a unique polygon/datetime observation. In this example, polygons are (3) street segments. For a description of all columns in the dataset, see Rglossary. 
