
//Must Download library from https://github.com/aguegu/ardulibs/tree/master/hx711
//Open library code and modify the "Average" from 25 to 1 for quicker sample rate
//If statements necessary because strain guage readings go up from 0 in compression, but down from 8420 in tension

#include <Hx711.h>

Hx711 scale(A0, A1);
int val;
int calval;
int Potval;
void setup() {
  Serial.begin(9600);
}

void loop() {
  val = scale.getGram();
  
  //Serial.println (val);
  Potval = analogRead(A3);
  Serial.println((Potval-500)*0.1*100);
  //Serial.println(val);


  if (val > (.1) && val < 10){
    Serial.println(val*29.422+6.802);
  }
  else if (val < -4000) {
    calval = ( 8420- val*(-1))*29.422+6.802;
    Serial.println(calval);
  }
  else if (val > (-0.1) && val < 0.1){
    Serial.println("0");
  }
  else {
    calval = val*29.422+6.802;
    Serial.println(calval);
    
  }
    
  delay(10);



}
  /*
  Serial.println(scale.getGram(),1);
  if ((scale.getGram()) > 5000){
    Serial.println("compression");
  } 
  else{
    Serial.println("tension");
  }
}
*/
