# sleep analysis - quick and dirty
# updated tuesday i think

library(tidyverse)
library(broom)

# load data
dat <- read.csv("/Users/researcher/Desktop/sleep_project/data/pilot_sleep.csv")

# look at it
head(dat)
summary(dat)
str(dat)

# missing values
sum(is.na(dat$sleep_hours))
sum(is.na(dat$caffeine_mg_daily))

# drop rows with missing data for now (TODO: revisit this)
dat2 <- dat[complete.cases(dat),]

# plot sleep distribution
hist(dat2$sleep_hours, breaks=20, main="sleep hours", xlab="hours")

# plot gpa distribution
hist(dat2$gpa, breaks=20)

# scatter
plot(dat2$sleep_hours, dat2$gpa)

# regression
m1 <- lm(gpa ~ sleep_hours, data=dat2)
summary(m1)

# add controls
m2 <- lm(gpa ~ sleep_hours + stress_score + year_of_study, data=dat2)
summary(m2)

# diagnostics
par(mfrow=c(2,2))
plot(m2)
par(mfrow=c(1,1))

# also try with caffeine
m3 <- lm(gpa ~ sleep_hours + stress_score + year_of_study + caffeine_mg_daily, data=dat2)
summary(m3)

# correlation matrix
cor(dat2[,c("sleep_hours","gpa","stress_score","caffeine_mg_daily","year_of_study")])

# save plot
png("sleep_gpa_scatter.png")
plot(dat2$sleep_hours, dat2$gpa, xlab="Sleep hours", ylab="GPA", pch=19, col=rgb(0,0,0,0.4))
abline(m1, col="red", lwd=2)
dev.off()

# print results
print(summary(m2))
cat("R-squared:", summary(m2)$r.squared, "\n")

# todo:
# - clean up the path (hardcoded)
# - actually decide what to do about missing data
# - need to check normality of residuals more carefully
# - write up results
# - figures need proper labels
