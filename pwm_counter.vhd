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
           led_one : in  STD_LOGIC;
           led_two : in  STD_LOGIC;
           led_three : in  STD_LOGIC;
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

signal           baud_count_9600 : integer range 0 to 127 :=0;
signal         en_16_x_baud_9600 : std_logic := '0';
signal             write_to_uart : std_logic;
signal                   tx_full : std_logic;
signal              tx_half_full : std_logic;
signal                   data_tx : std_logic_vector(7 downto 0);

signal pwm_one_value : integer range 0 to 255 :=255;
signal pwm_two_value : integer range 0 to 255 :=255;
signal pwm_three_value : integer range 0 to 255 :=255;

signal pwm_one_value_up : integer range 0 to 255 :=0;
signal pwm_two_value_up : integer range 0 to 255 :=0;
signal pwm_three_value_up : integer range 0 to 255 :=0;

signal led_one_fill_percentege : integer range 0 to 255 :=0;
signal led_two_fill_percentege : integer range 0 to 255 :=0;
signal led_three_fill_percentege : integer range 0 to 255 :=0;

signal pwm_one_count : integer range 0 to 255 :=0;
signal pwm_two_count : integer range 0 to 255 :=0;
signal pwm_three_count : integer range 0 to 255 :=0;

signal pwm_one_fin    : std_logic := '0';
signal pwm_two_fin    : std_logic := '0';
signal pwm_three_fin  : std_logic := '0';

signal rst_one : std_logic :='0';
signal rst_two : std_logic :='0';
signal rst_three : std_logic :='0';

type state is (led_one_write, led_two_write, led_three_write, write_data);
signal current_state : state := led_one_write;

begin
 
FSM : process(current_state, data_tx, led_one_fill_percentege, led_two_fill_percentege, led_three_fill_percentege, pwm_one_value_up, pwm_two_value_up ,pwm_three_value_up) is
begin
	 if rising_edge(clk_in) then
	 write_to_uart <= '0';	 
    case current_state is
	
		  when led_one_write =>
				data_tx <=	std_logic_vector(to_unsigned(pwm_one_value_up, data_tx'length));
				current_state <= led_two_write;
		  when led_two_write =>
				data_tx <= std_logic_vector(to_unsigned(pwm_two_value_up, data_tx'length));
				current_state <= led_three_write;
		  when led_three_write => 
				data_tx <= std_logic_vector(to_unsigned(pwm_three_value_up, data_tx'length));
				current_state <= write_data;
		  when write_data => 
				write_to_uart <= '1';
				current_state <= led_one_write;
		  when others =>
    end case;
	 end if;
end process;


  tx_led_uart: uart_tx 
  port map (            data_in => data_tx, 
                   write_buffer => write_to_uart,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud_9600,
                     serial_out => tx,
                    buffer_full => tx_full,
               buffer_half_full => tx_half_full,
                            clk => clk_in );

  baud_timer_9600: process(clk_in)
  begin
    if clk_in'event and clk_in='1' then
      if baud_count_9600=38 then
           baud_count_9600 <= 0;
         en_16_x_baud_9600 <= '1';
       else
           baud_count_9600 <= baud_count_9600 + 1;
         en_16_x_baud_9600 <= '0';
      end if;
    end if;
  end process baud_timer_9600;

  pwm_one_counter: process(clk_in, rst_one)
  begin
	 if rst_one ='1' then
		pwm_one_count <= 0;
    elsif clk_in'event and clk_in='1' then
		pwm_one_fin <= '0';
      if led_one = '1' then
			if pwm_one_value_up = 255 then
				pwm_one_value_up <= 0;
				pwm_one_fin <= '1';
			else
				pwm_one_value_up <= pwm_one_value_up + 1;
			end if;
		end if;
    end if;
  end process pwm_one_counter;

  pwm_two_counter: process(clk_in, rst_two)
  begin
	 if rst_two ='1' then
		pwm_two_count <= 0;
    elsif clk_in'event and clk_in='1' then
		pwm_two_fin <= '0';
      if led_two = '1' then
			if pwm_two_value_up = 255 then
				pwm_two_value_up <= 0;
				pwm_two_fin <= '1';
			else
				pwm_two_value_up <= pwm_two_value_up + 1;
			end if;		
		end if;
    end if;
  end process pwm_two_counter;

  pwm_three_counter: process(clk_in, rst_three)
  begin
	 if rst_three ='1' then
		pwm_three_count <= 0;
    elsif clk_in'event and clk_in='1' then
		pwm_three_fin <= '0';
      if led_three = '1' then
			if pwm_three_value_up = 255 then
				pwm_three_value_up <= 0;
				pwm_three_fin <= '1';
			else
				pwm_three_value_up <= pwm_three_value_up + 1;
			end if;			
		end if;
    end if;
  end process pwm_three_counter;

end Behavioral;

