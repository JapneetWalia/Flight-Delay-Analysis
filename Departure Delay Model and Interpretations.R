library(ISLR)
library(MASS)
library(tidyverse)
library(lubridate)

load("St662 Project imputed.RData")




# Merging weather and planes data with flights_model

weather$weather_id<-nrow(weather)
planes$planes_id<-nrow(planes)

fl_we <- flights_model %>% left_join(weather[,c(1,6:16)], c("origin","time_hour"))
fl_we_pl <- fl_we %>% left_join(planes, by =  "tailnum")

## delete those observations which can not merger from weather or planes dataset.
fl_we_pl<-fl_we_pl%>%
  filter(is.na(planes_id)!=1,is.na(weather_id)!=1)

sum(is.na(fl_we_pl$planes_id))
sum(is.na(fl_we_pl$weather_id))


# define the 'delay' is those flights delay more than 15 minutes.
fl_model<-fl_we_pl%>%
  mutate(flag=ifelse(dep_delay<=15,0,1))


table(fl_model$flag)/nrow(fl_model)  # delay reat of flights is 21.72%    


# calculate  variables (planes_age, dep_hour) for making model

data_model<-fl_model%>%
  mutate(planes_age=ifelse((2013-year.y)>30,30,(2013-year.y)),
         dep_hour=as.numeric(ifelse(nchar(sched_dep_time)==4,substr(sched_dep_time,1,2),substr(sched_dep_time,1,1))),
  )%>%
  dplyr::select(flag,month,dep_hour,carrier,origin,planes_age,seats,
         temp,dewp,humid,wind_dir,wind_speed,pressure,visib,precip)%>%
  filter(is.na(planes_age)!=1)  # delete those observations which miss the value of made year 


######### model trying

#### logistic

data_model_1<-data_model%>%
  dplyr::select(flag,
         month,
         dep_hour,
         planes_age,
         seats, 
         temp,
         dewp,
         humid,
         wind_speed,
         pressure,
         visib,
         precip,
         origin)


# move: carrier(too many factors with much random information) 

set.seed(123)
s<-sample(nrow(data_model_1),0.6*nrow(data_model_1))
data_model_train<-data_model_1[s,]
data_model_test<-data_model_1[-s,]

#fit binomial model. move out  wind_dir(not significant) and dewp(with high corrolation coeficient with humid)
fit_log <- glm(flag ~month+
                 dep_hour+                      # from departure time
                 planes_age+
                 seats+                        # plane's type
                 temp+
                 humid+
                 wind_speed+
                 pressure+
                 visib+
                 precip+
                 origin,
               data = data_model_train, family = binomial())


summary(fit_log)



## Looking for the most significant predictor.

AICs <- rep(NA,10)
Models <- vector("list",10)
Vars <- colnames(data_model_train)[3:12]
for(i in 1:10) {
  Models[[i]] <- glm(formula(paste0("flag~",Vars[i])),data=data_model_train, family = binomial())
  AICs[i] <- AIC(Models[[i]])
}
print(AICs)

minAIC <- which.min(AICs)
print(AICs[minAIC])
print(Vars[minAIC])
summary(Models[[minAIC]])

names(AICs) <- Vars                         # add names
sAICs <- sort(AICs)                         # sort into order
print(sAICs)
plot(sAICs,xaxt="n")                        # plot
axis(1,labels=names(sAICs),at=1:length(Vars),las=2,cex.axis=.75)


# **************************************************************************************


## -------------- Interpretating The Parameter Estimates -------------- ##

exp(1.386e-01)
# dep_hour:  A unit increase in departure hour keeping all other predictors fixed changes the odds of 
#             getting a departure delay of more than 15 minutes by a factor of 1.148665 which is
#             14.87% increase.


exp(2.627e-02)
# Wind Speed: A unit increase in wind speed keeping all other predictors fixed changes the odds of 
#             getting a departure delay of more than 15 minutes by a factor of 1.026618 which accounts for
#             a 2.7% increase.

exp(-2.201e-02)
# pressure:  A unit increase in pressure keeping all other predictors fixed changes the odds of 
#             getting a departure delay of more than 15 minutes by a factor of 0.9782305 which is
#             0.22% decrease.



exp(5.174e-03)
# Temperature: A unit increase in temperature keeping all other predictors fixed changes the odds of 
#             getting a departure delay of more than15 minutes by a factor of 1.005187 which is
#             0.05% increase.


exp(1.434e-02)
# Humidity: A unit increase in humidity keeping all other predictors fixed changes the odds of 
#             getting a departure delay of more than 15 minutes by a factor of 1.014443 which is
#             1.4% increase.


exp(-4.214e-03)
# Plane's Age: A unit increase in plane's age keeping all other predictors fixed changes the odds of 
#             getting a departure delay of more than 15 minutes by a factor of 0.9957949 which is
#             0.04% decrease.

exp(-1.860e-03)
# Seats:  A unit increase in seat keeping all other predictors fixed changes the odds of 
#             getting a departure delay of more than 15 minutes by a factor of 0.9981417 which is
#             0.02% decrease.



# **************************************************************************************

## accuracy for train data set 
predictions <- predict(fit_log,data_model_train,type = "response")%>%
  round(digits = 2)


data_model_train<-data_model_train%>%
  mutate(pred_outcome =ifelse(predictions > 0.5,1,0))

# accuracy
1-sum(data_model_train$flag!=data_model_train$pred_outcome)/nrow(data_model_train)

## accuracy for test data set 

predictions_test <- predict(fit_log,data_model_test,type = "response")%>%
  round(digits = 2)


data_model_test<-data_model_test%>%
  mutate(pred_outcome =ifelse(predictions_test > 0.5,1,0))
# accuracy
1-sum(data_model_test$flag!=data_model_test$pred_outcome)/nrow(data_model_test)




# For training dataset, the accuricy is 78.86% , and for testing dataset the accuricy is 78.93%


