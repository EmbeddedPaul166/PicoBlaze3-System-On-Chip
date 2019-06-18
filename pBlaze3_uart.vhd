--
-- KCPSM3 reference design - Real Time Clock with UART communications
--
-- Ken Chapman - Xilinx Ltd - October 2003
--
-- The design demonstrates the following:-
--           Connection of KCPSM3 to Program ROM
--           Connection of UART macros supplied with PicoBlaze with
--                Baud rate generation
--           Definition of input and output ports with 
--                Minimum decoding
--                Pipelining where appropriate
--           Interrupt circuit with
--                Simple fixed period timer
--                Automatic clearing using interrupt acknowledge from KCPSM3
--
-- The design is set up for a 55MHz system clock and UART communications rate of 38400 baud.
-- Please read design documentation to modify to your own requirements.
--
------------------------------------------------------------------------------------
--
-- NOTICE:
--
-- Copyright Xilinx, Inc. 2003.   This code may be contain portions patented by other 
-- third parties.  By providing this core as one possible implementation of a standard,
-- Xilinx is making no representation that the provided implementation of this standard 
-- is free from any claims of infringement by any third party.  Xilinx expressly 
-- disclaims any warranty with respect to the adequacy of the implementation, including 
-- but not limited to any warranty or representation that the implementation is free 
-- from claims of any third party.  Furthermore, Xilinx is providing this core as a 
-- courtesy to you and suggests that you contact all third parties to obtain the 
-- necessary rights to use this implementation.
--
------------------------------------------------------------------------------------
--
-- Library declarations
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
------------------------------------------------------------------------------------
--
--
entity pBlaze3_uart is
    Port (    tx_user : out std_logic;
              rx_user : in std_logic;
				  tx_8seg : out std_logic;
				  tx_led : out std_logic;
              rx_counter_led : in std_logic;
              clk : in std_logic);
    end pBlaze3_uart;
--
------------------------------------------------------------------------------------
--
-- Start of test architecture
--
architecture Behavioral of pBlaze3_uart is
--
------------------------------------------------------------------------------------
--
-- declaration of KCPSM3
--
  component kcpsm3 
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
--
-- declaration of program ROM
--
  component uclock
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                    clk : in std_logic);
    end component;
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
--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
signal address         : std_logic_vector(9 downto 0);
signal instruction     : std_logic_vector(17 downto 0);
signal port_id         : std_logic_vector(7 downto 0);
signal out_port_user   : std_logic_vector(7 downto 0);
signal out_port_8seg   : std_logic_vector(7 downto 0);
signal out_port_led   : std_logic_vector(7 downto 0);
signal in_port         : std_logic_vector(7 downto 0);
signal write_strobe    : std_logic;
signal read_strobe     : std_logic;
signal interrupt       : std_logic;
signal interrupt_ack   : std_logic;
--
-- Signals for connection of peripherals
--
signal uart_status_port_user : std_logic_vector(7 downto 0);
signal uart_status_port_8seg : std_logic_vector(7 downto 0);
signal uart_status_port_led : std_logic_vector(7 downto 0);
signal uart_status_port_counter_led : std_logic_vector(7 downto 0);
--
-- Signals to form an timer generating an interrupt every microsecond
--
signal timer_count   : integer range 0 to 63 :=0;
signal timer_pulse   : std_logic;
--
-- Signals for UART connections
--
signal          baud_count_38400 : integer range 0 to 127 :=0;
signal        en_16_x_baud_38400 : std_logic;
signal        write_to_uart_user : std_logic;
signal              tx_full_user : std_logic;
signal         tx_half_full_user : std_logic;
signal       read_from_uart_user : std_logic;
signal              rx_data_user : std_logic_vector(7 downto 0);
signal      rx_data_present_user : std_logic;
signal              rx_full_user : std_logic;
signal         rx_half_full_user : std_logic;

signal           baud_count_9600 : integer range 0 to 127 :=0;
signal              en_16_x_9600 : std_logic;

signal        write_to_uart_8seg : std_logic;
signal              tx_full_8seg : std_logic;
signal         tx_half_full_8seg : std_logic;

signal       write_to_uart_led : std_logic;
signal             tx_full_led : std_logic;
signal        tx_half_full_led : std_logic;

signal            read_from_uart_counter_led : std_logic;
signal                   rx_data_counter_led : std_logic_vector(7 downto 0);
signal           rx_data_present_counter_led : std_logic;
signal                   rx_full_counter_led : std_logic;
signal              rx_half_full_counter_led : std_logic;
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin
  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 and the program memory 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  processor: kcpsm3
    port map(      address => address,
               instruction => instruction,
                   port_id => port_id,
              write_strobe => write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     reset => '0',
                       clk => clk);
 
  program_rom: uclock
    port map(      address => address,
               instruction => instruction,
                       clk => clk);

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Interrupt 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- Interrupt is a generated once every 55 clock cycles to provide a 1us reference. 
  -- Interrupt is automatically cleared by interrupt acknowledgment from KCPSM3.
  --

  Timer: process(clk)
  begin

    if clk'event and clk='1' then
      
      if timer_count=54 then
         timer_count <= 0;
         timer_pulse <= '1';
       else
         timer_count <= timer_count + 1;
         timer_pulse <= '0';
      end if;

      if interrupt_ack = '1' then
         interrupt <= '0';
       elsif timer_pulse = '1' then 
         interrupt <= '1';
        else
         interrupt <= interrupt;
      end if;
     
    end if;
    
  end process Timer;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- UART FIFO status signals to form a bus
  --

  uart_status_port_user <= "000" & rx_data_present_user & rx_full_user & rx_half_full_user & tx_full_user & tx_half_full_user;
  uart_status_port_8seg <= "000000" & tx_full_8seg & tx_half_full_8seg;
  uart_status_port_led <= "000000" & tx_full_led & tx_half_full_led;
  uart_status_port_counter_led <= "000" & rx_data_present_counter_led & rx_full_counter_led & rx_half_full_counter_led & "00";

  --
  -- The inputs connect via a pipelined multiplexer
  --

  input_ports: process(clk)
  begin
    if clk'event and clk='1' then
              
		  case port_id is
       
        -- read UART status at address 00 hex
        when "00000001" =>    in_port <= uart_status_port_user;

        -- read UART receive data at address 01 hex
        when "00000010" =>    in_port <= rx_data_user;

        -- read UART status at address 02 hex
        when "00000011" =>    in_port <= uart_status_port_counter_led;
		  
		  -- read UART status at address 03 hex
		  when "00000100" =>    in_port <= rx_data_counter_led;
		  
        -- transmit UART status at address 04 hex
        when "00000101" =>    in_port <= uart_status_port_8seg;

        -- transmit UART status at address 05 hex
        when "00000110" =>    in_port <= uart_status_port_led;	  
        
        -- Don't care used for all other addresses to ensure minimum logic implementation
        when others =>    in_port <= "XXXXXXXX";  

      end case;

      -- Form read strobe for UART receiver FIFO buffer.
      -- The fact that the read strobe will occur after the actual data is read by 
      -- the KCPSM3 is acceptable because it is really means 'I have read you'!

      read_from_uart_user <= read_strobe and (not port_id(0)) and port_id(1) and (not port_id(2)); 
		read_from_uart_counter_led <= read_strobe and (not port_id(0)) and (not port_id(1)) and port_id(2); 

    end if;

  end process input_ports;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  -- adding the output registers to the clock processor
   
  output_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if write_strobe='1' then
              
		  case port_id is
		  
		    -- read UART status at address 00 hex
          when "00000111" =>    out_port_user <= out_port;

          -- read UART receive data at address 01 hex
          when "00001000" =>    out_port_8seg <= out_port;

          -- read UART status at address 02 hex
          when "00001001" =>    out_port_led <= out_port;	  
        
          -- Don't care used for all other addresses to ensure minimum logic implementation
          when others =>    out_port_user <= "XXXXXXXX";
									 out_port_8seg <= "XXXXXXXX";
									 out_port_led <= "XXXXXXXX";

        end case;

      end if;

    end if; 

  end process output_ports;

  --
  -- write to UART transmitter FIFO buffer at address 01 hex.
  -- This is a combinatorial decode because the FIFO is the 'port register'.
  --

  write_to_uart <= write_strobe and port_id(0);

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- UART  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
  -- Each contains an embedded 16-byte FIFO buffer.
  --


  --User-pBlaze3 uart
  tx_user: uart_tx 
  port map (            data_in => out_port_user, 
                   write_buffer => write_to_uart_user,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud_38400,
                     serial_out => tx_user,
                    buffer_full => tx_full_user,
               buffer_half_full => tx_half_full_user,
                            clk => clk );

  rx_user: uart_rx
  port map (            serial_in => rx_user,
                         data_out => rx_data_user,
                      read_buffer => read_from_uart_user,
                     reset_buffer => '0',
                     en_16_x_baud => en_16_x_baud_38400,
              buffer_data_present => rx_data_present_user,
                      buffer_full => rx_full_user,
                 buffer_half_full => rx_half_full_user,
                              clk => clk );  
										
  baud_timer_38400: process(clk)
  begin
    if clk'event and clk='1' then
      if baud_count_38400=9 then
           baud_count_38400 <= 0;
         en_16_x_baud_38400 <= '1';
       else
           baud_count_38400 <= baud_count_38400 + 1;
         en_16_x_baud_38400 <= '0';
      end if;
    end if;
  end process baud_timer;										
										
										
  --pBlaze3-8seg uart								
  tx_8seg: uart_tx 
  port map (            data_in => out_port_8seg, 
                   write_buffer => write_to_uart_8seg,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud_9600,
                     serial_out => tx_8seg,
                    buffer_full => tx_full_8seg,
               buffer_half_full => tx_half_full_8seg,
                            clk => clk );
									 									 
									 
  --pBlaze3-3 LEDs uart								 
  tx_led: uart_tx 
  port map (            data_in => out_port_led, 
                   write_buffer => write_to_uart_led,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud_9600,
                     serial_out => tx_led,
                    buffer_full => tx_full_led,
               buffer_half_full => tx_half_full_led,
                            clk => clk );
								  
 
  --pBlaze3-PWMCounter uart
  rx_counter_led: uart_rx
  port map (            serial_in => rx_counter_led,
                         data_out => rx_data_counter_led,
                      read_buffer => read_from_uart_counter_led,
                     reset_buffer => '0',
                     en_16_x_baud => en_16_x_baud_9600,
              buffer_data_present => rx_data_present_counter_led,
                      buffer_full => rx_full_counter_led,
                 buffer_half_full => rx_half_full_counter_led,
                              clk => clk );  

  baud_timer_9600: process(clk)
  begin
    if clk'event and clk='1' then
      if baud_count_9600=38 then
           baud_count_9600 <= 0;
         en_16_x_baud_9600 <= '1';
       else
           baud_count_9600 <= baud_count_9600 + 1;
         en_16_x_baud_9600 <= '0';
      end if;
    end if;
  end process baud_timer;


  ----------------------------------------------------------------------------------------------------------------------------------

end Behavioral;

------------------------------------------------------------------------------------------------------------------------------------
--
-- END OF FILE pBlaze3_uart.vhd
--
------------------------------------------------------------------------------------------------------------------------------------

