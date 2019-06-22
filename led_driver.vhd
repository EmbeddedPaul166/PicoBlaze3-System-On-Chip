----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:51:59 06/19/2019 
-- Design Name: 
-- Module Name:    led_driver - Behavioral 
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

entity led_driver is
    Port ( clk_in : in  STD_LOGIC;
			  en_16_x_baud_9600 : in  std_logic;
           rx : in  STD_LOGIC;
           led_one : out  STD_LOGIC;
           led_two : out  STD_LOGIC;
           led_three : out  STD_LOGIC);
end led_driver;

architecture Behavioral of led_driver is

--
-- declaration of UART Receiver with integral 16 byte FIFO buffer
--
  component uart_rx
    Port (            serial_in : in std_logic;
                       data_out : out std_logic_vector(7 downto 0);
                    read_buffer : in std_logic;
                   reset_buffer : in std_logic;
                   en_16_x_baud : in std_logic;
            buffer_data_present : out std_logic;
                    buffer_full : out std_logic;
               buffer_half_full : out std_logic;
                            clk : in std_logic);
  end component;

signal read_from_uart  : std_logic := '0';
signal rx_data         : std_logic_vector(7 downto 0);
signal rx_data_present : std_logic;
signal rx_full         : std_logic;
signal rx_half_full    : std_logic;

signal pwm_one_value : integer range 0 to 127 :=127;
signal pwm_two_value : integer range 0 to 127 :=127;
signal pwm_three_value : integer range 0 to 127 :=127;

signal pwm_one_count : integer range 0 to 127 :=0;
signal pwm_two_count : integer range 0 to 127 :=0;
signal pwm_three_count : integer range 0 to 127 :=0;

signal rst_one    : std_logic := '0';
signal rst_two    : std_logic := '0';
signal rst_three    : std_logic := '0';

signal digit_address : std_logic_vector(1 downto 0) := "00";

signal slow_clk    : std_logic := '0';

type state is (address_received, data_received, no_data_received);
signal current_state, previous_state: state := address_received;

begin

clk_div_by_2: process(clk_in)
begin
	if rising_Edge(clk_in) then
		slow_clk <= not slow_clk;
	end if;
end process;

 
FSM : process(clk_in, current_state, rx_data, rx_data_present, digit_address) is
begin
	 if rising_Edge(clk_in) then
	 read_from_uart <= '0';
	 rst_one <= '0';
	 rst_two <= '0';
	 rst_three <= '0';	 
	 
    case current_state is

		  when address_received =>	  
				if rx_data_present = '0' then
					previous_state <= current_state;
					current_state <= no_data_received;
				else
					digit_address <= rx_data(1 downto 0);
					read_from_uart <= '1';
					previous_state <= current_state;
					current_state <= data_received;
				end if;
				
        when data_received =>			
				if rx_data_present = '0' then
					previous_state <= current_state;
					current_state <= no_data_received;
				elsif digit_address = "01" then
					pwm_one_value <= to_integer(unsigned(rx_data));
					rst_one <= '1';
					read_from_uart <= '1';
					previous_state <= current_state;
					current_state <= address_received;
				elsif digit_address = "10" then
					pwm_two_value <= to_integer(unsigned(rx_data));
					rst_two <= '1';
					read_from_uart <= '1';
					previous_state <= current_state;
					current_state <= address_received;
				elsif digit_address = "11" then
					pwm_three_value <= to_integer(unsigned(rx_data));
					rst_three <= '1';
					read_from_uart <= '1';
					previous_state <= current_state;
					current_state <= address_received;
				end if;
 
        when no_data_received =>
            if rx_data_present = '1' then
					if previous_state = address_received then
						previous_state <= current_state;
						current_state <= address_received;
					elsif previous_state = data_received then
						previous_state <= current_state;
						current_state <= data_received;
					end if;
            end if;
		  when others =>
    end case;
	 end if;
end process;

  pwm_one_counter: process(slow_clk, rst_one)
  begin
	 if rst_one ='1' then
		pwm_one_count <= 0;
    elsif slow_clk'event and slow_clk='1' then
      if pwm_one_count = 127 then
           pwm_one_count <= 0;
           
       else
           pwm_one_count <= pwm_one_count + 1;
			  if pwm_one_count >= pwm_one_value then
				led_one <= '1';
			  else
				led_one <= '0';
			  end if;
           
      end if;
    end if;
  end process pwm_one_counter;

  pwm_two_counter: process(slow_clk, rst_two)
  begin
	 if rst_two ='1' then
		pwm_two_count <= 0;
    elsif slow_clk'event and slow_clk='1' then
      if pwm_two_count = 127 then
           pwm_two_count <= 0;
           
       else
           pwm_two_count <= pwm_two_count + 1;
			  if pwm_two_count >= pwm_two_value then
				led_two <= '1';
			  else
				led_two <= '0';
			  end if;
           
      end if;
    end if;
  end process pwm_two_counter;

  pwm_three_counter: process(slow_clk, rst_three)
  begin
	 if rst_three ='1' then
		pwm_three_count <= 0;
    elsif slow_clk'event and slow_clk='1' then
      if pwm_three_count = 127 then
           pwm_three_count <= 0;
           
       else
           pwm_three_count <= pwm_three_count + 1;
			  if pwm_three_count >= pwm_three_value then
				led_three <= '1';
			  else
				led_three <= '0';
			  end if;
           
      end if;
    end if;
  end process pwm_three_counter;
  
  receive: uart_rx 
  port map (            serial_in => rx,
                         data_out => rx_data,
                      read_buffer => read_from_uart,
                     reset_buffer => '0',
                     en_16_x_baud => en_16_x_baud_9600,
              buffer_data_present => rx_data_present,
                      buffer_full => rx_full,
                 buffer_half_full => rx_half_full,
                              clk => clk_in );  



end Behavioral;

