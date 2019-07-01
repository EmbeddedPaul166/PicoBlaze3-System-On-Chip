----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:58:52 06/02/2019 
-- Design Name: 
-- Module Name:    top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( tx : out  STD_LOGIC;
           rx : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  rst : in STD_LOGIC;
			  sseg : out  STD_LOGIC_VECTOR (6 downto 0);
			  an : out  STD_LOGIC_VECTOR (2 downto 0);
			  led_one : out  STD_LOGIC;
			  led_two : out  STD_LOGIC;
			  led_three : out  STD_LOGIC);
end top;

architecture Behavioral of top is

signal clk_slow : std_logic;

component clk_div 
    Port ( CLKIN_IN        : in    std_logic; 
           RST_IN          : in    std_logic; 
           CLKDV_OUT       : out   std_logic; 
           CLKIN_IBUFG_OUT : out   std_logic; 
           CLK0_OUT        : out   std_logic);
end component;

component baud_generator
    Port ( clk : in  STD_LOGIC;
           en_16_x_baud_9600 : out  STD_LOGIC;
           en_16_x_baud_38400 : out  STD_LOGIC);
end component;

component pBlaze3_uart
    Port (    en_16_x_baud_9600 : in  std_logic;
              en_16_x_baud_38400 : in  std_logic;
				  tx_user : out std_logic;
              rx_user : in std_logic;
				  tx_sseg : out std_logic;
				  tx_led : out std_logic;
              rx_pwm_gauge : in std_logic;
              clk : in std_logic);
end component;


component led_driver
    Port ( clk_in : in  STD_LOGIC;
			  en_16_x_baud_9600 : in  STD_LOGIC;
           rx : in  STD_LOGIC;
           led_one : out  STD_LOGIC;
           led_two : out  STD_LOGIC;
           led_three : out  STD_LOGIC);
end component;

component pwm_counter
    Port ( clk_in : in  STD_LOGIC;
			  en_16_x_baud_9600 : in  STD_LOGIC;
           led_one : in  STD_LOGIC;
           led_two : in  STD_LOGIC;
           led_three : in  STD_LOGIC;
           tx : out  STD_LOGIC);
end component;

component led8a_driver 
   Port (  clk_in : in  STD_LOGIC;
			  en_16_x_baud_9600 : in  STD_LOGIC;
			  sseg : out  STD_LOGIC_VECTOR (6 downto 0);
			  an : out  STD_LOGIC_VECTOR (2 downto 0);
           rx: in STD_LOGIC);
end component;	  


signal en_16_x_baud_9600_connect : std_logic;
signal en_16_x_baud_38400_connect : std_logic;
signal tx_sseg_connect : std_logic;
signal tx_led : std_logic;
signal rx_pwm_gauge : std_logic;
signal led_one_value :   STD_LOGIC;
signal led_two_value :   STD_LOGIC;
signal led_three_value :   STD_LOGIC;

begin

led_one <= led_one_value;
led_two <= led_two_value;
led_three <= led_three_value;

CLOCK_DIVIDE_BY_TWO: clk_div
    Port map( CLKIN_IN => clk, 
              RST_IN => rst,
				  CLKDV_OUT => clk_slow, 
				  CLKIN_IBUFG_OUT => open, 
              CLK0_OUT => open);

BAUD_GEN: baud_generator
    Port map( clk => clk_slow,
              en_16_x_baud_9600 => en_16_x_baud_9600_connect,
              en_16_x_baud_38400 => en_16_x_baud_38400_connect);

KCPSM3: pBlaze3_uart
    Port map( en_16_x_baud_9600 => en_16_x_baud_9600_connect,
              en_16_x_baud_38400 => en_16_x_baud_38400_connect,
				  tx_user => tx,
              rx_user => rx,
				  tx_sseg => tx_sseg_connect,
              tx_led => tx_led,
				  rx_pwm_gauge => rx_pwm_gauge,
              clk => clk_slow);

LED_PWM_DRIVER: led_driver
    Port map( clk_in => clk_slow,
				  en_16_x_baud_9600 => en_16_x_baud_9600_connect,
              rx => tx_led,
              led_one => led_one_value,
              led_two => led_two_value,
              led_three => led_three_value);

PWM_GAUGE_DRIVER: pwm_counter
    Port map( clk_in => clk_slow,
				  en_16_x_baud_9600 => en_16_x_baud_9600_connect,
              led_one => led_one_value,
              led_two => led_two_value,
              led_three => led_three_value,
              tx => rx_pwm_gauge);
  
SSEG_DRIVER: led8a_driver 
    Port map( clk_in => clk_slow,
				  en_16_x_baud_9600 => en_16_x_baud_9600_connect,
				  sseg => sseg,
				  an => an,
				  rx => tx_sseg_connect);
				  
end Behavioral;

