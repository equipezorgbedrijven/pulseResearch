# pulseResearch

An R package for reading Pulse research data from Google Cloud Storage with authenticated access.

## Installation

You can install the package from this repository:

```r
# install.packages("devtools")
devtools::install_github("equipezorgbedrijven/pulseResearch")
```

## Environment Variables

Before using this package, you need to set up the following environment variables in your `.Renviron` file:

- `GOOGLE_CLIENT_ID`: Your Google Cloud OAuth 2.0 client ID
- `GOOGLE_CLIENT_SECRET`: Your Google Cloud OAuth 2.0 client secret

### Setting Up Environment Variables

1. Open your `.Renviron` file by running:
   ```r
   usethis::edit_r_environ()
   ```

2. Add your credentials:
   ```
   GOOGLE_CLIENT_ID="your-client-id-here"
   GOOGLE_CLIENT_SECRET="your-client-secret-here"
   ```

3. Save the file and restart your R session for the changes to take effect.

## Usage

### Authentication with `get_token()`

The `get_token()` function authenticates you with Google Cloud and returns a token for accessing Google Cloud resources.

```r
library(pulseResearch)

# Authenticate and get a token
token <- get_token()
```

This function will:
- Check that your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` are set
- Prompt you to authenticate via your web browser
- Return a token that can be used for subsequent Google Cloud operations

### Reading Files with `cloud_read()`

The `cloud_read()` function downloads and reads files from Google Cloud Storage. It supports CSV, XLSX, and RData file formats.

```r
# Read a CSV file from the default bucket
data <- cloud_read("mydata.csv")

# Read an Excel file from a specific bucket
data <- cloud_read("mydata.xlsx", bucket = "my_custom_bucket")

# Read an RData file
data <- cloud_read("mydata.Rdata")
```

**Parameters:**
- `file`: Name of the file to read (must end with `.csv`, `.xlsx`, or `.Rdata`)
- `bucket`: GCS bucket name (default: `"pulse_cloud"`)

**Returns:**
- A `data.table` containing the data from the specified file
- For RData files containing lists, returns the original structure

### Complete Example

```r
library(pulseResearch)

# Step 1: Authenticate
token <- get_token()

# Step 2: Read data from Google Cloud Storage
my_data <- cloud_read("research_data.csv", bucket = "pulse_cloud")

# Step 3: Work with your data
head(my_data)
```

## Requirements

This package requires the following R packages:
- `googleAuthR`
- `googleCloudStorageR`
- `data.table`
- `httr`
- `readxl`
