# This script creates a data.frame for sharing 


# /* 
# ----------------------------- Setting up ---------------------------
# */
######################################################
# Path to parent folder ratingStudy
path2parent <- "C:/Users/Alex/Documents/GitHub/ratingStudy" # This need to be changed to run this document
######################################################

# Set wd
setwd(path2parent)

# /* 
# ----------------------------- Load raw data ---------------------------
# */
# Prepare
subNo           <- 1:6
N               <- length(subNo)
locationRatings <- array(data = NA, dim = c(20, 20, N))
objectRatings   <- matrix(NA, 20, N)

# Sequentially loading data
for(i in 1:N){
  locationRatings[,,i] <- matrix(scan(paste0(path2parent, '/normativeData/locationRatings_', as.character(subNo[i]) ,'.dat')), byrow = TRUE, ncol = 20)
  objectRatings[,i]    <- scan(paste0(path2parent, '/normativeData/objectRatings_', as.character(subNo[i]) ,'.dat'))
}

# Shuffle to anonymise the data
shuffle         <- sample(1:N)
locationRatings <- locationRatings[,,shuffle]
objectRatings   <- objectRatings[,shuffle]


objectNames <- c('microwave','kitchen roll','saucepan', 'toaster','fruit bowl','tea pot','knife','mixer','bread','glass jug','mug','dishes','towels','toy','pile of books','umbrella','hat','helmet','calendar','fan')

# /* 
# ----------------------------- Create DF---------------------------
# */
# Calculate metrics
averageLocationRatings <- apply(locationRatings, 1:2, mean)
sdLocationRatings      <- apply(locationRatings, 1:2, sd)
averageObjectRatings   <- apply(objectRatings, 1, mean)
sdObjectRatings        <- apply(objectRatings, 1, sd)

# DF that includes everything at once
ratings4allObjects <- data.frame(fileNam = paste0(rep(1:20, 20), '_', rep(1:20, each = 20), '.png'),
                                 objNam  = rep(factor(1:20, labels = objectNames), 20),
                                 objNum  = rep(1:20, 20),
                                 location = rep(1:20, each = 20),
                                 objLocRating_avg = c(averageLocationRatings),
                                 objLocRating_SD  = c(sdLocationRatings),
                                 objRating_avg    = rep(averageObjectRatings, 20),
                                 objRating_SD     = rep(sdObjectRatings, 20))

# /* 
# ----------------------------- Legend ---------------------------
# */
# Legend for ratings4allObjects
# fileNam          = File name (e.g. 1_10.png) is object 1 (microwave) at location 10.
# objNam           = Object name.
# objNum           = Object number. 
# location         = Location in the environment. 
# objLocRating_avg = Average rating for the question "How expected is that object in that location?"
# objLocRating_SD  = Standard deviation of rating for the question "How expected is that object in that location?"
# objRating_avg    = Average rating for the question "How expected is that object in general in the kitchen?"
# objRating_SD     = Standard deviation of rating for the question "How expected is that object in general in the kitchen?"

# /* 
# ----------------------------- Write files ---------------------------
# */
# .RData file
save('ratings4allObjects', file ='ratingStudy_data.RData')

# .txt file
write.table(ratings4allObjects, file ='ratingStudy_data.txt', quote = FALSE, sep = '\t', row.names = FALSE)