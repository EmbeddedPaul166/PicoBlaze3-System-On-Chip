library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port ( tx : out  std_logic;
           rx : in  std_logic;
           clk : in  std_logic;
			  rst : in std_logic;
			  sseg : out  std_logic_vector (6 downto 0);
			  an : out  std_logic_vector (2 downto 0);
			  led_one : out  std_logic;
			  led_two : out  std_logic;
			  led_three : out  std_logic);
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
    Port ( clk : in  std_logic;
           en_16_x_baud_9600 : out  std_logic;
           en_16_x_baud_4800 : out  std_logic);
end component;

component pBlaze3_uart
    Port (    en_16_x_baud_9600 : in  std_logic;
              en_16_x_baud_4800 : in  std_logic;
				  tx_user : out std_logic;
              rx_user : in std_logic;
				  tx_sseg : out std_logic;
				  tx_led : out std_logic;
				  tx_pwm_gauge : out std_logic;
              rx_pwm_gauge : in std_logic;
              clk : in std_logic);
end component;


component led_driver
    Port ( clk_in : in  std_logic;
			  en_16_x_baud_4800 : in  std_logic;
           rx : in  std_logic;
           led_one : out  std_logic;
           led_two : out  std_logic;
           led_three : out  std_logic;
			  led_one_count_uptime : out  integer range 0 to 255;
           led_two_count_uptime : out  integer range 0 to 255;
           led_three_count_uptime : out  integer range 0 to 255);
end component;

component pwm_counter
    Port ( clk_in : in  std_logic;
			  en_16_x_baud_4800 : in  std_logic;
			  led_one_count_uptime : in  integer range 0 to 255;
           led_two_count_uptime : in  integer range 0 to 255;
           led_three_count_uptime : in  integer range 0 to 255;
			  rx : in  std_logic;
           tx : out  std_logic);
end component;

component led8a_driver 
   Port (  clk_in : in  std_logic;
			  en_16_x_baud_4800 : in  std_logic;
			  sseg : out  std_logic_vector (6 downto 0);
			  an : out  std_logic_vector (2 downto 0);
           rx: in std_logic);
end component;	  


signal en_16_x_baud_9600 : std_logic;
signal en_16_x_baud_4800 : std_logic;
signal tx_sseg : std_logic;
signal tx_led : std_logic;
signal tx_pwm_gauge : std_logic;
signal rx_pwm_gauge : std_logic;
signal led_one_value :   std_logic;
signal led_two_value :   std_logic;
signal led_three_value :   std_logic;
signal led_one_count_uptime_connect :  integer range 0 to 255;
signal led_two_count_uptime_connect :  integer range 0 to 255;
signal led_three_count_uptime_connect : integer range 0 to 255;

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
              en_16_x_baud_9600 => en_16_x_baud_9600,
              en_16_x_baud_4800 => en_16_x_baud_4800);

KCPSM3: pBlaze3_uart
    Port map( en_16_x_baud_9600 => en_16_x_baud_9600,
              en_16_x_baud_4800 => en_16_x_baud_4800,
				  tx_user => tx,
              rx_user => rx,
				  tx_sseg => tx_sseg,
              tx_led => tx_led,
				  tx_pwm_gauge => tx_pwm_gauge,
				  rx_pwm_gauge => rx_pwm_gauge,
              clk => clk_slow);

LED_PWM_DRIVER: led_driver
    Port map( clk_in => clk_slow,
				  en_16_x_baud_4800 => en_16_x_baud_4800,
              rx => tx_led,
              led_one => led_one_value,
              led_two => led_two_value,
              led_three => led_three_value,
				  led_one_count_uptime => led_one_count_uptime_connect,
              led_two_count_uptime => led_two_count_uptime_connect,
              led_three_count_uptime => led_three_count_uptime_connect);

PWM_GAUGE_DRIVER: pwm_counter
    Port map( clk_in => clk_slow,
				  en_16_x_baud_4800 => en_16_x_baud_4800,
				  led_one_count_uptime => led_one_count_uptime_connect,
              led_two_count_uptime => led_two_count_uptime_connect,
              led_three_count_uptime => led_three_count_uptime_connect,
				  rx => tx_pwm_gauge,
              tx => rx_pwm_gauge);
  
SSEG_DRIVER: led8a_driver 
    Port map( clk_in => clk_slow,
				  en_16_x_baud_4800 => en_16_x_baud_4800,
				  sseg => sseg,
				  an => an,
				  rx => tx_sseg);
				  
end Behavioral;

