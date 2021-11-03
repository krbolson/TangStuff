readme.md
KRB 03-Nov-2021

This github repository is set up to share some FPGA code and save other
English speakers a bit of trouble with the Tang products.  I am not very
familar with github and do not intend to update these files frequently.

The VHDL and other files here relate to the following FPGA products

1.  "Sipeed Tang Nano FPGA Board Powered by GW1N-1 FPGA"
    Tang Nano:  Gowin GW1N-1-LV based breadboard in 40DIP600 form, USB-C
    Purchased from seeedstudio, $5.90 each,  SKU# 102991314
    https://www.seeedstudio.com/Sipeed-Tang-Nano-FPGA-board-powered-by-GW1N-1-FPGA-p-4304.html

2.  "Sipeed TANG PriMER FPGA Dev. Board"
    Tang Primer Anlogic EG4S20 based breadboard in 40DIP600 form, USB-microB
    Purchased from seeedstudio, $20.60 each,  SKU# 102110202
    https://www.seeedstudio.com/Sipeed-TANG-PriMER-FPGA-Development-Board-p-2881.html

3.  "5 Inch TFT Display for Sipeed Tang Nano FPGA Development Board"
    A rather delicate affair with a dangling flex PCB and 40pin 0.5mm FFC
    Purchased from seeedstudio, $15.60 each,  SKU# 104990583
    https://www.seeedstudio.com/5-Inch-Display-for-Sipeed-Tang-Nanno-p-4301.html
    
The 5" TFT display is a generic with a resistive touchscreen.  The TangNano does not use or
wire the touchscreen pins.  The TangPrimer does, and works fine with this display.
Both of the breadboards are somewhat awkward to use with the short cable of the TFT,
and physically mounting everything securely is a puzzle - you'll have to glue the TFT
somehow to a mounting plate.  Something for thingaverse 3D printing ?

The 5" TFT display does not require the LCD_HSYNC or LCD_VSYMC signals, only LCD_DEN,
so save a few gates by not wiring them.

The TangNano also works, but the LCD uses up most than 50% of the available I/O pins, and
if you want any sort of a frame buffer you'll run out of memory.  The TangNano only uses
16 of the 24 color lines and does not wire the touchscreen.

I imagine the TangNano, with some work, could support a pong or breakout type game.  Maybe
a VT100 emulator with more work.  Displaying even static pictures on the TangNano seems
difficult, as 800x480x16 is 6 Mbits, and the G1WIN-1-LV only has 72 Kbits.  Quite a challenge!

In any case, for the TFT I am likely to use it with the Tang Primer, and save the Tang Nano
for a motor and quadreature encoder experiment.  Or maybe some I2C solar panel tilter.


For more information on these Tang Products, visit:
   www.sipeed.com
   https://dl.sipeed.com/shareURL/TANG/Primer
   https://tangnano.sipeed.com/

The related synthesis software is avaiable from FPGA manufacturers.
   www.gowin.com
   www.anlogic.com

Finding the proper licenses can take a while.
Seeedstudio does not provide current links for them, rather expired versions.
A lot of the documentation is in Chinese - google translate helps here in some cases.

For benchtop developemnt, neither of the FPGA boards provide a serial port interface
through the USB after FPGA configuration.  This is annoying - get yourself an FTDI.


Files:
1.  readme.md   -- this file

2.  vVGAmod.vhd -- driver for 5" TFT
    This has been tested on the Tang Primer.  It should  also work with the
    Tang Nano, but has not been tested yet.  It provides a bit clearer looking
    screen then the demo for the Tang Nano, and verifies the edges of the
    display can be addressed.

3.  <nofileyet>  I could include the io.adc I/O pin assignments, some sdc timing
    constraints and a top level with the 24-to33MHz pll hooking everything up,
    but that is virtually identical to what Tang provides at sites given above.

Contact: krbolson \<at\> gmail \<dot\> com

