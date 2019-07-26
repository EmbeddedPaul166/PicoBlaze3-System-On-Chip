----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:59:40 06/22/2019 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity baud_generator is
    Port ( clk : in  STD_LOGIC;
           en_16_x_baud_9600 : out  STD_LOGIC;
           en_16_x_baud_4800 : out  STD_LOGIC);
end baud_generator;

architecture Behavioral of baud_generator is

signal           baud_count_9600 : integer range 0 to 127;
signal          baud_count_4800 : integer range 0 to 127;

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
	
	
  baud_timer_4800: process(clk)
  begin
    if clk'event and clk='1' then
      if baud_count_4800=77 then
         baud_count_4800 <= 0;
         en_16_x_baud_4800 <= '1';
       else
         baud_count_4800 <= baud_count_4800 + 1;
         en_16_x_baud_4800 <= '0';
      end if;
    end if;
  end process baud_timer_4800;


end Behavioral;

