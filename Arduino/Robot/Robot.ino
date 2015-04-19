const int rightMotorPinF=6;
const int rightMotorPinB=7;
const int leftMotorPinF=8;
const int leftMotorPinB=9;
const int headphonePin=A0;
const int motorSpeed=1000;
const float numReadings=1200;

void setup(){
  Serial.begin(9600);
  pinMode(headphonePin, INPUT);
  pinMode(leftMotorPinF, OUTPUT);
  pinMode(leftMotorPinB, OUTPUT);
  pinMode(rightMotorPinF, OUTPUT); 
  pinMode(rightMotorPinB, OUTPUT);
}

void loop(){
    float m=0;
    float voltage;
    float lastVoltage=analogRead(headphonePin);
    float last=0;
    float mostZerosInARow=0;
    float numZeros=0;
    for(int x=0;x<numReadings;x++){
      voltage=analogRead(headphonePin);
      if((voltage>lastVoltage)!=last){
        m+=1;
      }
      if (lastVoltage==0 && voltage==0){
        numZeros+=1;
      }
      if (lastVoltage==0 && voltage!=0){
        if (numZeros>mostZerosInARow){
          mostZerosInARow=numZeros;
        }
        numZeros=0;
      }
      last=(voltage>lastVoltage);
      lastVoltage=voltage;
    }
    if (numZeros>mostZerosInARow){
      mostZerosInARow=numZeros;
      numZeros=0;
    }
        
    Serial.print(mostZerosInARow);Serial.print(": ");Serial.println(m);
    if (m>100*(numReadings/1500) && m<560*(numReadings/1500) && mostZerosInARow<10){ //forward
      Serial.println("forward");
      analogWrite(leftMotorPinF, motorSpeed);
      analogWrite(leftMotorPinB, 0);
      analogWrite(rightMotorPinF, motorSpeed);
      analogWrite(rightMotorPinB, 0);
    }else if (m>560*(numReadings/1500) && m<945*(numReadings/1500) && mostZerosInARow<10){ //back
      Serial.println("back");
      analogWrite(leftMotorPinF, 0);
      analogWrite(leftMotorPinB, motorSpeed);
      analogWrite(rightMotorPinF, 0);
      analogWrite(rightMotorPinB, motorSpeed);
    }else if (m>945*(numReadings/1500) && m<1290*(numReadings/1500) && mostZerosInARow<10){ //right
      Serial.println("right");
      analogWrite(leftMotorPinF, 0);
      analogWrite(leftMotorPinB, 0);
      analogWrite(rightMotorPinF, motorSpeed);
      analogWrite(rightMotorPinB, 0);
    }else if (m>1290*(numReadings/1500) && m<2000*(numReadings/1500) && mostZerosInARow<10){ //left
      Serial.println("left");
      analogWrite(leftMotorPinF, motorSpeed);
      analogWrite(leftMotorPinB, 0);
      analogWrite(rightMotorPinF, 0);
      analogWrite(rightMotorPinB, 0);
    }else{ //None
      Serial.println("None");
      analogWrite(leftMotorPinF, 0);
      analogWrite(leftMotorPinB, 0);
      analogWrite(rightMotorPinF, 0);
      analogWrite(rightMotorPinB, 0);
    }
    
}

