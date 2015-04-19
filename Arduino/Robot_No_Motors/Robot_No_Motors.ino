const int headphonePin=A0;
void setup(){
  Serial.begin(9600);
  pinMode(headphonePin, INPUT);
}

void loop(){
  float m=0;
  float voltage;
  float lastVoltage=analogRead(headphonePin);
  float last=0;
  for(int x=0;x<1500;x++){
    voltage=analogRead(headphonePin);
    if((voltage>lastVoltage)!=last){
      m+=1;
    }
    last=(voltage>lastVoltage);
    lastVoltage=voltage;
  }
  
  Serial.println(m);
}

