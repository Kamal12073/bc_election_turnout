# author: Chad Neald
# date: 2020-11-19

"This script downloads data from one or more url links and saves it to a given file path.
The file path can be an absolute path or a relative path, but it should not include the
ending file name. The file name will come from the base name of the url link itself.
Usage: src/download_data.R <url_list>... --path=<path>

Options:
<url_list>...               Takes one or more space separated urls to a downloadable 
                            csv file. At least one url is required.

--path=<path>               Takes a path to where the data should be saved.
                            This can be a relative or an absolute path, but it should
                            not include the file name. The downloaded files will be
                            named according to the basename of the url. If the path
                            does not exist, it will be automatically created.
                            This is a required argument.
" -> doc

library(tidyverse)
library(here)
library(docopt)
library(httr)
library(testthat)

opt <- docopt(doc)

main <- function(url_list, path){
  
  # If the directory does not exist it will be created
  # If the directory does exist, a message will be output and the script will continue
  dir.create(here(path), recursive = TRUE)
  
  # Download data for each url in the list
  for (i in seq_along(url_list)){
    
    # Check if the url ends in .csv
    if(!str_detect(url_list[[i]], "\\.csv$")){
      stop(paste("Error. The following url does not end in .csv: ", url_list[[i]]))
    }
    
    status = HEAD(url_list[[i]])
    
    # Check if the url resolves to a successful connection
    if(status$status_code != 200){
      stop(paste("Error with the following url: ", url_list[[i]]))
    }
   
    
    # Check if the file already exists on the system
    filename <- here(path, basename(url_list[[i]]))
    if(file.exists(filename)){
      print(paste("File ", filename, " already exists. Skipping download."))      
    } else{
      download.file(url_list[[i]], filename, quiet = TRUE, mode = "wb")
    }
  }
}


main(opt$url_list, opt$path)
