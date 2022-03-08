#include <MPU9250.h>
#include <SharpIR.h>
#include "SPI.h"
#include "Wire.h"

/********** Variable Declarations **********/
//Conductive Sensor Variables
int conductiveReading = 0;
const int conductivePin = A0;
const int defaultSignal = 22;

//Rangefinder Sensor Variables
int rangefinderInput = 0;
float rangefinderInput_mm = 0;
const int rangefinderPin = A1;
int rangefinderReading = 0;
float benchmarkRange = 60.0; //Benchmark distance of range sensor to conveyor (mm)
float readingDifferenceRange;
float coinThreshold = 2.0;
float smallNutThreshold = 5.5;

//Magnetometer Sensor Variables
MPU9250 IMU(Wire,0x68);
int status;
float benchmarkMag = 0; //Benchmark value of no detected material reading (experimentally determined)
float currentValue = 0;
float readingDifferenceMag = 0;
int minimumReading = 5; //Change according to minimum reading determined experimentally
int magnetometerReading = 0;
/********** Variable Declarations **********/

void setup() {
  Serial.begin(9600);

  //Call setups for each sensor
  setupConductiveSensor(); //Set up the pins for the conductive sensor
  setupRangefinderSensor(); //Set up the pins for the range finder sensor
  setupMagnetometerSensor(); //Set up the pins for the magnetometer sensor
}

void loop() {
  
}

/********* Sensor Setups **********/
void setupConductiveSensor() {
  pinMode(conductivePin, INPUT);
  pinMode(defaultSignal, OUTPUT);
  digitalWrite(defaultSignal, HIGH); 
}

void setupRangefinderSensor() {
  pinMode(rangefinderPin, INPUT);
}

void setupMagnetometerSensor() {
  status = IMU.begin(); //Start communication with IMU
}
/********* Sensor Setups **********/

/********** Sensor Read Functions **********/
int conductiveSensor() {
  conductiveReading = digitalRead(conductivePin);
  return conductiveReading;
}

int rangefinderSensor() {
  rangefinderInput = analogRead(rangefinderPin);

  rangefinderInput_mm = 18526*pow(rangefinderInput, -0.968); //Converts input from range finder from ADC into mm
  readingDifferenceRange = benchmarkRange - rangefinderInput_mm;

  //Determine type of object based on predefined threshold values
  if(readingDifferenceRange < coinThreshold) {
    rangefinderReading = 0;
  }
  else if(readingDifferenceRange > coinThreshold && readingDifferenceRange < smallNutThreshold) {
    rangefinderReading = 1;
  }
  else if(readingDifferenceRange > smallNutThreshold) {
    rangefinderReading = 2;
  }
  
  return rangefinderReading;
}

int magnetometerSensor() {
  IMU.readSensor();

  readingDifferenceMag = currentValue - benchmarkMag;

  //Determine output reading based on predefined threshold values
  if(readingDifferenceMag >= minimumReading) {
    magnetometerReading = 1;
  }
  else if(readingDifferenceMag < minimumReading) {
    magnetometerReading = 0;
  }

  return magnetometerReading;
}
/********** Sensor Read Functions **********/
