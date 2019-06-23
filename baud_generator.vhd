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

--attribute dont_touch              : boolean;


signal           baud_count_9600 : integer range 127 to 0 :=0;
signal          baud_count_38400 : integer range 127 to 0 :=0;
signal         en_16_x_baud_9600_connect : std_logic;
signal        en_16_x_baud_38400_connect : std_logic;
signal        rst_38400 : std_logic := '0';
signal        rst_9600 : std_logic := '0';

--attribute dont_touch of baud_count_9600    : signal is true;
--attribute dont_touch of baud_count_38400    : signal is true;

begin

en_16_x_baud_9600 <= en_16_x_baud_9600_connect;
en_16_x_baud_38400 <= en_16_x_baud_38400_connect;

  baud_timer_38400: process(clk)
  begin
    if rst_38400 = '1' then
		baud_count_38400 <= 0;
		en_16_x_baud_38400_connect <= '0';
    elsif clk'event and clk='1' then
      if baud_count_38400=9 then
           baud_count_38400 <= 0;
           en_16_x_baud_38400_connect <= '1';
       else
           baud_count_38400 <= baud_count_38400 + 1;
           en_16_x_baud_38400_connect <= '0';
      end if;
    end if;
  end process baud_timer_38400;

  baud_timer_9600: process(clk)
  begin
	 if rst_9600 = '1' then
		baud_count_9600 <= 0;
		en_16_x_baud_9600_connect <= '0';
    elsif clk'event and clk='1' then
      if baud_count_9600=38 then
           baud_count_9600 <= 0;
         en_16_x_baud_9600_connect <= '1';
       else
           baud_count_9600 <= baud_count_9600 + 1;
         en_16_x_baud_9600_connect <= '0';
      end if;
    end if;
  end process baud_timer_9600;

end Behavioral;

