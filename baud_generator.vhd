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

attribute keep              : string;


signal           baud_count_9600 : integer range 0 to 127;
signal          baud_count_38400 : integer range 0 to 127;
signal         en_16_x_baud_9600_connect : std_logic;
signal        en_16_x_baud_38400_connect : std_logic;
signal        rst_38400 : std_logic := '0';
signal        rst_9600 : std_logic := '0';

attribute keep of rst_38400    : signal is "true";
attribute keep of rst_9600    : signal is "true";

component counter
	 Generic (max_value : integer range 0 to 127 := 9);
    Port ( rst : in  STD_LOGIC;
			  clk : in  STD_LOGIC;
           count : out  integer range 0 to 127);
end component;

begin

en_16_x_baud_9600 <= en_16_x_baud_9600_connect;
en_16_x_baud_38400 <= en_16_x_baud_38400_connect;

	 counter_baud_9600: counter
	 Generic map(max_value => 38)
    Port map( rst => rst_9600,
			  clk => clk,
           count => baud_count_9600);
			  
	 counter_baud_38400: counter
	 Generic map(max_value => 9)
    Port map( rst => rst_38400,
	        clk => clk,
           count => baud_count_38400);

	baud_gen_9600: process(baud_count_9600, clk)
	begin
	if rising_edge(clk) then
		if baud_count_9600 = 9 then
			en_16_x_baud_9600_connect <= '1';
			rst_9600 <= '1';
		else
			en_16_x_baud_9600_connect <= '0';
			rst_9600<= '0';
		end if;
	end if;
	end process;
	
	
	baud_gen_38400: process(baud_count_9600, clk)
	begin
	if rising_edge(clk) then
		if baud_count_38400 = 38 then
			en_16_x_baud_38400_connect <= '1';
			rst_38400 <= '1';
		else
			en_16_x_baud_38400_connect <= '0';
			rst_38400 <= '0';
		end if;
	end if;	
	end process;


end Behavioral;

