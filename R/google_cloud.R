#' Get token
#'
#' @description Get a token by logging in to Google Cloud.
#'
#' @return Token to access Google Cloud resources.
#'
#' @export
#' @importFrom googleAuthR gar_auth
get_token <- function() {
  # Set the Google client id and secret
  stopifnot(
    "Please set the GOOGLE_CLIENT_ID variable in your `.Renviron file`" =
      Sys.getenv("GOOGLE_CLIENT_ID") != "",
    "Please set the GOOGLE_CLIENT_SECRET variable in your `.Renviron file`" =
      Sys.getenv("GOOGLE_CLIENT_SECRET") != ""
  )
  options("googleAuthR.client_id" = Sys.getenv("GOOGLE_CLIENT_ID"))
  options("googleAuthR.client_secret" = Sys.getenv("GOOGLE_CLIENT_SECRET"))

  # Get token
  token <- googleAuthR::gar_auth(
    scopes = c(
      "https://www.googleapis.com/auth/cloud-platform"
    ),
    cache = FALSE
  )

  return(token)
}

#' Cloud read
#'
#' @description Download a csv, xlsx or Rdata file from Google Cloud Storage.
#'
#' @param file File name of the file to read from Google Cloud Storage. Should
#'   be a csv, xlsx or Rdata.
#' @param bucket String containing the GCS-bucket where to read the data from.
#'
#' @return Data.table containing the data of the file specified, or a list with
#'   data.tables.
#'
#' @export
#' @import data.table
#' @importFrom googleCloudStorageR gcs_get_object gcs_list_objects
#' @importFrom httr content
#' @importFrom readxl read_excel
cloud_read <- function(file, bucket = "pulse_cloud") {
  # Check whether given file exists
  objects <- googleCloudStorageR::gcs_list_objects(bucket = bucket)
  stopifnot(
    "Your file name should end with `.csv`, `.Rdata` or `.xlsx`" =
      grepl("\\.csv$|\\.rdata$|\\.xlsx$", tolower(file)),
    "This file does not exist." = file %in% objects$name
  )

  # Download and save file
  raw <- googleCloudStorageR::gcs_get_object(
    file,
    parseObject = grepl("\\.rdata$|\\.xlsx$", tolower(file)),
    bucket = bucket
  )

  # Read and convert data to data.table
  if (grepl("\\.xlsx$", tolower(file))) {
    tmp <- tempfile(fileext = '.xlsx')
    writeBin(raw, tmp)
    my_excel <- readxl::read_excel(tmp)
    data <- data.table(my_excel)
  } else if (grepl("\\.csv$", tolower(file))) {
    data <- data.table(read.csv2(text = httr::content(
      raw, as = "text", encoding = "UTF-8")
    ))
  } else if (grepl("\\.rdata$", tolower(file))) {
    tmp <- tempfile(fileext = '.Rdata')
    writeBin(raw, tmp)
    data <- readRDS(tmp)
  }

  return(data)
}
