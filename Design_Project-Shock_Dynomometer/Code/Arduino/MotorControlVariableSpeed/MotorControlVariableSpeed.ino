
const int Onswitch = 8;
const int Modeswitch = 9;
const int LEDpfour = 7;
const int LEDpthree = 6;
const int LEDpone = 5;
const int LEDptwo = 4;
const int pwm = 10;
const int dir = 3;

int OnSwitch = 0;
int ModeSwitch = 0;

int LEDone = 0;
int LEDtwo = 0;
int LEDthree = 0;
int LEDfour= 0;

int value = 0;

void setup() {
  Serial.begin(9600);
  
  pinMode(pwm,OUTPUT);
  pinMode(dir,OUTPUT);
  
  pinMode(Onswitch, INPUT_PULLUP);
  pinMode(Modeswitch, INPUT_PULLUP);
  
  pinMode(LEDpone, OUTPUT);
  pinMode(LEDptwo, OUTPUT);
  pinMode(LEDpthree, OUTPUT);
  pinMode(LEDpfour, OUTPUT);
  
  digitalWrite(dir, HIGH);
}

void loop() {
  OnSwitch = digitalRead(Onswitch);
  Serial.println(OnSwitch);
 
  if (OnSwitch == HIGH) {
    Serial.println("Altering Speed");
      delay(100);
    ModeSwitch = digitalRead(Modeswitch);
    
    if (ModeSwitch == 1){
      value++;
    }
    
      else{
        value--;
      delay(200);
      }
      
     if(value>255) {                        
        value= 255;
     }
      else if(value<0){
       value= 0;
      }
      else if (value>0 && value<60){
        Serial.println("Low Speed");
        digitalWrite(LEDpone, HIGH);
        digitalWrite(LEDptwo, LOW);
        digitalWrite(LEDpthree,LOW);
        digitalWrite(LEDpfour, LOW);
      }
      else if (value>49 && value<120){
        Serial.println("Medium Low Speed");
        digitalWrite(LEDpone, HIGH);
        digitalWrite(LEDptwo, HIGH);
        digitalWrite(LEDpthree,LOW);
        digitalWrite(LEDpfour, LOW);
      }
      else if (value>99 && value<180){
        Serial.println("Medium High Speed");
        digitalWrite(LEDpone, HIGH);
        digitalWrite(LEDptwo, HIGH);
        digitalWrite(LEDpthree,HIGH);
        digitalWrite(LEDpfour, LOW);
      }
      else if (value>149 && value<255){
        Serial.println("High Speed Speed");
        digitalWrite(LEDpone, HIGH);
        digitalWrite(LEDptwo, HIGH);
        digitalWrite(LEDpthree,HIGH);
        digitalWrite(LEDpfour, HIGH);
      }
  }
    else{
      value=value;
      Serial.println("Constant Speed");
      delay(500);
    }
    analogWrite(pwm, value);
    Serial.println(value);
    delay(500);
    }
