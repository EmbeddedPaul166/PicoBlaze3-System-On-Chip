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
			  sseg : out  STD_LOGIC_VECTOR (2 downto 0);
			  an : out  STD_LOGIC_VECTOR (7 downto 0));
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

component pBlaze3_uart
    Port (    tx_user : out std_logic;
              rx_user : in std_logic;
				  tx_8seg : out std_logic;
				  tx_led : out std_logic;
              rx_counter_led : in std_logic;
              clk : in std_logic);
end component;

--component led8a_driver 
--   Port ( clk_in : in  STD_LOGIC;
--			  sseg : out  STD_LOGIC_VECTOR (6 downto 0);
--			  an : out  STD_LOGIC_VECTOR (7 downto 0);
--			  tx: out std_logic;
--           rx: in std_logic);
--end component;	  
			
signal tx_8seg : std_logic;
signal tx_led : std_logic;
signal rx_counter_led : std_logic;

begin

CLOCK_DIVIDE_BY_TWO: clk_div
    Port map( CLKIN_IN => clk, 
              RST_IN => rst,
				  CLKDV_OUT => clk_slow, 
				  CLKIN_IBUFG_OUT => open, 
              CLK0_OUT => open);

UART: pBlaze3_uart
    Port map( tx_user => tx,
              rx_user => rx,
				  tx_8seg => tx_8seg,
              tx_led => tx_led,
				  rx_counter_led => rx_counter_led,
              clk => clk_slow);
				  
--LED_DRIVER_UART: led8a_driver 
--    generic map(F_Hz, true)
--    PORT MAP( clk_in => clk_slow,
--				  sseg => sseg,
--				  an => an,
--				  tx => open,   --temporarily
--				  rx => open);  --temporarily
				  
end Behavioral;

