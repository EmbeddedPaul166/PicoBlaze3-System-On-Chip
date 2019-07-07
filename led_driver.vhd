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
           led_three : out  STD_LOGIC;
			  led_one_count_up : out  integer range 0 to 255;
           led_two_count_up : out  integer range 0 to 255;
           led_three_count_up : out  integer range 0 to 255);
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

signal read_from_uart  : std_logic;
signal rx_data         : std_logic_vector(7 downto 0);
signal rx_data_present : std_logic;
signal rx_full         : std_logic;
signal rx_half_full    : std_logic;

signal pwm_one_value : integer range 0 to 255 :=255;
signal pwm_two_value : integer range 0 to 255 :=255;
signal pwm_three_value : integer range 0 to 255 :=255;

signal pwm_one_count : integer range 0 to 255 :=0;
signal pwm_two_count : integer range 0 to 255 :=0;
signal pwm_three_count : integer range 0 to 255 :=0;

signal rst_one    : std_logic := '0';
signal rst_two    : std_logic := '0';
signal rst_three    : std_logic := '0';

signal led_address :  STD_LOGIC_VECTOR (1 downto 0) := "01";

type state is (idle, data_read, data_received, change_address);
signal current_state : state := idle;

begin

FSM : process(clk_in, current_state, rx_data, rx_data_present, led_address) is
begin	 
	 if rising_edge(clk_in) then
	 read_from_uart <= '0';
	 rst_one <= '0';
	 rst_two <= '0';
	 rst_three <= '0';	 
    case current_state is
		  
		  when idle =>
		  
				if rx_data_present = '1' then
					current_state <= data_read;
				else
					current_state <= idle;
				end if;
				
		  when data_read =>
		  
				read_from_uart <= '1';				
				current_state <= data_received;
				
        when data_received =>
				if led_address = "01" then
					pwm_one_value <= to_integer(unsigned(rx_data));
					rst_one <= '1';
				elsif led_address = "10" then
					pwm_two_value <= to_integer(unsigned(rx_data));
					rst_two <= '1';
				elsif led_address = "11" then
					pwm_three_value <= to_integer(unsigned(rx_data));
					rst_three <= '1';
				end if;				
				current_state <= change_address;
					  
				
		  when change_address =>
				if led_address = "01" then
						led_address <= "10";
				elsif led_address = "10" then
						led_address <= "11";
				elsif led_address = "11" then
						led_address <= "01";
				end if;
				current_state <= idle;
			
		  when others =>
				
    end case;
	 end if;
end process;


  pwm_one_counter: process(clk_in, rst_one)
  begin
	 if rst_one ='1' then
		pwm_one_count <= 0;
    elsif clk_in'event and clk_in='1' then
      if pwm_one_count = 255 then
           pwm_one_count <= 0;         
       else
           pwm_one_count <= pwm_one_count + 1;
			  if pwm_one_count <= pwm_one_value then
				led_one <= '1';
			  else
				led_one_count_up <= pwm_one_count;
				led_one <= '0';
			  end if;          
      end if;
    end if;
  end process pwm_one_counter;

  pwm_two_counter: process(clk_in, rst_two)
  begin
	 if rst_two ='1' then
		pwm_two_count <= 0;
    elsif clk_in'event and clk_in='1' then
      if pwm_two_count = 255 then
           pwm_two_count <= 0;         
       else
           pwm_two_count <= pwm_two_count + 1;
			  if pwm_two_count <= pwm_two_value then
				led_two <= '1';
			  else
			   led_two_count_up <= pwm_two_count;
				led_two <= '0';
			  end if;        
      end if;
    end if;
  end process pwm_two_counter;

  pwm_three_counter: process(clk_in, rst_three)
  begin
	 if rst_three ='1' then
		pwm_three_count <= 0;
    elsif clk_in'event and clk_in='1' then
      if pwm_three_count = 255 then
           pwm_three_count <= 0;          
       else
           pwm_three_count <= pwm_three_count + 1;
			  if pwm_three_count <= pwm_three_value then
				led_three <= '1';
			  else
			   led_three_count_up <= pwm_three_count;
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

