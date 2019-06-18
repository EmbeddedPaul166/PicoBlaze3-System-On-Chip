library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led8a_driver is
    Generic ( MAIN_CLK: natural:=100E6;                 -- main frequency in Hz
              CLKDIV_INTERNAL: boolean:=True);         -- 
    Port ( clk_in : in  STD_LOGIC;                      -- main_clk or slow_clk (external)
           sseg : out  STD_LOGIC_VECTOR (2 downto 0);   -- active Low
           an : out  STD_LOGIC_VECTOR (7 downto 0);    -- active Low
			  tx: out std_logic;
           rx: in std_logic);
end led8a_driver;

architecture Behavioral of led8a_driver is

--
-- declaration of UART transmitter with integral 16 byte FIFO buffer
--
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
signal one_hot,address: std_logic_vector(7 downto 0):=x"FE";
signal seg: std_logic_vector(2 downto 0);

signal baud_count      : integer range 0 to 127 :=0;
signal en_16_x_baud    : std_logic;
signal out_port        : std_logic_vector(7 downto 0);
signal write_to_uart   : std_logic;
signal tx_full         : std_logic;
signal tx_half_full    : std_logic;
signal read_from_uart  : std_logic;
signal rx_data         : std_logic_vector(7 downto 0);
signal rx_data_present : std_logic;
signal rx_full         : std_logic;
signal rx_half_full    : std_logic;

signal a : STD_LOGIC_VECTOR (7 downto 0);       -- digit AN0
signal b : STD_LOGIC_VECTOR (7 downto 0);       -- digit AN1
signal c : STD_LOGIC_VECTOR (7 downto 0);       -- digit AN2
signal d : STD_LOGIC_VECTOR (7 downto 0);       -- digit AN3 
signal e : STD_LOGIC_VECTOR (7 downto 0);       -- digit AN4
signal f : STD_LOGIC_VECTOR (7 downto 0);       -- digit AN5
signal g : STD_LOGIC_VECTOR (7 downto 0);       -- digit AN6
signal h : STD_LOGIC_VECTOR (7 downto 0);       -- digit AN7

begin

-- outputs
an_out: an <= one_hot;
sseg_out: sseg <= not(seg);
--

  transmit: uart_tx 
  port map (            data_in => out_port, 
                   write_buffer => write_to_uart,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud,
                     serial_out => tx,
                    buffer_full => tx_full,
               buffer_half_full => tx_half_full,
                            clk => clk_in );

  receive: uart_rx 
  port map (            serial_in => rx,
                         data_out => rx_data,
                      read_buffer => read_from_uart,
                     reset_buffer => '0',
                     en_16_x_baud => en_16_x_baud,
              buffer_data_present => rx_data_present,
                      buffer_full => rx_full,
                 buffer_half_full => rx_half_full,
                              clk => clk_in );  

  baud_timer: process(clk)
  begin
    if clk'event and clk='1' then
      if baud_count=9 then
           baud_count <= 0;
         en_16_x_baud <= '1';
       else
           baud_count <= baud_count + 1;
         en_16_x_baud <= '0';
      end if;
    end if;
  end process baud_timer;

 addr_reg: process(slow_clk)
 begin
     if rising_edge(slow_clk) then 
         one_hot <= one_hot(6 downto 0) & one_hot(7);
     end if;    
 end process;
 address <= one_hot;

 data_mux: with address select
 digit <= a when x"fe",
          b when x"fd",
          c when x"fb",
          d when x"f7",
          e when x"ef",
          f when x"df",
          g when x"bf",
          h when x"7f",
          DONTCARE when others;

 sseg_dec: with digit select            --        0
  seg <= "110" when x"31",          --      -----
         "011" when x"32",          --    5|     |1
         "111" when x"33",          --     |  6  |
         "110" when x"34",          --      -----
         "101" when x"35",          --    4|     |2
         "101" when x"36",          --     |     |
         "111" when x"37",          --      -----
         "111" when x"38",          --        3
         "111" when x"39",
         "111" when x"61",
         "100" when x"62",				--CORRECT THIS FOR DESIRED FAVLUES
         "001" when x"63",
         "110" when x"64",
         "001" when x"65",
         "001" when x"66",
         "111" when x"30",
         "000" when others;

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