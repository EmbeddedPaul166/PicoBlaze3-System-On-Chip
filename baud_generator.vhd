----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:59:40 06/22/2019 
-- Design Name: 
-- Module Name:    baud_generator - Behavioral 
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

entity baud_generator is
    Port ( clk : in  STD_LOGIC;
           en_16_x_baud_9600 : out  STD_LOGIC;
           en_16_x_baud_38400 : out  STD_LOGIC);
end baud_generator;

architecture Behavioral of baud_generator is

signal           baud_count_9600 : integer range 0 to 127;
signal          baud_count_38400 : integer range 0 to 127;

begin

  baud_timer_9600: process(clk)
  begin
    if clk'event and clk='1' then
      if baud_count_9600=38 then
         baud_count_9600 <= 0;
         en_16_x_baud_9600 <= '1';
       else
         baud_count_9600 <= baud_count_9600 + 1;
         en_16_x_baud_9600 <= '0';
      end if;
    end if;
  end process baud_timer_9600;
	
	
  baud_timer_38400: process(clk)
  begin
    if clk'event and clk='1' then
      if baud_count_38400=9 then
         baud_count_38400 <= 0;
         en_16_x_baud_38400 <= '1';
       else
         baud_count_38400 <= baud_count_38400 + 1;
         en_16_x_baud_38400 <= '0';
      end if;
    end if;
  end process baud_timer_38400;


end Behavioral;

