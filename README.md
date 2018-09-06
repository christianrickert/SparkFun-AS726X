# SparkFun-AS726X
Demonstration of the SparkFun AS726X NIR/VIS Spectral Sensor

![Screenshot of the graphical user interface](https://github.com/crickert1234/SparkFun-AS726X/blob/master/SpectralSensorAS726X.png)

## Hardware
* [SparkFun RedBoard - Programmed with Arduino](https://www.sparkfun.com/products/13975)
* [SparkFun Qwiic Shield for Arduino](https://www.sparkfun.com/products/14352)
* [SparkFun Spectral Sensor Breakout - AS7262 Visible (Qwiic)](https://www.sparkfun.com/products/14347)

## Communication
The connection between the RedBoard and the graphical user interface is realized via virtual COM drivers from [FTDI](http://www.ftdichip.com/Drivers/VCP.htm). The communication is implemented through a custom serial port handshake, i.e. the RedBoard will not record or transmit new data before the previous transmission has been confirmed by the graphical user interface.
