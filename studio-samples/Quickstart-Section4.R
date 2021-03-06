## Only one of the following two lines should be used
## If running in ML Studio use the first line with maml.mapInputPort().
## If in RStudio used the second line with read.csv()
cadairydata <- maml.mapInputPort(1)
# cadairydata  <- read.csv("cadairydata.csv", header = TRUE, stringsAsFactors = FALSE)

## Esure the coding is consistent and convert column to a factor
cadairydata$Month <- as.factor(substr(cadairydata$Month, 1, 3))

# Remove two columns we do not need
cadairydata <- cadairydata[, c(-1, -2)]

## Create a new column with the month count
## Function to find the number of months from the first
## month of the time series. 
num.month <- function(Year, Month) {
  ## Find the starting year.
  min.year  <- min(Year)
  
  ## Compute the number of months from the start of the time series.
  12 * (Year - min.year) + Month - 1
}

# Compute the new column for the dataframe. 
cadairydata$Month.Count <- num.month(cadairydata$Year, cadairydata$Month.Number)


log.transform <- function(invec, multiplier = 1) {
  ## Function for the transformation which is the log
  ## of the input value times a multiplier
  
  warningmessages <- c("ERROR: Non-numeric argument encountered in function log.transform",
                       "ERROR: Arguments to function log.transform must be greate than zero",
                       "ERROR: Aggurment multiplier to funcition log.transform must be a scaler",
                       "ERROR: Invalid time seies value encountered in function log.transform"
                       )
  
  ## Check the input arguments.
  if(!is.numeric(invec) | !is.numeric(multiplier)) {warning(warningmessages[1]); return(NA)}  
  if(any(invec < 0.0) | any(multiplier < 0.0)) {warning(warningmessages[2]); return(NA)}
  if(length(multiplier) != 1) {{warning(warningmessages[3]); return(NA)}}
  
  ## Wrap the multiplication in tryCatch.
  ## If there is an exception, print the warningmessage to
  ## standard error and return NA.
  tryCatch(log(multiplier * invec), 
           error = function(e){warning(warningmessages[4]); NA})
}

 
## Apply the transformation function to the 4 columns
## of the dataframe with production data. 
multipliers  <- list(1.0, 6.5, 1000.0, 1000.0)
cadairydata[, 4:7] <- Map(log.transform, cadairydata[, 4:7], multipliers)

## Get rid of any rows with NA values
cadairydata <- na.omit(cadairydata)  

str(cadairydata) # Check the results

## The following line should be executed only when running in
## Azure ML Studio. 
maml.mapOutputPort('cadairydata') 

