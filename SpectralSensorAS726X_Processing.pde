/*
  SpectralSensorAS726 Processing
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
import java.nio.*;
import processing.serial.*;
import controlP5.*;


// constants
ControlP5 cp5;
static final int cr = 13;           // DEC integer value of the carriage return character
static final int lf = 10;           // DEC integer value of the line feed character
static final int tb = 9;            // DEC integer value of the tabulator character
static final int nf = 4;            // number of bytes expected per data value
static final int nv = 7;            // number of expected values per data transmission
static final int nb = nf * nv + 2;  // number of bytes expected per data transmission (handshake + data)


// variables
byte[] offBuffer = new byte[4096];  // buffer for offset correction, maximum size
byte[] inBuffer = new byte[nb];     // buffer for data transmission, data transmission size
float value = 0.0;                  // single sensor reading
String[] Sliders = {" V  [450 nm]", " B  [500 nm]", " G  [550 nm]", " Y  [570 nm]", " O  [600 nm]", " R  [650 nm]", "        T  [°C]"};
String[] values = {};               // all sensor readings


// configure serial port
Serial serialPort = new Serial(this, "COM3", 115200);


// functions
void ONLINE() {
  cp5.getController("ONLINE").setColorForeground(color(255, 0, 0));
  dispose();
}

void RESET() {
  cp5.getController("ONLINE").setColorForeground(color(100, 100, 100));
  for (int s=0; s<(nv-1); s+=1)
    cp5.getController(Sliders[s]).setMax(5.0);
}

void receiveSensorData() {

  // wait for data block
  while (serialPort.available() < nb)
    delay(1);

  // correct data offset, look for carriage return character
  serialPort.readBytesUntil(cr, offBuffer);

  // begin data processing, end with line feed character
  serialPort.readBytesUntil(lf, inBuffer);
  for (int b=0; b<(nb-2); b+=nf) {
    value = ByteBuffer.wrap(inBuffer).order(ByteOrder.LITTLE_ENDIAN).getFloat(b);
    if (value > cp5.getController(Sliders[b/nf]).getMax())
      for (int s=0; s<(nv-1); s+=1)
        cp5.getController(Sliders[s]).setMax(value);
    cp5.getController(Sliders[b/nf]).setValue(value);
    print(value); print(" ");
    }
  println();

  // confirm data transmission, return tabulator character
  cp5.getController("ONLINE").setColorForeground(color(0, 255, 0));
  serialPort.write(tb);

}

void setup() {

  while (serialPort.available() > 0)  // clear (pull) read buffer
    serialPort.read();
  serialPort.clear();                 // clear (push) write buffer

  size(850, 600); // canvas size
  background(color(64, 64, 64));

  cp5 = new ControlP5(this);          // constructor

  cp5.addBang("ONLINE")
    .setPosition(50, 50)
    .setSize(50, 50)
    .setColorForeground(color(100, 100, 100));

  cp5.addBang("RESET")
    .setPosition(50, 150)
    .setSize(50, 50)
    .setColorForeground(color(100, 100, 100));

  cp5.addSlider(Sliders[0])
    .setPosition(150, 50)
    .setSize(50, 500)
    .setRange(0, 5)
    .setValue(1)
    .setColorForeground(color(98, 0, 255))
    .setColorBackground(color(128,128,128));

  cp5.addSlider(Sliders[1])
    .setPosition(250, 50)
    .setSize(50, 500)
    .setRange(0, 5)
    .setValue(1)
    .setColorForeground(color(0, 236, 167))
    .setColorBackground(color(128,128,128));

  cp5.addSlider(Sliders[2])
    .setPosition(350, 50)
    .setSize(50, 500)
    .setRange(0, 5)
    .setValue(1)
    .setColorForeground(color(0, 255, 0))
    .setColorBackground(color(128,128,128));

  cp5.addSlider(Sliders[3])
    .setPosition(450, 50)
    .setSize(50, 500)
    .setRange(0, 5)
    .setValue(1)
    .setColorForeground(color(237, 255, 0))
    .setColorBackground(color(128,128,128));

  cp5.addSlider(Sliders[4])
    .setPosition(550, 50)
    .setSize(50, 500)
    .setRange(0, 5)
    .setValue(1)
    .setColorForeground(color(255, 114, 0))
    .setColorBackground(color(128,128,128));

  cp5.addSlider(Sliders[5])
    .setPosition(650, 50)
    .setSize(50, 500)
    .setRange(0, 5)
    .setValue(1)
    .setColorForeground(color(221, 0, 0))
    .setColorBackground(color(128,128,128));

  cp5.addSlider(Sliders[6])
    .setPosition(750, 50)
    .setSize(50, 500)
    .setRange(-40, 85)
    .setValue(-27.5)
    .setColorForeground(color(255, 255, 255))
    .setColorBackground(color(128,128,128));

}


void draw() {     // main loop
  receiveSensorData();
}


void dispose() {  // finally
    print("Stopping ...");
    serialPort.stop();
    println(" done.");
}
