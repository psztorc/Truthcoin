D <- data.frame(x=c(0,0,0,    .125,   .25, .5,.5,.5, .5,.5,.5, .75, .875,  1,1,1),
                y=c(1,1.1,.9,   .5,     0,  1,1,1,    1,1,1,   0, .5,    1,1.1,.9))

plot(D$y~D$x)

m1 <- lm(y~x,data=D)
summary(m1)
m2 <- lm(y~poly(x,degree=4,raw=TRUE),data=D)
summary(m2)
summary(m2)$coef[,1]

Dnew <- data.frame(x=seq(0,1,length.out=100))

Dnew$Yhat <- predict(m2,newdata=Dnew)
plot(Dnew$Yhat~Dnew$x)