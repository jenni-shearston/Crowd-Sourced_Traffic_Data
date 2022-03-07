# Function: get_gt_timeseries for set of captured datetimes
# Project: Acquisition and Analysis of Crowd-Sourced Traffic Data at Varying Spatial Scales
# Script Authors: Jenni A. Shearston and Sebastian T. Rowland
# Updated: 03/07/2022

####***********************
#### Table of Contents #### 
####***********************

# N: Notes
# 1: Function to Create Google Traffic timeseries for Entire Traffic Map Area

####**************
#### N: Notes #### 
####**************

# This function loops function 0_07_get_gt_timepoint over all gt_image_cat 
# filenames included in the captured_datetime_vector, creating a timeseries of
# Google Traffic data for the entire traffic map area.

####*********************************************************************************
#### 1: Function to Create Google Traffic timeseries for Entire Traffic Map Area #### 
####*********************************************************************************

# BEGIN FUNCTION 
get_gt_agg_timeseries <- function(captured_datetime_vector_filename = datetimes_of_interest, 
                                  dir_output = 'outputs/Rtutorials', 
                                  name_output = 'your_name_here',
                                  gt_dir = gt_dir,
                                  method = 'parallel') {
  
  # OPTION 1
  # Use forloop 
  if (method == 'forloop') {
  
    # 1a Initialize a dataframe to fill
    gt_timeseries <- data.frame(captured_datetime = NA,
                                gt_pixcount_maroon = NA,
                                gt_pixcount_red= NA,
                                gt_pixcount_orange = NA,
                                gt_pixcount_green = NA,
                                gt_pixcount_gray= NA,
                                gt_pixcount_construction = NA,
                                gt_pixcount_emergency = NA,
                                gt_pixcount_notsampled = NA,
                                gt_pixcount_background = NA,
                                gt_pixcount_tot = NA)

    # 1b Collect the timeseries in a loop over each gt_image_cat filename
    for (i in 1:length(captured_datetime_vector_filename)) {
      gt_timeseries <- gt_timeseries %>%
        dplyr::bind_rows(get_gt_timepoint(
          captured_datetime_vector_filename[i],
          gt_dir))
      if (i%%50 == 0) {print(captured_datetime_vector_filename[i])}
    }
  
  # OPTION 2
  # Use parallelization
  } else if (method == 'parallel') {
    
    # 1a Set up parallelization
    # 1a.i Get the number of cores
    #      Note: We subtract one to reserve a core for other tasks
    n.cores <- parallel::detectCores() - 1
    # 1a.ii Create the cluster
    my.cluster <- parallel::makeCluster(
      n.cores, 
      type = "FORK")
    # 1a.iii Register it to be used by %dopar%
    doParallel::registerDoParallel(cl = my.cluster)
  
    #1b Collect the timeseries in parallel over each gt_image_cat filename
    gt_timeseries <- 
      foreach(
        i = 1:length(captured_datetime_vector_filename),
        .combine = 'rbind'
      ) %dopar% {
        get_gt_timepoint(captured_datetime_vector_filename[i],
                         gt_dir)
        }
     stopCluster(my.cluster)
  }
  
  # FOR EITHER OPTION
  
  # 1c Save out gt_agg_timeseries
  gt_timeseries %>% 
    dplyr::filter(!is.na(captured_datetime)) %>%
    fst::write_fst(here::here(dir_output, 
                         paste0(name_output, '.fst')))

}

# END FUNCTION 




