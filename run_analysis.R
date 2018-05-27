##after manually downloading the ZIP-file, i set up two variables to quickly switch between the two subfolders
testdir <- "./UCI HAR Dataset/test"
traindir <- "./UCI HAR Dataset/train"

##loading all files in both folders with full filenames
files <- c(list.files(testdir, full.names = TRUE, pattern = ".txt"), 
           list.files(traindir, full.names = TRUE, pattern = ".txt"))

##reading all the files as tables
subject_test  <- read.table(files[[1]], header = FALSE)
x_test        <- read.table(files[[2]], header = FALSE)
y_test        <- read.table(files[[3]], header = FALSE)
subject_train <- read.table(files[[4]], header = FALSE)
x_train       <- read.table(files[[5]], header = FALSE)
y_train       <- read.table(files[[6]], header = FALSE)

##i also need the features.txt, because it contains the variable-names
features <- read.table("./UCI HAR Dataset/features.txt")

##first i am binding row-wise, creating three tables
subjects <- rbind(subject_test, subject_train)
colnames(subjects) <- "subject"
activities <- rbind(y_test, y_train)
colnames(activities) <- "activity"
x_set <- rbind(x_test, x_train)
colnames(x_set) <- features[,2]

##binding it all together column-wise
fullset <- cbind(subjects, activities, x_set)

##Only the measurements on the mean and standard deviation for each measurement are required. 
##First i set all names to lower, to ease the search
names(fullset) <- tolower(names(fullset))

##select from dplyr package returns a strange error, so i use base R subsetting with a logical vector
logical <- grepl(".*mean|.*std", names(fullset))
fullset_sub <- fullset[,logical]

##adding the subject and activity variables. Again.
fullset_sub <- cbind(fullset[,1:2], fullset_sub)

##applying the descriptive activity-names from the file activity_labels.txt
activities <- c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")
fullset_sub$activity <- factor(fullset_sub$activity)
levels(fullset_sub$activity) <- activities
                                
##now for the descriptive variable names. I remove the brackets, 
##the letter t at the beginning of every variable and the letters acc
names(fullset_sub) <- sub("\\(","",names(fullset_sub))
names(fullset_sub) <- sub("\\)","",names(fullset_sub))
names(fullset_sub) <- sub("^t","",names(fullset_sub))
names(fullset_sub) <- sub("acc","",names(fullset_sub))
                                
##finally the tidy data set with the average of each variable for each activity and each subject is created
fullset_grouped <- group_by(fullset_sub, subject, activity)
fullset_averaged <- summarize_all(fullset_grouped, mean)
View(fullset_averaged)