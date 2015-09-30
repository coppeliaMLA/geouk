#' Reads in and validates data for geoukr
#'
#' @param file The path and filename of a csv file
#' @param sep The column separator
#' @return Returns a data frame, with validated geo locations and dates converted into the R date class
#' @author Simon Raper
#' @export

read_in_geouk<-function(file, sep){

  in_file <- read.csv(file, stringsAsFactors=FALSE, sep=sep)

  data(admin_geo_hierarchy)

  #List of valid column names

  valid_date_cols<-c("date", "start_of_week", "start_of_month")

  valid_geo_cols<-names(admin_geo_hierarchy)

  #Find columns for joining

  in_file_names<-names(in_file)

  matching<-intersect(in_file_names, c(valid_date_cols, valid_geo_cols))

  if (length(matching)>0) {
    print("The following columms are correctly named for joining")
    print(matching)
  }
  else {
    print("No columns are correctly named for joining")
  }

  #Convert date columns

  for (d in valid_date_cols){
    if (d %in% matching) {
      options(show.error.messages = FALSE)
      result<-try(in_file[,d]<-as.Date(in_file[,d]))
      if (class(result) == "try-error" || is.na(result) ) {print("Your date data is in an incorrect format")}
      options(show.error.messages = TRUE)
    }

  }

  #Validate geographical columns

  #return data

  return(in_file)

}
