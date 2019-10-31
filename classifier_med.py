import pandas as pd

from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

import os
import tensorflow


import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout

dataset = pd.read_csv('data/dataset_modified.csv')
dataset.head(5)

missed_appointment = dataset.groupby('PatientId')['Showed_up'].sum()
missed_appointment = missed_appointment.to_dict()
dataset['missed_appointment_before'] = dataset.PatientId.map(lambda x: 1 if missed_appointment[x]>0 else 0)
dataset['missed_appointment_before'].corr(dataset['Showed_up'])

dataset = dataset.drop(['PatientId', 'AppointmentID', 'ScheduledDay', 'AppointmentDay'], axis = 1)
print("Columns: {}".format(dataset.columns))

dataset = pd.concat([dataset.drop('Neighbourhood', axis = 1), 
           pd.get_dummies(dataset['Neighbourhood'])], axis=1)

gender_map = {'M': 0, 'F': 1}
dataset['Gender'] = dataset['Gender'].map(gender_map)

y = dataset.loc[:, 'Showed_up']
X = dataset.drop(['Showed_up'], axis = 1)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.33, random_state = 42)

print("Final shape: {}".format(X_train.shape))


standardScaler = StandardScaler()
X_train = standardScaler.fit_transform(X_train)
X_test = standardScaler.transform(X_test)


classifier = Sequential()
classifier.add(Dense(units = 64, activation = 'relu', input_dim = 91))
classifier.add(Dropout(rate = 0.5))
classifier.add(Dense(units = 128, activation = 'relu'))
classifier.add(Dropout(rate = 0.5))
classifier.add(Dense(units = 128, activation = 'relu'))
classifier.add(Dropout(rate = 0.5))
classifier.add(Dense(units = 1, activation = 'sigmoid'))
classifier.compile(optimizer = 'adam', loss = 'binary_crossentropy', metrics = ['accuracy'])
classifier.summary()


history = classifier.fit(X_train, y_train, epochs = 5, validation_split = 0.1)

y_pred = classifier.predict(X_test)
y_pred = y_pred > 0.5

print("Confusion matrix:")
print(confusion_matrix(y_test, y_pred))
print("-"*50)
print("Accuracy: {:.2f}%".format(accuracy_score(y_test, y_pred)*100))

