#include <PWM.h>
#include <Math.h>
#include "SPI.h"
#include "MPU9250.h"
#include <Wire.h>

///// System Pin Declarations /////

// Stepper Motor Pin Declarations

// stepperMotor#[] = {Enable Pin, Direction Pin, Speed Pin}
const int stepperMotor1[] = {50, 52, 7}; // Belt Stepper Motor
const int stepperMotor2[] = {51, 53, 12}; // Chute Stepper Motor, to be added once motor is added to system.

///// System Constant Declarations /////

// Stepper Direction Declarations
const int CW = 1;
const int CCW = 0;

// Chute Position Declarations and Properties, in degrees from the leftmost cup.
const float chuteSeparation = 28;
const float smallSteel = 0;
const float smallBrass = 1;
const float largeBrass = 2;
const float largeNylon = 3;
const float dumpObject = 1.5; // Position still needs to be figured out

//Conductive Sensor Variables
const int conductivePin = 2;
const int defaultSignal = 22;

//Rangefinder Sensor Variables
int rangefinderInput = 0;
float rangefinderInput_mm = 0;
const int rangefinderPin = A1;
int rangefinderReading = 0;
float benchmarkRange = 134.5-40; //Benchmark distance of range sensor to conveyor (mm)
float readingDifferenceRange;
float largeNutThreshold = 20;

//Magnetometer Sensor Variables
MPU9250 IMU(Wire, 0x68);
int status;
float benchmarkMag = 499.1; //Benchmark value of no detected material reading (experimentally determined)
float currentValue = 0;
float readingDifferenceMag = 0;
int minimumReading = 10; //Change according to minimum reading determined experimentally
int magnetometerReading = 0;

// Other Necessary Constants
float idealConveyorFrequency = 275; // Default 75
float idealChuteFrequency = 50;

///// System Global Variables /////

// Nut Detection and Chute Position Variables
float nutDetected = 0;
float chutePosition = 1;
int DOFReading = 0;
int IRReading = 0;
int conductiveReading = 0;

//Temp Variables
int testCounter = 0;

///// System Run Code /////
// System Setup Code
void setup() { // System Setup
  InitTimersSafe();
  Serial.begin(9600);
  setupConveyor();
  setupChute();
  setupConductiveSensor();
  setupRangefinderSensor();
  delay(50);
  status = IMU.begin(); //Start communication with IMU
  if (status < 0) {
    Serial.println("IMU Initialization Unsuccessful");
    Serial.print("Status: ");
    Serial.println(status);

  }
}
// System Process Loop
void loop() {
  /*Serial.print("Magnetometer Output: ");
  Serial.print(magnetometerSensor());
  Serial.print(", ");
  Serial.print(currentValue);
  Serial.print(", ");
  Serial.println(readingDifferenceMag);
  Serial.print("Conductive Output: ");
  Serial.println(conductiveReading);
  Serial.print("Infrared Output: ");
  Serial.print(rangefinderInput_mm);
  Serial.print(", ");
  Serial.print(readingDifferenceRange);
  Serial.print(", ");
  Serial.println(rangefinderSensor());
  Serial.println(""); */

  if (magnetometerSensor() >= 1) { // Detects Steel
    chuteSelection(0, 1);
    delay (3000);
    chuteSelection(1, 0);
    Serial.println("Steel Detected");
  } else {
    if (conductiveSensor() > conductiveReading) {
      conductiveReading = conductiveSensor();
    }
    
    IRReading = rangefinderSensor();
    if (IRReading > 0 && conductiveReading > 0) { // Detects Large Brass
      chuteSelection(2, 1);
      delay (2500);
      chuteSelection(1, 2);
      Serial.println("Large Brass Detected");

      conductiveReading = 0;
      
    } else if (IRReading > 0 && conductiveReading == 0) {  // Detects Large Nylon
      chuteSelection(3, 1);
      delay (2500);
      chuteSelection(1, 3);
      Serial.println("Large Nylon Detected");

      conductiveReading = 0;
      
    }
  }
  delay (100);
}
///// Setup Functions /////

void setupConveyor() {

  for (int i = 0; i <= 2; i++) { // Initializes Pins for Stepper Motors
    pinMode(stepperMotor1[i], OUTPUT); // Belt Stepper Motor
  }
  digitalWrite(stepperMotor1[1], 1); // Set Stepper Direction
  SetPinFrequencySafe(stepperMotor1[2], setStepperSpeed(idealConveyorFrequency * 1.8, 1)); // Set Input Frequency
  analogWrite(stepperMotor1[2], 127); // Set PWM Duty Cycle Ratio
  digitalWrite(stepperMotor1[0], HIGH); // Set Enable On
}

void setupChute() {
  for (int i = 0; i <= 2; i++) { // Initializes Pins for Stepper Motors
    pinMode(stepperMotor2[i], OUTPUT); // Chute Stepper Motor, to be added once motor is added to system.
  }
}
void setupConductiveSensor() {
  pinMode(conductivePin, INPUT);
  //  attachInterrupt(digitalPinToInterrupt(conductivePin), conductiveSensorInterrupt, RISING);
  pinMode(defaultSignal, OUTPUT);
  digitalWrite(defaultSignal, HIGH);
}

void setupRangefinderSensor() {
  pinMode(rangefinderPin, INPUT);
}

///// System Functions /////

int setStepperSpeed (int translationDistance, float translationDuration) {

  // Sets stepper speed as a function of degrees/second in the form of Hz

  int output = 0; // Output in Hz
  if (translationDuration > 0) { // Verifies that a non-zero and non-negative time was input
    output = translationDistance / (1.8 * translationDuration); // Converts from input distance and time to output step frequency
  }
  return output;
}

void rotateStepper (const int stepperAttributes[], int translationDistance, float translationDuration, int translationDirection) {

  // rotateStepper() rotates a stepper motor a given distance in a given amount of time in a given direction.

  // Enables inputs to stepper as specified.
  digitalWrite(stepperAttributes[1], translationDirection); // Set Stepper Direction
  SetPinFrequencySafe(stepperAttributes[2], setStepperSpeed(translationDistance, translationDuration)); // Set Input Frequency
  analogWrite(stepperAttributes[2], 127); // Set PWM Duty Cycle Ratio
  digitalWrite(stepperAttributes[0], HIGH); // Set Enable On

  delay(translationDuration * 1000); // Waits for the input translation duration.

  // Disables all Inputs and stepper motor commands.
  digitalWrite(stepperAttributes[0], LOW); // Sets Enable Off
  analogWrite(stepperAttributes[2], 0); // Sets Analog Pin Off
  SetPinFrequencySafe(stepperAttributes[2], 0); // Sets Analog Frequency to 0
  digitalWrite(stepperAttributes[1], LOW); // Disable Stepper Direction

}

int chuteSelection(float nutType, float currentPosition) {

  // chuteSelection() recieves sensed nut type and current position, outputs stepper motor movement, and returns new position.

  int stepperMotorDirection;
  float stepperMotorTranslation;
  float stepperMotorDuration;

  digitalWrite(stepperMotor1[0], LOW); // Pauses conveyor stepper.

  stepperMotorTranslation = (nutType - currentPosition) * chuteSeparation;

  if (stepperMotorTranslation >= 0) { // May be unable to input a SetPinFrequency command of 0Hz. Needs to be tested.
    stepperMotorDirection = CW;
  } else if (stepperMotorTranslation < 0) {
    stepperMotorTranslation = abs(stepperMotorTranslation);
    stepperMotorDirection = CCW;
  }

  stepperMotorDuration = stepperMotorTranslation / (1.8 * idealChuteFrequency); // Calculates how long the stepper motor is to run.

  rotateStepper(stepperMotor2, 10 * stepperMotorTranslation, stepperMotorDuration, stepperMotorDirection);

  digitalWrite(stepperMotor1[0], HIGH); // Resumes conveyor stepper.
  return nutType;
}

/********** Sensor Read Functions **********/
int conductiveSensor() {// Returns the conductivity of the nut and resets the value.
  int output;
  output = digitalRead(conductivePin);
  return output;
}

int rangefinderSensor() {
  rangefinderInput = analogRead(rangefinderPin);

  rangefinderInput_mm = 18526 * pow(rangefinderInput, -0.968); //Converts input from range finder from ADC into mm
  readingDifferenceRange = -1 * (rangefinderInput_mm - benchmarkRange);

  //Determine type of object based on predefined threshold values
  if (readingDifferenceRange > largeNutThreshold) {
    rangefinderReading = 1;
  }
  /*else if (readingDifferenceRange < smallNutThreshold && readingDifferenceRange > -6.0) {
    rangefinderReading = 1;
  } */
  else {
    rangefinderReading = 0;
  }
  return rangefinderReading;
}

int magnetometerSensor() {
  IMU.readSensor();

  currentValue = sqrt(sq(IMU.getMagX_uT()) + sq(IMU.getMagY_uT()) + sq(IMU.getMagZ_uT()));

  readingDifferenceMag = currentValue - benchmarkMag;

  //Determine output reading based on predefined threshold values
  if (readingDifferenceMag >= minimumReading) {
    magnetometerReading = 1;
  }
  else if (readingDifferenceMag < minimumReading) {
    magnetometerReading = 0;
  }
  benchmarkMag = currentValue;
  return magnetometerReading;
}
