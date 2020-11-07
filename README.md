# NYC Flights Data 2013-Analysis

Analyzing NYC Flights data 2013 using various statistical and visualization tools, the project majorly hovers around the delay statistics with a nuanced intervention into nearly all the possible factors. The project uses SAS and R Programming for analysis of the data on statistical grounds, while using advanced visualization extensions available in R to produce visual evidences of the results found.

The project attempts to propose a model to predict the arrival and departure delays considering various factors ranging from the weather conditions to the manufactural details of the aircraft. We categorize the delay in certain intevals of the duration and fit a logistic regression model to classify the given set of features into one of those categories. The predictions obtained by the model are approximately 70% accurate on validation data and opens the doors for further research. 


The sequential stages of the project are summarized as follows:

1. Exploratory Data Analysis: We start with exploring the statistical aspects of the data in both univariate and multivariate settings. This includes identifying the missing values in the data followed by the outlier detection by identifying highly influential data points that lie away from the distribution of the data.
2. Data Cleaning and preparation: Evaluating the feasibility of imputations of the missing values using the general and contextual understanding of the data with an objective to minimze the contamination of the data with noise. On the basis of the evaluation metrics, we impute the data and deal with the unusual observations (potential outliers).
3. Diagnostic Analysis: Here, we use visualization tools to understand the key aspects of the data.
4. Predictive Analysis: This is the data modelling stage where we predict the departure delay and use the standard inferential statistics to interpret the results obtained.
