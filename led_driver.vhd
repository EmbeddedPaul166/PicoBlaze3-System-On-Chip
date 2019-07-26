library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_driver is
    Port ( clk_in : in  STD_LOGIC;
			  en_16_x_baud_4800 : in  std_logic;
           rx : in  STD_LOGIC;
           led_one : out  STD_LOGIC;
           led_two : out  STD_LOGIC;
           led_three : out  STD_LOGIC;
			  led_one_count_uptime : out  integer range 0 to 255;
           led_two_count_uptime : out  integer range 0 to 255;
           led_three_count_uptime : out  integer range 0 to 255);
end led_driver;

architecture Behavioral of led_driver is

component uart_rx
	Port ( serial_in : in std_logic;
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

signal pwm_one_value : integer range 0 to 255 := 0;
signal pwm_two_value : integer range 0 to 255 := 0;
signal pwm_three_value : integer range 0 to 255 := 0;

signal pwm_one_count : integer range 0 to 255 :=0;
signal pwm_two_count : integer range 0 to 255 :=0;
signal pwm_three_count : integer range 0 to 255 :=0;

signal rst_one    : std_logic := '0';
signal rst_two    : std_logic := '0';
signal rst_three    : std_logic := '0';

signal led_one_connect    : std_logic := '0';
signal led_two_connect    : std_logic := '0';
signal led_three_connect    : std_logic := '0';

signal led_address :  STD_LOGIC_VECTOR (1 downto 0) := "01";

type state is (idle, data_read, data_received, change_address);
signal current_state : state := idle;

begin

	led_one <= led_one_connect;
	led_two <= led_two_connect;
	led_three <= led_three_connect;

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
		elsif rising_edge(clk_in) then
			if pwm_one_count = 255 then
				pwm_one_count <= 0;
			else
				if pwm_one_count <= pwm_one_value then
					led_one_connect <= '1';				
				else
					led_one_connect <= '0';
				end if;
				pwm_one_count <= pwm_one_count + 1;
			end if;
		end if;
	end process;
	
	--send_value_pwm_one: process(pwm_one_count)
	--begin
		--if pwm_one_count = pwm_one_value then
			--led_one_count_uptime <= pwm_one_count;
		--end if;
	--end process;
	
	pwm_two_counter: process(clk_in, rst_two)
	begin
		if rst_two ='1' then
			pwm_two_count <= 0;
		elsif rising_edge(clk_in) then
			if pwm_two_count = 255 then
				pwm_two_count <= 0;
			else
				if pwm_two_count <= pwm_two_value then
					led_two_connect <= '1';
				else
					led_two_connect <= '0';
				end if;			  
				pwm_two_count <= pwm_two_count + 1;
			end if;
		end if;
	end process;

	--send_value_pwm_two: process(pwm_two_count)
	--begin
		--if pwm_two_count = pwm_two_value then
			--led_two_count_uptime <= pwm_two_count;
		--end if;
	--end process;

	pwm_three_counter: process(clk_in, rst_three)
	begin
		if rst_three ='1' then
			pwm_three_count <= 0;
		elsif rising_edge(clk_in) then
			if pwm_three_count = 255 then
				pwm_three_count <= 0;
			else
				if pwm_three_count <= pwm_three_value then
					led_three_connect <= '1';
				else				
					led_three_connect <= '0';
				end if;			  
				pwm_three_count <= pwm_three_count + 1;
			end if;
		end if;
	end process;

	--send_value_pwm_three: process(pwm_three_count)
	--begin
		--if pwm_three_count = pwm_three_value then
			--led_three_count_uptime <= pwm_three_count;
		--end if;
	--end process;

	led_one_count_uptime <= pwm_one_value;
	led_two_count_uptime <= pwm_two_value;
	led_three_count_uptime <= pwm_three_value;

	receive: uart_rx 
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

