-- uart.vhd: UART controller - receiving part
-- Author(s): Stefan Peknik
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
  CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
	signal cnt_clk       : std_logic_vector(4 downto 0) := "00000";
	signal cnt_bit       : std_logic_vector(3 downto 0) := "0000";
	
	signal cnt_clk_en    : std_logic := '0';
	
	signal other_bits_en : std_logic := '0';
	
	signal dmx_en        : std_logic := '0';
	
	signal dt_vld        : std_logic := '0';
begin

	FSM: entity work.UART_FSM(behavioral)
		port map (
			DIN => DIN,
			CLK => CLK,
			RST => RST,
			
			CNT_CLK => cnt_clk,
			CNT_BIT => cnt_bit,
			
			CNT_CLK_EN => cnt_clk_en,
			
			OTHER_BITS_EN => other_bits_en,
			
			DMX_EN => dmx_en,
			
			DOUT_VLD => dt_vld
		);
  
  process(CLK) begin
    if rising_edge(CLK) then
      
      if dt_vld = '1' then
        DOUT_VLD <= '1';
      else
        DOUT_VLD <= '0';
      end if;
      
      if RST = '1' then
        DOUT <= "00000000";
      end if;
      
      if cnt_clk_en = '1' then
        cnt_clk <= cnt_clk + "1";
      end if;
      
      if cnt_clk = "10110" then
        cnt_clk <= "00000";
      end if;
      
      if cnt_bit = "1000" then
        cnt_bit <= "0000";
      end if;
      
      if other_bits_en = '1' then
        if cnt_clk = "01110" then
          cnt_bit <= cnt_bit + "1";
          cnt_clk <= "00000";
        end if;
      end if;
      
      if dmx_en = '1' then
        case cnt_bit is
          when "0000" => DOUT(0) <= DIN;
          when "0001" => DOUT(1) <= DIN;
          when "0010" => DOUT(2) <= DIN;
          when "0011" => DOUT(3) <= DIN;
          when "0100" => DOUT(4) <= DIN;
          when "0101" => DOUT(5) <= DIN;
          when "0110" => DOUT(6) <= DIN;
          when "0111" => DOUT(7) <= DIN;
          when others => null;
        end case;
      end if;
      
      
      
    end if;
	end process;
end behavioral;
