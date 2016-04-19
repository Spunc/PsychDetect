/*
 * Arduino software to be used in combination with PsychDetect
 *
 * Allows an Arduino to be used as I/O device.
 *
 * INPUT:
 * Currently, only pin 2 is configured as an input pins. In our
 * setup, we use it to check the status of a photo sensor that
 * signals, if the subject is in the waiting position.
 * If the input pin changes its state to HIGH, pin 13 (the
 * onboard LED) will be switched on.

 * OUTPUT:
 * Currently, only pin 12 is configured as an output pin. In our
 * setup, we use it to operate a feeder for giving rewards upon
 * correct stimulus detection.
 * To control output pins through a serial connection, send two
 * bytes with the first byte indicating the pin number (12) and
 * the second byte the new state (HIGH or LOW).
 *
 * Author: Lasse Osterhagen
 * 2016-04-18
 */

const byte inputPin = 2;
const byte outputPin = 12;
const byte LEDPin = 13;

byte oldInputVal = 0;
byte inBuffer[2];
byte outBuffer[2];

void writeSerial(byte val) {
  digitalWrite(LEDPin, val);
  outBuffer[1] = val;
  Serial.write( (uint8_t*) outBuffer, 2 );
}

void setup() {
  pinMode(inputPin, INPUT);
  pinMode(outputPin, OUTPUT);
  pinMode(LEDPin, OUTPUT);
  outBuffer[0] = inputPin;
  Serial.begin(9600);
}

void loop() {
  
  // Check input pin status
  byte newInputVal = digitalRead(inputPin);
  if(newInputVal != oldInputVal) {
    writeSerial(newInputVal);
    oldInputVal = newInputVal;
  }
  
  // Check serial input
  if(Serial.available() > 0) {
    Serial.readBytes( (char*) inBuffer, 2 );
    if(inBuffer[0] == outputPin) {
      digitalWrite(inBuffer[0], inBuffer[1]);
    }
  }
}

/*
 * Serial input handling can be extended, e. g. for analog output:
 * else {
 *   analogWrite(inBuffer[0], inBuffer[1]);
 * }
 */

