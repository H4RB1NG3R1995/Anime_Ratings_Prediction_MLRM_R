# Anime_Ratings_Prediction_MLRM_R
To predict the Ratings received by the enlisted anime releases (Movie/Web series), by using a Multiple Linear Regression Model

Problem statement:

The objective here is to perform a Linear regression analysis to arrive at a model that can be used to predict the Ratings received by the enlisted anime releases
(Movie/Web series), such that, in future, the anime production studios can develop their strategies which can improve the ratings.

Data Dictionary:

About the dataset: This dataset comprises the scrapped information about anime releases (Movie/Web series/etc.) from anime-planet (founded in 2001), which is the
first anime & manga recommendation database. It comprises the anime & manga release logistics (Title, Description, Episodes, Duration, etc.) along with the viewer’s
response behaviour statistics (Watched, Want to watch, Watching, Votes) records from the year 2005 to 15th June, 2020.

1. rating: Average user rating given by the viewers for the anime releases.
2. title: Name of the anime releases.
3. mediaType: Format of publication of the anime releases (Web/DVD special/Movie/TV special/TV).
4. eps: Number of episodes (movies are considered 1 episode).
5. duration: Duration of each episode (in minutes).
6. Ongoing: Whether the anime is ongoing or not (Yes/No).
7. sznOfRelease: The season of release of the anime (Winter/Spring/Fall/Summer).
8. description: Synopsis of plot of the anime.
9. studios: Studios responsible for the creation of different anime.
10. tags: Tags, genres, etc. of different anime.
11. contentWarn: Content warning provided for the different anime.
12. watched: The number of users who completed watching it.
13. watching: The number of users who are watching it.
14. wantWatch: The number of users who want to watch it.
15. dropped: The number of users who dropped it before completion.
16. votes: The number of votes that contribute to the ratings received by different anime.

The dataset has 7029 observations of 16 variables.

Two additional feature engineered variables "studios_cleaned" and "Number_of_tags" were added. The first variable is the cleaned version of the variable "studios" without the special characters and the second is the number of tags an anime has, calculated from the "tags" variable.

Title, description, tags, Number_of_tags, studios and studios_cleaned are being dropped since these are qualitative variables and consist of too many unique values. So they are insignificant from a business perspective. Sznofrelease and contentwarn are dropped since the number of missing values in these two columns exceed 30% and is close to 70%. 

After conducting Pearson Correlation test between the target variable and continuous predictors, and taking the benchmark as 0.4, variables eps, duration, watching and dropped are removed from the final set of predictors.

After conducting ANOVA test between the target variable and categorical predictors, mediatype and ongoing come out as important.

Skewness test is done on the continuous predictors. Log transformations are done on those predictors for which the skewness coefficients are coming out to be greater than 1 to improve the accuracy of the final model.

The entire dataset is split into train and test datasets in 70:30 ratio.

The test results after running MLRM on the train dataset are given as follows:
1. MAPE: 19.06% and Mean Accuracy: 80.93%
2. MDAPE: 12.6% and Median Accuracy: 87.39%
3. DW test for autocorrelation: p-value = 0
4. BP test for homoscedasticity: p-value < 0.00000000000000022
5. AD test for normality: p-value < 0.00000000000000022

The test results after running MLRM on the test dataset are given as follows:
1. MAPE: 18.79% and Mean Accuracy: 81.21%
2. MDAPE: 12.39% and Median Accuracy: 87.6%
3. DW test for autocorrelation: p-value = 0
4. BP test for homoscedasticity: p-value < 0.00000000000000022
5. AD test for normality: p-value < 0.00001223

Significant variables from the test dataset:

Positively Significant: Mediatype (Movie, TV Special), Ongoing (Yes) and votes
Negatively Significant: Mediatype (Web)
