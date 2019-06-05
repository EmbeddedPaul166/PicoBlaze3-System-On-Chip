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
    Port ( alarm : out STD_LOGIC;
			  tx : out  STD_LOGIC;
           rx : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  rst : in STD_LOGIC);
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

component uart_clock
    Port ( tx : out std_logic;
           rx : in std_logic;
           alarm : out std_logic;
           clk : in std_logic);
end component;


begin

CLOCK_DIVIDE_BY_TWO: clk_div
    Port map( CLKIN_IN => clk, 
          RST_IN => rst,
          CLKDV_OUT => clk_slow, 
          CLKIN_IBUFG_OUT => open, 
          CLK0_OUT => open);

UART: uart_clock
    Port map (tx => tx,
              rx => rx,
				  alarm => alarm,
              clk => clk_slow);
end Behavioral;

