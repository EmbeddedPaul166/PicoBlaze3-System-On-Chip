library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_counter is
    Port ( clk_in : in  std_logic;
			  en_16_x_baud_4800 : in  std_logic;
			  led_one : in  std_logic;
           led_two : in  std_logic;
           led_three : in  std_logic;
			  rx : in  std_logic;
           tx : out  std_logic);
end pwm_counter;

architecture Behavioral of pwm_counter is

component uart_tx
	Port (data_in : in std_logic_vector(7 downto 0);
         write_buffer : in std_logic;
         reset_buffer : in std_logic;
         en_16_x_baud : in std_logic;
         serial_out : out std_logic;
         buffer_full : out std_logic;
         buffer_half_full : out std_logic;
         clk : in std_logic);
end component;
	 
component uart_rx
	Port (serial_in : in std_logic;
         data_out : out std_logic_vector(7 downto 0);
         read_buffer : in std_logic;
         reset_buffer : in std_logic;
         en_16_x_baud : in std_logic;
         buffer_data_present : out std_logic;
         buffer_full : out std_logic;
         buffer_half_full : out std_logic;
         clk : in std_logic);
end component;

constant total_signal_count : integer range 0 to 255 := 255;

signal write_to_uart : std_logic;
signal tx_full : std_logic;
signal tx_half_full : std_logic;
signal data_tx : std_logic_vector(7 downto 0);

signal read_from_uart : std_logic;
signal rx_data : std_logic_vector(7 downto 0);
signal rx_data_present : std_logic;
signal rx_full : std_logic;
signal rx_half_full : std_logic;

signal led_one_count_uptime : integer range 0 to 255 := 0;
signal led_two_count_uptime : integer range 0 to 255 := 0;
signal led_three_count_uptime : integer range 0 to 255 := 0;

signal reg_led_one_count_uptime : integer range 0 to 255 := 0;
signal reg_led_two_count_uptime : integer range 0 to 255 := 0;
signal reg_led_three_count_uptime : integer range 0 to 255 := 0;

signal led_address : integer range 0 to 3 := 0;

signal rst_one : std_logic;
signal rst_two : std_logic;
signal rst_three : std_logic;

signal led_one_shift_reg : std_logic_vector(1 downto 0) := (others => '0');
signal led_two_shift_reg : std_logic_vector(1 downto 0) := (others => '0');
signal led_three_shift_reg : std_logic_vector(1 downto 0) := (others => '0');

signal led_one_counter_enable : std_logic := '0';
signal led_two_counter_enable : std_logic := '0';
signal led_three_counter_enable : std_logic := '0';

signal pwm_one_max_count_reached : std_logic := '0';
signal pwm_two_max_count_reached : std_logic := '0';
signal pwm_three_max_count_reached : std_logic := '0';


type state is (wait_for_address, data_read_address, address_received, send_led_pwm_value);
signal current_state : state := send_led_pwm_value;

begin

	FSM : process(clk_in, current_state, reg_led_one_count_uptime, reg_led_two_count_uptime, reg_led_three_count_uptime) is
	begin
		if rising_edge(clk_in) then
			read_from_uart <= '0';
			write_to_uart <= '0';
			case current_state is
				
				when wait_for_address =>
					if rx_data_present = '1' then
						current_state <= data_read_address;
					else
						current_state <= wait_for_address;
					end if;
					
				when data_read_address =>
					read_from_uart <= '1';				
					current_state <= address_received;
					
				when address_received =>
					led_address <= to_integer(unsigned(rx_data));
					current_state <= send_led_pwm_value;
				
				when send_led_pwm_value =>
					if led_address = 1 then
						data_tx <=	std_logic_vector(to_unsigned(reg_led_one_count_uptime, data_tx'length));
						write_to_uart <= '1';
					elsif led_address = 2 then
						data_tx <=	std_logic_vector(to_unsigned(reg_led_two_count_uptime, data_tx'length));
						write_to_uart <= '1';
					elsif led_address = 3 then
						data_tx <=	std_logic_vector(to_unsigned(reg_led_three_count_uptime, data_tx'length));
						write_to_uart <= '1';
					end if;
					current_state <= wait_for_address;
					
				when others =>
		
			end case;
		end if;	
	end process;

	pwm_one_duty_counter: process(clk_in, rst_one)
	begin
		if rst_one ='1' then
			led_one_count_uptime <= 0;
		elsif rising_edge(clk_in) then
			if led_one_counter_enable = '0' then
				led_one_count_uptime <= 0;
				pwm_one_max_count_reached<= '0';
			elsif led_one_counter_enable = '1' then			
				if led_one_count_uptime = 255 then
					pwm_one_max_count_reached <= '1';
				else
					led_one_count_uptime <= led_one_count_uptime + 1;
				end if;
			end if;
		end if;
	end process;
	
	led_one_edge_detection: process(clk_in)
	begin
		if rising_edge(clk_in) then
			led_one_shift_reg(1) <= led_one;
			led_one_shift_reg(0) <= led_one_shift_reg(1);
			if led_one_shift_reg(1) = '1' and led_one_shift_reg(0) = '0' then
				led_one_counter_enable <= '1';
			elsif led_one_shift_reg(1) = '0' and led_one_shift_reg(0) = '1' then
				led_one_counter_enable <= '0';
				reg_led_one_count_uptime <= led_one_count_uptime;
			elsif pwm_one_max_count_reached = '1' then
				reg_led_one_count_uptime <= led_one_count_uptime;
			end if;
		end if;
	end process;
	
	pwm_two_duty_counter: process(clk_in, rst_two)
	begin
		if rst_two ='1' then
			led_two_count_uptime <= 0;
		elsif rising_edge(clk_in) then
			if led_two_counter_enable = '0' then
				led_two_count_uptime <= 0;
				pwm_two_max_count_reached<= '0';
			elsif led_two_counter_enable = '1' then			
				if led_two_count_uptime = 255 then
					pwm_two_max_count_reached <= '1';	
				else
					led_two_count_uptime <= led_two_count_uptime + 1;
				end if;
			end if;
		end if;
	end process;
	
	led_two_edge_detection: process(clk_in)
	begin
		if rising_edge(clk_in) then
			led_two_shift_reg(1) <= led_two;
			led_two_shift_reg(0) <= led_two_shift_reg(1);
			if led_two_shift_reg(1) = '1' and led_two_shift_reg(0) = '0' then
				led_two_counter_enable <= '1';
			elsif led_two_shift_reg(1) = '0' and led_two_shift_reg(0) = '1' then
				led_two_counter_enable <= '0';
				reg_led_two_count_uptime <= led_two_count_uptime;
			elsif pwm_two_max_count_reached = '1' then
				reg_led_two_count_uptime <= led_two_count_uptime;
			end if;
		end if;
	end process;
	
	pwm_three_duty_counter: process(clk_in, rst_three)
	begin
		if rst_three ='1' then
			led_three_count_uptime <= 0;
		elsif rising_edge(clk_in) then
			if led_three_counter_enable = '0' then
				led_three_count_uptime <= 0;
				pwm_three_max_count_reached<= '0';
			elsif led_three_counter_enable = '1' then			
				if led_three_count_uptime = 255 then
					pwm_three_max_count_reached <= '1';
				else
					led_three_count_uptime <= led_three_count_uptime + 1;
				end if;
			end if;
		end if;
	end process;
	
	led_three_edge_detection: process(clk_in)
	begin
		if rising_edge(clk_in) then
			led_three_shift_reg(1) <= led_three;
			led_three_shift_reg(0) <= led_three_shift_reg(1);
			if led_three_shift_reg(1) = '1' and led_three_shift_reg(0) = '0' then
				led_three_counter_enable <= '1';
			elsif led_three_shift_reg(1) = '0' and led_three_shift_reg(0) = '1' then
				led_three_counter_enable <= '0';
				reg_led_three_count_uptime <= led_three_count_uptime;
			elsif pwm_three_max_count_reached = '1' then
				reg_led_three_count_uptime <= led_three_count_uptime;
			end if;
		end if;
	end process;

	tx_pwm_gauge: uart_tx 
	port map (data_in => data_tx, 
            write_buffer => write_to_uart,
            reset_buffer => '0',
            en_16_x_baud => en_16_x_baud_4800,
            serial_out => tx,
            buffer_full => tx_full,
            buffer_half_full => tx_half_full,
            clk => clk_in );


	rx_pwm_gauge: uart_rx 
	port map (serial_in => rx,
             data_out => rx_data,
             read_buffer => read_from_uart,
             reset_buffer => '0',
             en_16_x_baud => en_16_x_baud_4800,
             buffer_data_present => rx_data_present,
             buffer_full => rx_full,
             buffer_half_full => rx_half_full,
             clk => clk_in );  

end Behavioral;

