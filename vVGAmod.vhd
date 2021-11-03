-- KRB 26-Oct-2021
-- vVGAmod.vhd
-- translate TangNano example verilog VGAMod.v to VHDL



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE IEEE.NUMERIC_STD.ALL;

-- LCD driver for TangPriMER, Nano?

ENTITY vVGAmod IS
  PORT( 
        nRST:        IN STD_LOGIC := '0';      -- negative level Reset
        PixelClk:    IN STD_LOGIC;      -- 33MHz pixel clock for LCD

    -- Control
        LCD_DE:     OUT STD_LOGIC;  -- Display Enable, high during valid pixels
        LCD_HSYNC:  OUT STD_LOGIC;  -- Horz Sync, not required
        LCD_VSYNC:  OUT STD_LOGIC;  -- Vert sync, not required
    -- Data
        LCD_B:      OUT STD_LOGIC_VECTOR(7 DOWNTO 0); 
        LCD_G:      OUT STD_LOGIC_VECTOR(7 DOWNTO 0); 
        LCD_R:      OUT STD_LOGIC_VECTOR(7 DOWNTO 0) );
END vVGAmod;

-- LCD_HSYNC and LCD_VSYNC are not required by the Seeed/Tang 5" TFT,
-- hence they are generated here, but not actually tested.
-- Tie them to the LCD, or leave the LCD lines floating, high or low,
-- the TFT works just fine any which way.

ARCHITECTURE behave OF vVGAmod IS

SIGNAL H_pixCntr  : unsigned(15 DOWNTO 0);  -- pixel counter 
SIGNAL V_pixCntr  : unsigned(15 DOWNTO 0);  -- pixel counter

SIGNAL H_pixAcnt  : unsigned(15 DOWNTO 0);  -- actual Horz pixels 0..799, 
SIGNAL V_pixAcnt  : unsigned(15 DOWNTO 0);  -- actual Vert pixels 0..479,

-- timing constants, your milage may vary
CONSTANT V_BackPorch   : natural :=   0;  -- 6?
CONSTANT V_PulseW      : natural :=   5;  -- VSYNC pulse width
CONSTANT V_DisplayH    : natural := 480;  -- Vertical display pixels
CONSTANT V_FrontPorch  : natural :=  45;  -- Vert Front Porch

CONSTANT H_BackPorch   : natural := 182;  -- 
CONSTANT H_PulseW      : natural :=   1;  -- HSYNC pulse width
CONSTANT H_DisplayW    : natural := 800;  -- Horizontal display pixels
CONSTANT H_FrontPorch  : natural := 210;  -- Horz Front Porch

CONSTANT H_runLimit    : natural := H_DisplayW + H_BackPorch + H_FrontPorch; -- so 800+182+210= 1192
CONSTANT V_runLimit    : natural := V_DisplayH + V_BackPorch + V_FrontPorch; -- so 480+0+45= 525

-- original timing:
-- HSYNC=0 on H_pixCntr in [H_PulseW=1,H_DisplayW + H_BackPorch=982]
-- VSYNC=0 on V_pixCntr in [V_PulseW=5,V_runLimit-0=545]
-- DE=1 on H_pixCntr in [H_BackPorch=182,H_runLimit-H_FrontPorch=982]
--      and V_pixCntr in [V_BackPorch=0,V_runLimit-V_FrontPorch-1=479]    

BEGIN  -- ARCHITECTURE behave OF vVGAmod

myPixels: PROCESS (PixelClk) 
  BEGIN
    IF rising_edge(PixelClk) THEN
      IF (nRST='0')
  	  THEN
          V_pixCntr       <=  (OTHERS=> '0');    
          H_pixCntr       <=  (OTHERS=> '0');
  	  ELSIF ( H_pixCntr  =  H_runLimit )
      THEN
          H_pixCntr       <=  (OTHERS=> '0');
          V_pixCntr       <=  V_pixCntr + 1;
      ELSIF ( V_pixCntr  = V_runLimit  )
      THEN
          V_pixCntr       <=  (OTHERS=> '0');
          H_pixCntr       <=  (OTHERS=> '0');
      ELSE 
          H_pixCntr       <=  H_pixCntr + 1;
      END IF;
    END IF;
  END PROCESS myPixels;  -- PROCESS(PixelClock)

H_pixAcnt <= H_pixCntr - 182;
V_pixAcnt <= V_pixCntr - 0;

-- be careful, subtracting naturals gives a signed integer
LCD_HSYNC <= '0' WHEN (( H_pixCntr >= H_PulseW) AND ( H_pixCntr <= H_DisplayW + H_BackPorch))
  ELSE '1';
LCD_VSYNC <= '0' WHEN ((( V_pixCntr  >= V_PulseW ) AND ( V_pixCntr  <= V_runLimit )) )
  ELSE '1';
LCD_DE <= '1' WHEN ( H_pixCntr >= H_BackPorch )
               AND ( H_pixCntr <= H_runLimit-H_FrontPorch )
               AND ( V_pixCntr >= V_BackPorch )
               AND ( V_pixCntr <= V_runLimit-V_FrontPorch-1 )
  ELSE '0';

-- and now the 24 bit RGB colors !

--LCD_G <= 
--       "00000000" WHEN (H_pixCntr < 200)
--  ELSE "00001000" WHEN (H_pixCntr < 240) 
--  ELSE "00010000" WHEN (H_pixCntr < 280) 
--  ELSE "00100000" WHEN (H_pixCntr < 320) 
--  ELSE "01000000" WHEN (H_pixCntr < 360) 
--  ELSE "10000000" WHEN (H_pixCntr < 400) 
--  ELSE "00000000";

-- with green, we draw lines at edges, and two diagonally
-- to top left and bottom right corners.

LCD_G <= 
       "10000000" WHEN (H_pixAcnt  = V_pixCntr)
  ELSE "10000000" WHEN (H_pixAcnt -(800-480) = V_pixCntr) 
  ELSE "10000000" WHEN (H_pixAcnt  = 0) 
  ELSE "10000000" WHEN (H_pixAcnt  = 799) 
  ELSE "10000000" WHEN (V_pixAcnt   = 0) 
  ELSE "10000000" WHEN (V_pixAcnt   = 479) 
  ELSE "00000000";
  -- hum, I don't see V pixels at v= 479, only v=478; was there a v=-1?
  -- works fine when only DE is used, not HSYNC.

-- lower GB bright by half
LCD_R <= '0'&Std_Logic_Vector( V_pixAcnt( 7 downto 1));
LCD_B <= '0'&Std_Logic_Vector( H_pixAcnt( 7 downto 1));


END behave;  -- ARCHITECTURE behave OF Uart
