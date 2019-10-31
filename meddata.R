library('ggplot2')
library('gridExtra')
library('lubridate')

medical.dataset <- read.csv('data/med_dataset.csv', header = TRUE, sep = ',')
head(medical.dataset)
print(paste("Rows: ", nrow(medical.dataset)))
print(paste("Columns: ", ncol(medical.dataset)))
names(medical.dataset)

names(medical.dataset)[14] <- "Showed_up"
medical.dataset$Showed_up <- medical.dataset$Showed_up == 'No'

summary(medical.dataset)  
medical.dataset$ScheduledDay <- as.Date(medical.dataset$ScheduledDay)
medical.dataset$AppointmentDay <- as.Date(medical.dataset$AppointmentDay)
medical.dataset$Scholarship <-as.logical(medical.dataset$Scholarship)
medical.dataset$Hipertension <-as.logical(medical.dataset$Hipertension)
medical.dataset$Diabetes <-as.logical(medical.dataset$Diabetes)
medical.dataset$Alcoholism <-as.logical(medical.dataset$Alcoholism)
medical.dataset$Handcap <-as.logical(medical.dataset$Handcap)
medical.dataset$SMS_received <-as.logical(medical.dataset$SMS_received)
medical.dataset <- medical.dataset[medical.dataset$Age > 0, ]

png("person_turn.png")
plot<-ggplot(medical.dataset, aes(Showed_up)) + 
  geom_bar(fill = 'white', color = 'orange', width = 0.4) + 
  ggtitle("Did the person show for the appointment?") + 
  labs(y="Count", x = "No show for appointment")
print(plot)
dev.off()
png("gender.png")
plot2<-ggplot(medical.dataset, aes(Gender)) + 
  geom_bar(fill = c('#00AFBB', '#FC4E07'), color = c('#00AFBB', '#FC4E07'), width = 0.4) + 
  ggtitle("Gender appointment distribution") + 
  labs(y="Count", x = "Gender") +
  scale_x_discrete(labels=c("M" = "Male", "F" = "Female"))
print(plot2)
dev.off()
png("all.png")
plot3<-grid.arrange(ggplot(medical.dataset, aes(x=Scholarship, fill=Showed_up)) + geom_bar(position="fill"),
             ggplot(medical.dataset, aes(x=Hipertension, fill=Showed_up)) + geom_bar(position="fill"),
             ggplot(medical.dataset, aes(x=Diabetes, fill=Showed_up)) + geom_bar(position="fill"),
             ggplot(medical.dataset, aes(x=Alcoholism, fill=Showed_up)) + geom_bar(position="fill"),
             ggplot(medical.dataset, aes(x=Handcap, fill=Showed_up)) + geom_bar(position="fill"),
             ggplot(medical.dataset, aes(x=SMS_received, fill=Showed_up)) + geom_bar(position="fill"), ncol = 2)
print(plot3)
dev.off()
date.diff <- as.data.frame(medical.dataset$AppointmentDay - medical.dataset$ScheduledDay)
names(date.diff) <- 'Days.difference'
medical.dataset$Date.diff <- as.numeric(unlist(date.diff))
png("diff.png")
plot4<-ggplot(medical.dataset, aes(x = Date.diff, fill = Showed_up)) + geom_bar() +
  ggtitle("Difference between schedule day and appointment day") +
  labs(y="Count", x = "Days")
print(plot4)
dev.off()
png("slim_diff.png")
plot5<-ggplot(medical.dataset, aes(x = Date.diff, fill = Showed_up)) + geom_bar() +
  ggtitle("Difference between schedule day and appointment day") +
  labs(y="Count", x = "Days") + xlim(1,200)
print(plot5)
dev.off()
medical.dataset$Month <- month(medical.dataset$AppointmentDay)
png("month.png")
plot6<-ggplot(medical.dataset, aes(x = Month, fill = Showed_up)) + geom_bar() +
  ggtitle("Effect of month on appointment show ups") +
  labs(y="Count", x = "Months")
print(plot6)
dev.off()
#We can retrieve a subset of the dataset using subset() method and then by defining the argument select as -Month,

medical.dataset <- subset(medical.dataset, select = -Month)

png("neighbourhood.png")
plot7<-ggplot(medical.dataset, aes(x = Neighbourhood, fill = Showed_up)) + 
  geom_bar() + 
  ggtitle("Neighborhoods vs Appointment count") + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 5))

print(plot7)
dev.off()


age.show = as.data.frame(table(medical.dataset[medical.dataset$Showed_up == 'TRUE', ]$Age))
age.no_show = as.data.frame(table(medical.dataset[medical.dataset$Showed_up == 'FALSE', ]$Age))
png("age.png")
plot8<-ggplot(age.show, aes(x = Var1, y = Freq)) + geom_point(color = '#00AFBB') + geom_smooth(method = lm) +
  geom_point(data = age.no_show, aes(y = Freq), color = '#FC4E07') +
  scale_x_discrete(breaks = c(0, 25, 50, 75, 100, 125, 150), name = 'Age') +
  ggtitle("Relationship between age, their counts and show up")
print(plot8)
dev.off()

write.csv(medical.dataset, file = 'data/dataset_modified.csv', row.names = FALSE)



