# Crowd-Sourced_Traffic_Data

In this repository, we provide scripts, tutorials, sample data, and applications for acquiring, processing, and analyzing timeseries of real-time, crowd-sourced traffic data, at varying spatial scales. 

Please see the accompanying manuscript for descriptions and details:
ADD TITLE AND AUTHORS

**TABLE OF CONTENTS**

**Scripts**

*Acquiring crowd-sourced traffic data*
1. acquisition1_Load_Traffic_Map_Array.html 
2. acquisition2_Download_Traffic_Map_Array 
3. acquisition3_Matlab stitching it together script

*Processing crowd-sourced traffic data*
1. processing1_assigning color codes etc script

*Creating a timeseries of crowd-sourced traffic data*
1. timeseries1_get_gt_agg_timeseries.R (in Rfunctions folder)
2. timeseries2_get_gt_agg_timepoint.R (in Rfunctions folder)
3. timeseries3_make_captured_datetime_vector.R (in Rfunctions folder)
4. timeseries4_reformat_datetime_vector.R (in Rfunctions folder)
5. timeseries5_two_digit_pad.R (in Rfunctions folder)
6. timeseries6_get_gt_timeseries.R (in Rfunctions folder)
7. timeseries7_get_gt_timepoint.R (in Rfunctions folder)
8. timeseries8_point_to_sf_wbuffer.R (in Rfunctions folder)

**Tutorials**
1. tutorial1_create_timeseries_trafficmaparea.R
2. tutorial2_create_timeseries_points.R
3. tutorial3_create_timeseries_polygons.R

**Applications**
1. applications1_ (in applications folder)
2. applications2_ (in applications folder)

**Data**
1. bronx_example (in data/gt_image_cat folder)
2. CCC_01_01_18__02_00.png (in data/gt_image_cat folder)
3. gt_geo_projected.tif (in data/gt_refs folder)
4. bronx_census_tracts shapefile (in data/polygons_of_interest/bronx_census_tracts folder)
5. bronx_polygons_example_timeseries.fst (in outputs/Rtutorials folder)
6. bronx_example_points (in outputs/Rtutorials folder)
7. bronx_pointswbuffer_example_timeseries.fst (in outputs/Rtutorials folder)
8. nyc_subarea_example_timeseries.fst (in outputs/Rtutorials folder)

**Documentation**
1. Rglossary

**SCRIPT DESCRIPTION**

*Acquiring crowd-sourced traffic data*

1. acquisition1_Load_Traffic_Map_Array.html 



2. acquisition2_Download_Traffic_Map_Array 



3. acquisition3_ADD TITLE 



*Processing crowd-sourced traffic data*

1. processing1_assigning color codes etc script



*Creating a timeseries of crowd-sourced traffic data*

1. timeseries1_get_gt_agg_timeseries.R (in Rfunctions folder)

This function loops function timeseries2_get_gt_agg_timepoint over all processed traffic map images (gt_image_cat filenames - see Rglossary) included in a specified vector of datetimes (captured_datetime_vector - see Rglossary), creating a timeseries of processed traffic map data aggregated by unique polygon ids (poly_id - see Rglossary) in the shapefile provided.

2. timeseries2_get_gt_agg_timepoint.R (in Rfunctions folder)

This function aggregates pixel values from processed traffic map images (gt_cat values - see Rglossary - which correspond to traffic colors and other parameters) by unique polygon ids for a single inputted datetime.

3. timeseries3_make_captured_datetime_vector.R (in Rfunctions folder)

This function creates a vector of datetimes to be included in the timeseries.

4. timeseries4_reformat_datetime_vector.R (in Rfunctions folder)

This function reformats the vector of datetimes created by analysis3_make_captured_datetime_vector.R to match the filenames of processed traffic map images (gt_image_cat files - see Rglossary).

5. timeseries5_two_digit_pad.R (in Rfunctions folder)

This function adds two zeroes to the left of the input. 

6. timeseries6_get_gt_timeseries.R (in Rfunctions folder)

This function loops function timeseries7_get_gt_timepoint over all processed traffic map images (gt_image_cat filenames - see Rglossary) included in a specified vector of datetimes (captured_datetime_vector - see Rglossary), creating a timeseries of traffic map data for the entire traffic map area.

7. timeseries7_get_gt_timepoint.R (in Rfunctions folder)

This function counts the number of pixels of each value (gt_cat values - see Rglossary - which correspond to traffic colors and other parameters) for the entire traffic map area for a single inputted datetime.

8. timeseries8_point_to_sf_wbuffer.R (in Rfunctions folder)

This function converts points given in lat/lons to a spatial features object with a buffer of size radius.deg (in decimal degrees) around each point, and assigns a user provided unique ID to each point/buffer combination.

**TUTORIAL DESCRIPTION**

1. tutorial1_create_timeseries_trafficmaparea.R

In this script we present a tutorial for creating a timeseries from processed Google Traffic images, for the entire traffic map area. As an example, we include one week of processed data for a subset of the NYC area (every 3-hrs, n=56 images). Users can edit the parameters described in the tutorial to complete their own analysis with differing traffic map areas and time periods, or can run the script as-is to recreate the dataset nyc_subarea_example_timeseries.fst. We strongly recommend users clone this repository to ensure matching with the file structure and subfolders used in this tutorial. For definitions of variables created in the timeseries output, see Rglossary.

2. tutorial2_create_timeseries_points.R

In this script we present a tutorial for creating a timeseries from processed Google Traffic images, for points specified in lat/lon with buffers of user specified radius. As an example, we include one week of processed data for a subset of the NYC area (every 3-hrs, n=56 images), and create a timeseries of three points with small buffers in the South Bronx area. Users can edit the parameters described in the tutorial to complete their own analysis with differing traffic map areas, time periods, point locations, and buffer radii, or can run the script as-is to recreate the dataset bronx_pointswbuffer_example_timeseries.fst. We strongly recommend users clone this repository to ensure matching with the file structure and subfolders used in this tutorial. For definitions of variables created in the timeseries output, see Rglossary.

3. tutorial3_create_timeseries_polygons.R

In this script we present a tutorial for creating a timeseries from processed Google Traffic images, for spatial polygons. As an example, we include one week of processed data for a subset of the NYC area (every 3-hrs, n=56 images), and create a timeseries aggregated to South Bronx census tracts. Users can edit the parameters described in the tutorial to complete their own analysis with differing traffic map areas, time periods, and spatial polygons, or can run the script as-is to recreate the dataset bronx_polygons_example_timeseries.fst. We strongly recommend users clone this repository to ensure matching with the file structure and subfolders used in this tutorial. For definitions of variables created in the timeseries output, see Rglossary.

**APPLICATION DESCRIPTION**

**DATA DESCRIPTION**
1. bronx_example (in data/gt_image_cat folder)

Folder containing one week of processed Google Traffic images for a subset of the New York City (US) area. Images were obtained every 3 hours, for a total of n=56 images. Datetimes in the file names correspond to US/Eastern timezone (including daylight savings). 

2. CCC_01_01_18__02_00.png (in data/gt_image_cat folder)

A processed Google Traffic image (gt_image_cat - see Rglossary) used in the tutorials and applications to prepare a crosswalk file between a shapefile (polygons_of_interest - see Rglossary) and a processed Google Traffic image. The datetime of the filename corresponses to Eastern Standard Time (EST).

3. gt_geo_projected.tif (in data/gt_refs folder)

A geotiff of the NYC area subset used in the tutorial. This geotiff has been georeferenced using four points and projected in WGS84.

4. bronx_census_tracts shapefile (in data/polygons_of_interest/bronx_census_tracts folder)

A shapefile of US census tracts in Bronx County of New York City (US). This shapefile was created by filtering a shapefile of all of New York City census tracts, obtained using the R package nycgeo: https://nycgeo.mattherman.info

5. bronx_polygons_example_timeseries.fst (in outputs/Rtutorials folder)

An example timeseries output from tutorial3. Each row corresponds to a unique polygon/datetime observation. In this example, polygons are census tracts. For a description of all columns in the dataset, see Rglossary. 

6. bronx_example_points (in outputs/Rtutorials folder)

An example shapefile output from tutorial2: timeseries8_point_to_sf_wbuffer, with three circular buffers created from lat/lon points.

7. bronx_pointswbuffer_example_timeseries.fst (in outputs/Rtutorials folder)

An example timeseries output from tutorial2. Each row corresponds to a unique polygon/datetime observation. In this example, polygons are circular buffers built from a lat/lon point.  

8. nyc_subarea_example_timeseries.fst (in outputs/Rtutorials folder)

An example timeseries output from tutorial1. Each row corresponds to a datetime observation, with a count of all pixel values by type in the traffic map area.

