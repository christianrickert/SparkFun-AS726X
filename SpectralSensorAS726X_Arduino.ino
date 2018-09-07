/*
  SpectralSensorAS726 Arduino
  Copyright (C) 2018  Christian Rickert

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/


// imports
#include "AS726X.h"


// constants
AS726X sensor;
const byte c = 1;       // number of bytes per char
const byte f = 4;       // number of bytes per float
const byte v = 7;       // number of sensor readings


// type definitions
typedef union {
  char asByte[c];
  char asChar;
  char asInt;
} character;
character sign;         // for serial handshaking

typedef union {
  byte asByte[f];
  float asFloat;
} decimal;
decimal number;         // for serial transmission


// variables
float values[v] = {0};  // all sensor readings


void setup() {

  // configure sensor
  sensor.begin();
  sensor.setMeasurementMode(2);  // continuous data sampling
  sensor.setIntegrationTime(8);  // 1-255 * 2.8 ms (2.8-714 ms)

  // configure serial port
  Serial.begin(115200);
  while (Serial.available())     // clear (pull) read buffer
    Serial.read();
  Serial.flush();                // clear (push) write buffer

}


void loop() {

  if (sensor.dataAvailable()) {

    // read sensor values from memory banks
    values[0] = sensor.getCalibratedViolet();   // 450 nm +/- 20 nm (HWHM)
    values[1] = sensor.getCalibratedBlue();     // 500 nm +/- 20 nm (HWHM)
    values[2] = sensor.getCalibratedGreen();    // 550 nm +/- 20 nm (HWHM)
    values[3] = sensor.getCalibratedYellow();   // 570 nm +/- 20 nm (HWHM)
    values[4] = sensor.getCalibratedOrange();   // 600 nm +/- 20 nm (HWHM)
    values[5] = sensor.getCalibratedRed();      // 650 nm +/- 20 nm (HWHM)
    values[6] = sensor.getTemperature();        // assuming -40°C -> 85°C

    // begin of data transmission
    sensor.enableIndicator();
    sign.asChar = '\r';
    Serial.write(sign.asByte, c);

    // perform data transmission
    for (int i = 0; i < v; i++) {
      number.asFloat = values[i];
      Serial.write(number.asByte, f);
    }
    Serial.println();

    // end of data transmission
    sign.asChar = '\n';
    Serial.write(sign.asByte, c);
    Serial.flush();              // wait for outgoing transmission

    // waiting for response
    while (Serial.available() < c)
      delay(1);

    // validating response
    sign.asChar = '\t';
    if (Serial.read() == sign.asInt)
      sensor.disableIndicator();
  }

}
