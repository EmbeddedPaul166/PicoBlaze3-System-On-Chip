# PicoBlaze3-System-On-Chip

### Brief description
This is a System on Chip project for Elbert V2 FPGA board. It consists of VHDL files and ASM program for PicoBlaze3. It was a project assignment for Designing Reprogrammable Systems class at my University. The requirements for the project were to have 4 separate modules, where one is PicoBlaze and the rest handle board hardware such as LED, switches, etc and so that they must communicate only through PicoBlaze using UART communication protocol (including user).

My idea for the project was that the three demanded modules apart from PicoBlaze will be:
- LED PWM Driver, which sets ordered PWM duty on LED 1, 2 or 3 ordered by user, ranging from 0 to 255
- LED PWM Gauge, which detects rising and falling edges on LED values and measures their PWM duty
- SSEG Driver, which displays measured PWM duty values on seven segment display

Project was built using Xilinx ISE 14.7 and Opbasm assembler. It contains top.bit file which can be uploaded to Spartan3A FPGA right away.

### Project schematic
<img src="https://github.com/EmbeddedPaul166/PicoBlaze3-System-On-Chip/blob/master/Schematic.jpeg" height="400">

### User communication protocol
Board needs to be connected through level shifter and USB-UART converter to PC. After that a program for serial communication has to be opened and set for 9600 baud. Device responds to following commands:

#### Set LED PWM duty:
```
l1v123
```
Example command sets LED number 1 to PWM duty 123
```
l3v065
```
Example command sets LED number 3 to PWM duty 065

#### Display desired LED PWM duty value on seven segment display:
(seven segment display on Elbert V2 is only 3 digit long)
```
s1
```
Measured LED 1 PWM Duty will be displayed
```
s2
```
Measured LED 2 PWM Duty will be displayed


Assembly program has error handling implemented, so that user won't be able to break the device by typing wrong commands. PicoBlaze will send back error message upon doing so.
