----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:23:53 06/23/2019 
-- Design Name: 
-- Module Name:    counter - Behavioral 
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

entity counter is
	 Generic (max_value : integer range 0 to 127 := 9);
    Port ( rst : in  STD_LOGIC;
			  clk : in  STD_LOGIC;
           count : out  integer range 0 to 127);
end counter;

architecture Behavioral of counter is

attribute keep              : string;

signal count_connect :  integer range 0 to 127 := 0;

attribute keep of count_connect    : signal is "true";

begin

  count <= count_connect;

  counter: process(clk, rst)
  begin
    if rst = '1' then
		 count_connect <= 0;
    elsif rising_edge(clk) then
       count_connect <= count_connect + 1;
    end if;
  end process counter;



end Behavioral;

