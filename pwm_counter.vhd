----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:58:05 06/19/2019 
-- Design Name: 
-- Module Name:    pwm_counter - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm_counter is
    Port ( clk_in : in  STD_LOGIC;
			  en_16_x_baud_4800 : in  std_logic;
			  led_one_count_up : in  integer range 0 to 255;
           led_two_count_up : in  integer range 0 to 255;
           led_three_count_up : in  integer range 0 to 255;
           tx : out  STD_LOGIC);
end pwm_counter;

architecture Behavioral of pwm_counter is

  component uart_tx
    Port (            data_in : in std_logic_vector(7 downto 0);
                 write_buffer : in std_logic;
                 reset_buffer : in std_logic;
                 en_16_x_baud : in std_logic;
                   serial_out : out std_logic;
                  buffer_full : out std_logic;
             buffer_half_full : out std_logic;
                          clk : in std_logic);
    end component;

constant total_signal_count : integer range 0 to 255 := 255;

signal             write_to_uart : std_logic;
signal                   tx_full : std_logic;
signal              tx_half_full : std_logic;
signal                   data_tx : std_logic_vector(7 downto 0);


signal reg_led_one_count_up : integer range 0 to 255 := 0;
signal reg_led_two_count_up : integer range 0 to 255 := 0;
signal reg_led_three_count_up : integer range 0 to 255 := 0;

type state is ( led_one_write, wait_after_write_one, led_two_write, wait_after_write_two, led_three_write, wait_after_write_three);
signal current_state : state := led_one_write;

begin

FSM : process(clk_in, current_state, led_one_count_up, led_two_count_up, led_three_count_up) is
begin
	 if rising_edge(clk_in) then
	 write_to_uart <= '0';	 
    case current_state is		  

		  when led_one_write =>
				if led_one_count_up /= reg_led_one_count_up and tx_full = '0' then					
					data_tx <=	std_logic_vector(to_unsigned(led_one_count_up, data_tx'length));
					write_to_uart <= '1';
					current_state <= wait_after_write_one;
				else
					current_state <= led_one_write;
				end if;

		  when wait_after_write_one =>
				current_state <= led_two_write;
		  						
		  when led_two_write =>
				if led_two_count_up /= reg_led_two_count_up and tx_full = '0' then					
					data_tx <=	std_logic_vector(to_unsigned(led_two_count_up, data_tx'length));
					write_to_uart <= '1';
					current_state <= wait_after_write_two;
				else
					current_state <= led_two_write;
				end if;

		  when wait_after_write_two =>
				current_state <= led_three_write;
				
		  when led_three_write =>
				if led_three_count_up /= reg_led_three_count_up and tx_full = '0' then					
					data_tx <=	std_logic_vector(to_unsigned(led_three_count_up, data_tx'length));
					write_to_uart <= '1';
					current_state <= wait_after_write_three;
				else
					current_state <= led_three_write;
				end if;
				
		  when wait_after_write_three =>
				current_state <= led_one_write;
				
		  when others =>
    end case;
	 end if;
end process;


  tx_led_uart: uart_tx 
  port map (            data_in => data_tx, 
                   write_buffer => write_to_uart,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud_4800,
                     serial_out => tx,
                    buffer_full => tx_full,
               buffer_half_full => tx_half_full,
                            clk => clk_in );






  reg_led_one_count: process(clk_in)
  begin
		if rising_edge(clk_in) then
			reg_led_one_count_up <= led_one_count_up;
		end if;
  end process reg_led_one_count;

  reg_led_two_count: process(clk_in)
  begin
		if rising_edge(clk_in) then
			reg_led_two_count_up <= led_two_count_up;
		end if;
  end process reg_led_two_count;

  reg_led_three_count: process(clk_in)
  begin
		if rising_edge(clk_in) then
			reg_led_three_count_up <= led_three_count_up;
		end if;
  end process reg_led_three_count;





end Behavioral;

