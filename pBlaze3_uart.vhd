library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pBlaze3_uart is
    Port (    en_16_x_baud_9600 : in  std_logic;
              en_16_x_baud_4800 : in  std_logic;
				  tx_user : out std_logic;
              rx_user : in std_logic;
				  tx_sseg : out std_logic;
				  tx_led : out std_logic;
				  tx_pwm_gauge : out std_logic;
              rx_pwm_gauge : in std_logic;
              clk : in std_logic);
    end pBlaze3_uart;

architecture Behavioral of pBlaze3_uart is

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
  component uart_kcpsm3
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
signal out_port_sseg   : std_logic_vector(7 downto 0);
signal out_port_led   : std_logic_vector(7 downto 0);
signal out_port_pwm_gauge   : std_logic_vector(7 downto 0);
signal out_port   : std_logic_vector(7 downto 0);
signal in_port         : std_logic_vector(7 downto 0);
signal write_strobe    : std_logic;
signal read_strobe     : std_logic;
signal interrupt_ack   : std_logic;

signal uart_status_port_user : std_logic_vector(7 downto 0);
signal uart_status_port_sseg : std_logic_vector(7 downto 0);
signal uart_status_port_led : std_logic_vector(7 downto 0);
signal uart_status_port_pwm_gauge : std_logic_vector(7 downto 0);

signal        write_to_uart_user : std_logic;
signal              tx_full_user : std_logic;
signal         tx_half_full_user : std_logic;
signal       read_from_uart_user : std_logic;
signal              rx_data_user : std_logic_vector(7 downto 0);
signal      rx_data_present_user : std_logic;
signal              rx_full_user : std_logic;
signal         rx_half_full_user : std_logic;

signal        write_to_uart_sseg : std_logic;
signal              tx_full_sseg : std_logic;
signal         tx_half_full_sseg : std_logic;

signal       write_to_uart_led : std_logic;
signal             tx_full_led : std_logic;
signal        tx_half_full_led : std_logic;

signal            read_from_uart_pwm_gauge : std_logic;
signal                   rx_data_pwm_gauge : std_logic_vector(7 downto 0);
signal           rx_data_present_pwm_gauge : std_logic;
signal                   rx_full_pwm_gauge : std_logic;
signal              rx_half_full_pwm_gauge : std_logic;

signal        write_to_uart_pwm_gauge : std_logic;
signal              tx_full_pwm_gauge : std_logic;
signal         tx_half_full_pwm_gauge : std_logic;
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
                 interrupt => '0',
             interrupt_ack => interrupt_ack,
                     reset => '0',
                       clk => clk);
 
  program_rom: uart_kcpsm3
    port map(      address => address,
               instruction => instruction,
                       clk => clk);

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Interrupt 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- Interrupt is a generated once every 6 clock cycles to provide a 1us reference. 
  -- Interrupt is automatically cleared by interrupt acknowledgment from KCPSM3.
  --


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 input ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  --
  -- UART FIFO status signals to form a bus
  --

  uart_status_port_user <= "000" & rx_data_present_user & rx_full_user & rx_half_full_user & tx_full_user & tx_half_full_user;
  uart_status_port_sseg <= "000000" & tx_full_sseg & tx_half_full_sseg;
  uart_status_port_led <= "000000" & tx_full_led & tx_half_full_led;
  uart_status_port_pwm_gauge <= "000" & rx_data_present_pwm_gauge & rx_full_pwm_gauge & rx_half_full_pwm_gauge 
												  & tx_full_pwm_gauge & tx_half_full_pwm_gauge;

  --
  -- The inputs connect via a pipelined multiplexer
  --

  input_ports: process(clk)
  begin
    if clk'event and clk='1' then
              
		  case port_id is
       
        when "00000001" =>    in_port <= uart_status_port_user;

        when "00000010" =>    in_port <= rx_data_user;

        when "00000100" =>    in_port <= uart_status_port_pwm_gauge;
		  
		  when "00001000" =>    in_port <= rx_data_pwm_gauge;
		  
        when "00010000" =>    in_port <= uart_status_port_sseg;

        when "00100000" =>    in_port <= uart_status_port_led;	  
        
        when others =>    in_port <= "XXXXXXXX";  

      end case;
		
		read_from_uart_user <= read_strobe and port_id(1); 
		read_from_uart_pwm_gauge <= read_strobe and port_id(3);
		   
    end if;

  end process input_ports;

  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  -- adding the output registers to the clock processor
   
  --output_ports: process(clk) --deleted clk from sensitivity list
  --begin 	
		--if clk'event and clk = '1' then
		--if write_strobe = '1' then
			--if port_id(0) = '1' then
				--out_port_user <= out_port;
			--elsif port_id(1) = '1' then
				--out_port_sseg <= out_port;
			--elsif port_id(2) = '1' then
				--out_port_led <= out_port;
			--end if;
		--end if;
		--end if;

  --end process output_ports;
	
	
	out_port_user <= out_port;
	out_port_sseg <= out_port;
	out_port_led <= out_port;
	out_port_pwm_gauge <= out_port;
	



  write_to_uart_user <= write_strobe and port_id(0);
  write_to_uart_sseg <= write_strobe and port_id(1);
  write_to_uart_led <= write_strobe and port_id(2);
  write_to_uart_pwm_gauge <= write_strobe and port_id(3);


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- UART  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- Connect the 8-bit, 1 stop-bit, no parity transmit and receive macros.
  -- Each contains an embedded 16-byte FIFO buffer.
  --
  
  --User-pBlaze3 uart
  tx_user_uart: uart_tx 
  port map (            data_in => out_port_user, 
                   write_buffer => write_to_uart_user,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud_9600,
                     serial_out => tx_user,
                    buffer_full => tx_full_user,
               buffer_half_full => tx_half_full_user,
                            clk => clk );

  rx_user_uart: uart_rx
  port map (            serial_in => rx_user,
                         data_out => rx_data_user,
                      read_buffer => read_from_uart_user,
                     reset_buffer => '0',
                     en_16_x_baud => en_16_x_baud_9600,
              buffer_data_present => rx_data_present_user,
                      buffer_full => rx_full_user,
                 buffer_half_full => rx_half_full_user,
                              clk => clk );  										
										
										
  --pBlaze3-SSEG uart								
  tx_sseg_uart: uart_tx 
  port map (            data_in => out_port_sseg, 
                   write_buffer => write_to_uart_sseg,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud_4800,
                     serial_out => tx_sseg,
                    buffer_full => tx_full_sseg,
               buffer_half_full => tx_half_full_sseg,
                            clk => clk );
									 									 
									 
  --pBlaze3-3 LED uart								 
  tx_led_uart: uart_tx 
  port map (            data_in => out_port_led, 
                   write_buffer => write_to_uart_led,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud_4800,
                     serial_out => tx_led,
                    buffer_full => tx_full_led,
               buffer_half_full => tx_half_full_led,
                            clk => clk );
								  
 
  --pBlaze3-PWM Gauge uart
  
  tx_pwm_gauge_uart: uart_tx 
  port map (            data_in => out_port_pwm_gauge, 
                   write_buffer => write_to_uart_pwm_gauge,
                   reset_buffer => '0',
                   en_16_x_baud => en_16_x_baud_4800,
                     serial_out => tx_pwm_gauge,
                    buffer_full => tx_full_pwm_gauge,
               buffer_half_full => tx_half_full_pwm_gauge,
                            clk => clk );


  rx_pwm_gauge_uart: uart_rx
  port map (            serial_in => rx_pwm_gauge,
                         data_out => rx_data_pwm_gauge,
                      read_buffer => read_from_uart_pwm_gauge,
                     reset_buffer => '0',
                     en_16_x_baud => en_16_x_baud_4800,
              buffer_data_present => rx_data_present_pwm_gauge,
                      buffer_full => rx_full_pwm_gauge,
                 buffer_half_full => rx_half_full_pwm_gauge,
                              clk => clk );
																		


  ----------------------------------------------------------------------------------------------------------------------------------

end Behavioral;

------------------------------------------------------------------------------------------------------------------------------------
--
-- END OF FILE pBlaze3_uart.vhd
--
------------------------------------------------------------------------------------------------------------------------------------

