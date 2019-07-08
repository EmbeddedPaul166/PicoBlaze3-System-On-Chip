library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led8a_driver is
    Generic ( MAIN_CLK: natural:=6000000;                 -- main frequency in Hz
              CLKDIV_INTERNAL: boolean:=True);         -- 
    Port ( clk_in : in  STD_LOGIC;                      -- main_clk or slow_clk (external)
			  en_16_x_baud_4800 : in  STD_LOGIC;
           sseg : out  STD_LOGIC_VECTOR (6 downto 0);   -- active Low
           an : out  STD_LOGIC_VECTOR (2 downto 0);    -- active Low
           rx: in std_logic);
end led8a_driver;

architecture Behavioral of led8a_driver is

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
--
------------------------------------------------------------------------------------


constant DONTCARE: std_logic_vector(7 downto 0):="--------";
constant F_SLOW: natural:=500; -- display freq in Hz
constant H_PERIOD: natural:=MAIN_CLK/F_SLOW/2;
signal clkdiv_counter : natural range 0 to H_PERIOD :=0;
signal slow_clk: std_logic:='0';
signal digit: std_logic_vector(7 downto 0):=x"00";
signal one_hot,address: std_logic_vector(2 downto 0):="011";
signal seg: std_logic_vector(6 downto 0);

signal read_from_uart  : std_logic;
signal rx_data         : std_logic_vector(7 downto 0);
signal rx_data_present : std_logic;
signal rx_full         : std_logic;
signal rx_half_full    : std_logic;

signal a :  STD_LOGIC_VECTOR (7 downto 0) := x"00";       -- digit AN0
signal b :  STD_LOGIC_VECTOR (7 downto 0) := x"00";       -- digit AN1
signal c :  STD_LOGIC_VECTOR (7 downto 0) := x"00";       -- digit AN2
signal digit_address :  STD_LOGIC_VECTOR (1 downto 0) := "01";

type state is (idle, data_read, data_received, change_address);
signal current_state : state := idle;

begin
 
FSM : process(clk_in, current_state, rx_data, rx_data_present, digit_address) is
begin	 
	 if rising_edge(clk_in) then
	 read_from_uart <= '0';	
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
				if digit_address = "01" then
					a <= rx_data;
				elsif digit_address = "10" then
					b <= rx_data;
				elsif digit_address = "11" then
					c <= rx_data;
				end if;				
				current_state <= change_address;
					  
				
		  when change_address =>
				if digit_address = "01" then
						digit_address <= "10";
				elsif digit_address = "10" then
						digit_address <= "11";
				elsif digit_address = "11" then
						digit_address <= "01";
				end if;
				current_state <= idle;
			
		  when others =>
				
    end case;
	 end if;
end process;



-- outputs
an_out: an <= one_hot;
sseg_out: sseg <= not(seg);
--

  receive: uart_rx 
  port map (            serial_in => rx,
                         data_out => rx_data,
                      read_buffer => read_from_uart,
                     reset_buffer => '0',
                     en_16_x_baud => en_16_x_baud_4800,
              buffer_data_present => rx_data_present,
                      buffer_full => rx_full,
                 buffer_half_full => rx_half_full,
                              clk => clk_in );  

 addr_reg: process(slow_clk)
 begin
     if rising_edge(slow_clk) then 
         one_hot <= one_hot(1 downto 0) & one_hot(2);
     end if;    
 end process;
 address <= one_hot;

 data_mux: with address select
 digit <= a when "011",
          b when "101",
          c when "110",
          DONTCARE when others;

 sseg_dec: with digit select                
 seg <= "1111110" when "00000000",			  --        0
		  "0110000" when "00000001",          --      -----
        "1101101" when "00000010",          --    5|     |1
        "1111001" when "00000011",          --     |  6  |
        "0110011" when "00000100",          --      -----
        "1011011" when "00000101",          --    4|     |2
        "1011111" when "00000110",          --     |     |
        "1110000" when "00000111",          --      -----
        "1111111" when "00001000",          --        3
        "1111011" when "00001001",
        "0000000" when others;


-- clock signals
 clkdiv_true: if CLKDIV_INTERNAL generate
   process(clk_in) begin
     if rising_edge(clk_in) then 
       if clkdiv_counter=H_PERIOD-1 then
         clkdiv_counter <= 0;
         slow_clk <= not slow_clk;
       else 
         clkdiv_counter <= clkdiv_counter+1;
       end if;
     end if;
   end process;
 end generate;

 clkdiv_false: if not CLKDIV_INTERNAL generate
   slow_clk <= clk_in;
 end generate;

end Behavioral;