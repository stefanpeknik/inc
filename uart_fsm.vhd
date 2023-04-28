-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): Stefan Peknik
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   DIN           : in std_logic;
   CLK           : in std_logic;
   RST           : in std_logic;

   CNT_CLK       : in std_logic_vector(4 downto 0);
   CNT_BIT       : in std_logic_vector(3 downto 0);

   CNT_CLK_EN    : out std_logic;
  
   OTHER_BITS_EN : out std_logic;
                     
   DMX_EN        : out std_logic;

   DOUT_VLD      : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type state_t is (IDLE, WAIT_FIRST_MB, READ_MB, WAIT_NEXT_MB, WAIT_STOPBIT, VALID_DATA);
signal state : state_t := IDLE;
begin

  CNT_CLK_EN <= '1' when state = WAIT_FIRST_MB or state = WAIT_NEXT_MB else '0';

  OTHER_BITS_EN <= '1' when state = READ_MB or state = WAIT_NEXT_MB else '0';

  DMX_EN <= '1' when state = READ_MB else '0';

  DOUT_VLD <= '1' when state = VALID_DATA else '0';

   process (CLK) begin
      if rising_edge(CLK) then
         if RST = '1' then
            state <= IDLE;
         else
            case state is

               when IDLE => 
                  if DIN = '0' then
                     state <= WAIT_FIRST_MB;
                  end if;

               when WAIT_FIRST_MB =>
                  if CNT_CLK = "10110" then -- 22
                     state <= READ_MB;
                  end if;

               when READ_MB =>
                  state <= WAIT_NEXT_MB;
                  if CNT_BIT = "1000" then -- 8
                     state <= WAIT_STOPBIT;
                  end if ;

               when WAIT_NEXT_MB =>
                  if CNT_CLK = "01110" then -- 14
                     state <= READ_MB;
                  end if;

               when WAIT_STOPBIT =>
                  if DIN = '1' then
                     state <= VALID_DATA;
                  end if ;

               when VALID_DATA =>
                  state <= IDLE;

               when others => null;

            end case;
         end if;
      end if;
  end process;
end behavioral;
