#Problem Statement: To develop a Multiple Linear Regression Model that can be used 
#to predict the Ratings received by the enlisted anime releases (Movie/Web series) from 2005 to 2020, 
#such that, in future, the anime production studios can develop their strategies 
#which can improve the ratings.

#Here the dependent variable is "rating" which we have to predict via MLRM.

#Two new columns called "studios_cleaned" and "Number of Tags" were created in Excel. The first column contains the 
#names of the studios excluding the special characters and the second column contains the number of unique
#tags of each anime. They were feature engineered from "studios" and "tags" respectively.


#Preparing the environment for MLRM
install.packages("DataExplorer", dependencies = TRUE)

#Calling the packages
library(boot) 
library(car)
library(QuantPsyc)
library(lmtest)
library(sandwich)
library(vars)
library(nortest)
library(MASS)
library(caTools)
library(dplyr)
library(ggplot2)
library(pastecs)
library(DataExplorer)
library(e1071)
options(scipen=999)

#Creating mode function
Mode = function(x){
  ta = table(x)
  tam = max(ta)
  if (all(ta == tam))
    mod = NA
  else
    if(is.numeric(x))
      mod = as.numeric(names(ta)[ta == tam])
  else
    mod = names(ta)[ta == tam]
  return(mod)
}

#Setting working directory
Path<-"E:/IVY PRO SCHOOL/Internship Resources/R"
setwd(Path)
getwd()

data=read.csv("Anime_Final.csv")
data1=data #To create a backup of original data

#Basic Exploration of the data
str(data1)
summary(data1)
dim(data1)
plot_str(data1)

#title: character(qualitative)
#mediaType: character(categorical)
#ongoing: character(categorical)
#sznofRelease: character(categorical)
#description: character(qualitative)
#studios: character(categorical)
#contentWarn: character(qualitative)
#All the other variables are numeric(quantitative) in nature

#Replacing blank spaces in the dataset with "NA"
data1[data1==""]<-NA

#Missing values Identification and Treatment
as.data.frame(colSums(is.na(data1)))

#Identifying predictor variables

#Dropping title, description, studios, sznofrelease, contentwarn, tags

#Title, description, tags and Number_of_tags are being dropped since these are qualitative variables 
#and consist of too many unique values. So they are insignificant from a business
#perspective.

#studios is dropped because there is a calculated column called studios_cleaned which are 
#cleaned names of the studios

#sznofrelease and contentwarn are dropped since the number of missing values in these two columns
#exceed 30% and is close to 70%

data2=select(data1,-c(title, description, studios, tags, sznOfRelease, contentWarn, Number_of_tags))

as.data.frame(colSums(is.na(data2)))

#imputing missing values with median in "duration" and "watched" since the percentage of missing values 
#is lower than 30%
data2[is.na(data2$duration),"duration"]=round(median(data2$duration,na.rm=T),0)
data2[is.na(data2$watched),"watched"]=round(median(data2$watched,na.rm=T),0)

#imputing missing values with mode in mediaType and studios_cleaned 
data2[is.na(data2$mediaType),"mediaType"]=Mode(data2$mediaType)
data2[is.na(data2$studios_cleaned),"studios_cleaned"]=Mode(data2$studios_cleaned)

#converting relevant variables to factor variables
names<-c("mediaType","ongoing","studios_cleaned")   
data2[,names]<-lapply(data2[,names], factor)


#outlier treatment of continuous variables
summary(data2)
str(data2)

boxplot(data2$eps, horizontal = T)
quantiles1=quantile(data2$eps,c(0.95,0.96,0.963,0.965,0.97,0.98,0.99,0.995,1))
quantiles1
max(data2$eps)
quantiles_final1=quantile(data2$eps,0.995)
quantiles_final1
data2$eps = ifelse(data2$eps > quantiles_final1 , quantiles_final1, data2$eps)

boxplot(data2$duration, horizontal = T)
quantiles2=quantile(data2$duration,c(0.95,0.96,0.963,0.965,0.97,0.98,0.99,0.995,0.996,0.997,0.998,0.999,0.9991,0.9992,0.9993,0.9994,0.9995,0.9996,0.9997,0.9998,0.9999,1))
quantiles2
max(data2$duration)
quantiles_final2=quantile(data2$duration,0.9992)
quantiles_final2
data2$duration = ifelse(data2$duration > quantiles_final2 , quantiles_final2, data2$duration)

boxplot(data2$watched, horizontal = T)
quantiles3=quantile(data2$watched,c(0.95,0.96,0.963,0.965,0.97,0.98,0.99,0.995,0.996,0.997,0.998,0.999,0.9991,0.9992,0.9993,0.9994,0.9995,0.9996,0.9997,0.9998,0.9999,1))
quantiles3
max(data2$watched)
quantiles_final3=quantile(data2$watched,0.9993)
quantiles_final3
data2$watched = ifelse(data2$watched > quantiles_final3 , quantiles_final3, data2$watched)

boxplot(data2$watching, horizontal = T)
quantiles4=quantile(data2$watching,c(0.95,0.96,0.963,0.965,0.97,0.98,0.99,0.995,0.996,0.997,0.998,0.999,0.9991,0.9992,0.9993,0.9994,0.9995,0.9996,0.9997,0.9998,0.9999,1))
quantiles4
max(data2$watching)
quantiles_final4=quantile(data2$watching,0.996)
quantiles_final4
data2$watching = ifelse(data2$watching > quantiles_final4 , quantiles_final4, data2$watching)


boxplot(data2$wantWatch, horizontal = T)
quantiles5=quantile(data2$wantWatch,c(0.95,0.96,0.963,0.965,0.97,0.98,0.99,0.995,0.996,0.997,0.998,0.999,0.9991,0.9992,0.9993,0.9994,0.9995,0.9996,0.9997,0.9998,0.9999,1))
quantiles5
max(data2$wantWatch)
quantiles_final5=quantile(data2$wantWatch,0.9994)
quantiles_final5
data2$wantWatch = ifelse(data2$wantWatch > quantiles_final5 , quantiles_final5, data2$wantWatch)

boxplot(data2$dropped, horizontal = T)
quantiles6=quantile(data2$dropped,c(0.95,0.96,0.963,0.965,0.97,0.98,0.99,0.995,0.996,0.997,0.998,0.999,0.9991,0.9992,0.9993,0.9994,0.9995,0.9996,0.9997,0.9998,0.9999,1))
quantiles6
max(data2$dropped)
quantiles_final6=quantile(data2$dropped,0.998)
quantiles_final6
data2$dropped = ifelse(data2$dropped > quantiles_final6 , quantiles_final6, data2$dropped)

boxplot(data2$votes, horizontal = T)
quantiles7=quantile(data2$votes,c(0.95,0.96,0.963,0.965,0.97,0.98,0.99,0.995,0.996,0.997,0.998,0.999,0.9991,0.9992,0.9993,0.9994,0.9995,0.9996,0.9997,0.9998,0.9999,1))
quantiles7
max(data2$votes)
quantiles_final7=quantile(data2$votes,0.996)
quantiles_final7
data2$votes = ifelse(data2$votes > quantiles_final7 , quantiles_final7, data2$votes)

boxplot(data2$eps, horizontal = T)
boxplot(data2$duration, horizontal = T)
boxplot(data2$watched, horizontal = T)
boxplot(data2$watching, horizontal = T)
boxplot(data2$wantWatch, horizontal = T)
boxplot(data2$dropped, horizontal = T)
boxplot(data2$votes, horizontal = T)

summary(data2)
str(data2)

#Univariate and Bivariate analysis
plot_str(data2) #plot of continuous and categorical variables
plot_missing(data2) #missing value plot of data frame

#Quantitative analysis of the predictors
str(data2) #the data has 4 factor variables and all others are numerical variables
summary(data2) 
dim(data2) #the data has 7029 rows and 12 columns
head(data2, n=10)
tail(data2, n=10)
as.data.frame(stat.desc(data2))

#Univariate Visual analysis
plot_histogram(data2) #histogram
plot_density(data2) #density plot
plot_bar(data2) #bar plot for categorical variables

#Bivariate visual analysis (Correlation analysis)
plot_correlation(data2, type = "continuous") #for continuous variables
plot_bar(data2, with = "watched") #for categorical variables
plot_bar(data2, with = "watching")
plot_bar(data2, with = "wantWatch")
plot_bar(data2, with = "dropped")
plot_bar(data2, with = "votes")
plot_bar(data2, with = "rating")

#Correlation test between continuous independent and continuous dependent variables
cor.test(data2$rating,data2$eps, method = "pearson") #cor=0.17
cor.test(data2$rating,data2$duration, method = "pearson") #cor=0.28
cor.test(data2$rating,data2$watched, method = "pearson") #cor=0.43
cor.test(data2$rating,data2$watching, method = "pearson") #cor=0.39
cor.test(data2$rating,data2$wantWatch, method = "pearson") #cor=0.55
cor.test(data2$rating,data2$dropped, method = "pearson") #cor=0.34
cor.test(data2$rating,data2$votes, method = "pearson") #cor=0.44

#ANOVA test between categorical independent and continuous dependent variables
aov1<-aov(rating~mediaType, data=data2)
summary(aov1) #since p value is very low, so mediaType has a real impact on ratings
aov2<-aov(rating~ongoing, data=data2)
summary(aov2) #since p value is very low, so ongoing has a real impact on ratings
aov3<-aov(rating~studios_cleaned, data=data2)
summary(aov3) #since p value is very low, so studios_cleaned has a real impact on ratings

#Dropping studios_cleaned from the final set of predictors since the first variable has too many unique levels
#and considered to be a qualitative column. Taking correlation coefficient benchmark as
#0.4, dropping eps, duration, watching and dropped from the final set of predictors.
data3=select(data2, -c(studios_cleaned, eps, duration, watching, dropped))
str(data3)

#checking skewness of the continuous final set of predictors:
skewness(data3$watched) #skewness=2.123705 (high)
skewness(data3$wantWatch) #skewness=1.848259 (high)
skewness(data3$votes) #skewness=2.187035 (high)


#Taking a backup of data3 to another dataframe:
data4<-data3

#Replacing 0's in the continuous predictors with the next positive value i.e. 1
data4[data4$watched==0, "watched"]<-1
data4[data4$wantWatch==0, "wantWatch"]<-1
data4[data4$votes==0, "votes"]<-1

#Taking log transformations of the highly skewed variables:
data4$watched<-log(data4$watched)
data4$wantWatch<-log(data4$wantWatch)
data4$votes<-log(data4$votes)

#Skewness of log transformed variables:
skewness(data4$watched)
skewness(data4$wantWatch)
skewness(data4$votes)

#Splitting the data into train and test datasets:

set.seed(156)#This is used to produce reproducible results, everytime we run the model

spl = sample.split(data4, 0.7)#Splits the overall data into train and test data in 70:30 ratio

train = subset(data4, spl == TRUE)
str(train)
dim(train)

test = subset(data4, spl == FALSE)
str(test)
dim(test)

#Building the MLRM Model

#Iteration 1: Running on all final variables
trainmodel0<-lm(rating~., data = train)
summary(trainmodel0)

#Iteration 2: Fixing mediatype classes and dropping other
trainmodel1<-lm(rating~I(mediaType=="Movie")+I(mediaType=="Music Video")+I(mediaType=="OVA")+I(mediaType=="TV")+I(mediaType=="TV Special")+I(mediaType=="Web")+ongoing+watched+wantWatch+votes, data = train)
summary(trainmodel1) 

#Iteration 3: Fixing mediatype classes and dropping OVA
trainmodel2<-lm(rating~I(mediaType=="Movie")+I(mediaType=="Music Video")+I(mediaType=="TV")+I(mediaType=="TV Special")+I(mediaType=="Web")+ongoing+watched+wantWatch+votes, data = train)
summary(trainmodel2) 

#Iteration 4: dropping watched
trainmodel3<-lm(rating~I(mediaType=="Movie")+I(mediaType=="Music Video")+I(mediaType=="TV")+I(mediaType=="TV Special")+I(mediaType=="Web")+ongoing+wantWatch+votes, data = train)
summary(trainmodel3) 

#Checking Multicollinearity
as.data.frame(vif(trainmodel3))

#Iteration 5: dropping wantwatch VIF=11.374642
trainmodel4<-lm(rating~I(mediaType=="Movie")+I(mediaType=="Music Video")+I(mediaType=="TV")+I(mediaType=="TV Special")+I(mediaType=="Web")+ongoing+votes, data = train)
summary(trainmodel4) 

#Checking Multicollinearity
as.data.frame(vif(trainmodel4))

#Iteration 6: dropping mediatype = Music Video
trainmodel5<-lm(rating~I(mediaType=="Movie")+I(mediaType=="TV")+I(mediaType=="TV Special")+I(mediaType=="Web")+ongoing+votes, data = train)
summary(trainmodel5) 

#Checking Multicollinearity
as.data.frame(vif(trainmodel5))

#Getting predicted values
fitted(trainmodel5)

#Calculating MeanAPE for train data
train$pred <- fitted(trainmodel5)
train$lm_ape<-100*(abs((train$rating-train$pred)/train$rating))
MAPE1<-print(mean(train$lm_ape))
#MAPE for train dataset = 19.06%

#Mean Accuracy for train data
MAC1<-print(100-MAPE1) #MAC1=80.93%

#Calculating MedianAPE for train data
MDAPE1<-print(median(train$lm_ape))
#MDAPE for train dataset = 12.6%

#Median Accuracy for train data
MDAC1<-print(100-MDAPE1) #MDAC1=87.39%

#Checking Assumptions

#Autocorrelation
dwt(trainmodel5) #p-value=0

#Homoscedasticity (BP test)
bptest(trainmodel5) #p-value < 0.00000000000000022

## Normality testing (AD test)
resids1 <- trainmodel5$residuals
ad.test(resids1) #p-value < 0.00000000000000022


#Building the MLRM model on test data

#Iteration 1: Running the model on test data with the predictors found from trainmodel5
fit1<-lm(rating~I(mediaType=="Movie")+I(mediaType=="TV")+I(mediaType=="TV Special")+I(mediaType=="Web")+ongoing+votes, data = test)
summary(fit1)

#Iteration 2: Dropping mediatype TV
fit2<-lm(rating~I(mediaType=="Movie")+I(mediaType=="TV Special")+I(mediaType=="Web")+ongoing+votes, data = test)
summary(fit2)

#Checking vif
as.data.frame(vif(fit2))

#Calculating MeanAPE for test data
test$pred <- fitted(fit2)
test$lm_ape<-100*(abs((test$rating-test$pred)/test$rating))
MAPE2<-print(mean(test$lm_ape))
#MeanAPE for test dataset = 18.79%

#Mean Accuracy for test data
MAC2<-print(100-MAPE2) #MAC2=81.21%

#Calculating MedianAPE for test data
MDAPE2<-print(median(test$lm_ape))
#MedianAPE for test dataset = 12.39%

#Median Accuracy for test data
MDAC2<-print(100-MDAPE2) #MDAC2=87.6%

#Checking Assumptions

#Autocorrelation
dwt(fit2) #p-value=0

#Homoscedasticity (BP test)
bptest(fit2) #p-value < 0.00000000000000022

## Normality testing (AD test)
resids <- fit2$residuals
ad.test(resids) #p-value < 0.00001223