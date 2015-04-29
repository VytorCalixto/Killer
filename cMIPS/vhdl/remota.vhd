-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- UFPR, BCC, ci212 2013-2 trabalho semestral, autor: Roberto Hexsel, 01nov
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ESTE ARQUIVO NAO PODE SER ALTERADO

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- modelo funcional do computador remoto
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE; use IEEE.std_logic_1164.all; use IEEE.numeric_std.all;
use std.textio.all;
use work.p_WIRES.all;

        
entity remota is
  generic(OUTPUT_FILE_NAME : string := "serial.out";
          INPUT_FILE_NAME  : string := "serial.inp");
  port(rst, clk  : in  std_logic;
       start     : in  std_logic;    -- start operation =1
       inpDat    : in  std_logic;    -- serial input
       outDat    : out std_logic;    -- serial output
       bit_rt    : in  reg3);        -- selects bit rate
end remota;

architecture behavior of remota is

  component counter8 is
    port(rel, rst, ld, en: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector);
  end component counter8;


  -- transmission signals & states -----------------------------------------
  type tx_state is (st_init, st_idle, st_start,
                    st_b0, st_b1, st_b2, st_b3, st_b4, st_b5, st_b6, st_b7,
                    st_stop, st_wait, st_done);
  signal tx_current_st, tx_next_st : tx_state;
  signal tx_dbg_st : integer;  -- for debugging only
  
  signal tx_bit_rt : reg8;
  signal tx_clk, tx_run : std_logic;

  file input_stream : text open read_mode is INPUT_FILE_NAME;
  -- file input_stream : text open read_mode is "STD_INPUT";
  -- -----------------------------------------------------------------------
  
  -- reception signals & states --------------------------------------------
  type rx_state is (st_idle, st_check, st_start,
                    st_b0, st_b1, st_b2, st_b3, st_b4, st_b5, st_b6, st_b7,
                    st_stop, st_done);
  signal rx_current_st, rx_next_st : rx_state;
  signal rx_dbg_st : integer;  -- for debugging only
  
  signal recv, rx_bit_rt : reg8;
  signal rx_clk, rx_run, reset_rxck : std_logic;

  signal tx_baud_div, rx_baud_div : integer := 0;
  
  -- file output_stream : text open write_mode is OUTPUT_FILE_NAME;
  file output_stream : text open write_mode is "STD_OUTPUT";
  -- -----------------------------------------------------------------------

  
begin

  -- transmission control SM ----------------------------------------------
  U_TX_st_reg: process(rst,tx_clk)
  begin
    if rst = '0' then
      tx_current_st <= st_wait;
    elsif rising_edge(tx_clk) then
      tx_current_st <= tx_next_st;
    end if;
  end process U_TX_st_reg;

  tx_dbg_st <= integer(tx_state'pos(tx_current_st));  -- debugging only

  U_tx: process (tx_current_st, start)
    variable sentence : line;
    variable char : character;
    variable good, send_null : boolean;
    variable bfr  : reg8;
    variable j : integer;
  begin

    case tx_current_st is
      when st_wait =>                   -- 12 wait for starting signal
        outDat <= '1';
        tx_run <= '0';                  -- hold TX clock
        send_null := FALSE;
        if start = '0'  then
          tx_next_st <= st_wait;
        else
          if not endfile(input_stream) then
            readline( input_stream, sentence );  -- read first line of text
            -- assert false report "fst line: "&integer'image(sentence'length);
            j := 1;
            tx_next_st <= st_init;
          else
            tx_next_st <= st_done;      -- no input, done!
          end if;
        end if;
      when st_init =>                   -- 0
        outDat <= '1';
        tx_run <= '1';              -- start TX clock
        tx_next_st <= st_idle;
      when st_idle =>                   -- 1
        if not endfile(input_stream) then
          if j > sentence'right then    -- read new line of input
            readline( input_stream, sentence );
            -- assert false report "new line: "&integer'image(sentence'length);
            bfr := x"0a";               -- new line
            j := 0;
          elsif sentence'length = 0 then
            bfr := x"0a";             -- send new line for empty line
            -- assert false report "empty line: " & integer'image(j)&" " & LF;
          else
            read (sentence, char, good);
            -- assert false report "read: " & integer'image(j) & " " &char;
            bfr := std_logic_vector(to_signed( character'pos(char), 8));
          end if;
          tx_next_st <= st_start;
        else
          tx_next_st <= st_done;        -- no more input, done!
        end if;
      when st_start =>                  -- 2
        outDat <= '0';
        tx_next_st <= st_b0;
      when st_b0 =>                     -- 3
        outDat <= bfr(0);
        tx_next_st <= st_b1;
      when st_b1 =>                     -- 4
        outDat <= bfr(1);
        tx_next_st <= st_b2;
      when st_b2 =>                     -- 5
        outDat <= bfr(2);
        tx_next_st <= st_b3;
      when st_b3 =>                     -- 6
        outDat <= bfr(3);
        tx_next_st <= st_b4;
      when st_b4 =>                     -- 7
        outDat <= bfr(4);
        tx_next_st <= st_b5;
      when st_b5 =>                     -- 8
        outDat <= bfr(5);
        tx_next_st <= st_b6;
      when st_b6 =>                     -- 9
        outDat <= bfr(6);
        tx_next_st <= st_b7;
      when st_b7 =>                     -- 10
        outDat <= bfr(7);
        tx_next_st <= st_stop;
      when st_stop =>                   -- 11
        j := j + 1;
        outDat <= '1';
        tx_next_st <= st_idle;
      when st_done =>                   -- 13 wait forever
        if send_null = FALSE then
          bfr := x"00";               -- send out a NULL character
          send_null := TRUE;
          tx_next_st <= st_start;
        else
          tx_next_st <= st_done;        -- no more input, done!
          outDat <= '1';
        end if;
        tx_run <= '0';                  -- stop clock
      when others =>
        assert false report "REMOTE TX stateMachine broken"
          & integer'image(tx_state'pos(tx_current_st)) severity failure;
      end case;

  end process U_tx;
  -- ======================================================================


  
  -- reception ============================================================

  -- reception control SM -------------------------------------------------
  U_RX_st_reg: process(rst,clk)
  begin
    if rst = '0' then
      rx_current_st <= st_idle;
    elsif rising_edge(clk) then
      rx_current_st <= rx_next_st;
    end if;
  end process U_RX_st_reg;

  rx_dbg_st <= integer(rx_state'pos(rx_current_st));  -- debugging only

  U_rx: process(rx_current_st, rx_clk, inpDat)
    variable msg : line;
  begin
    case rx_current_st is
      when st_idle =>
        reset_rxck <= '0';
        rx_run     <= '0';
        recv       <= (others => 'U');
        if falling_edge(inpDat) then    -- start bit
          rx_next_st <= st_check;
        else
          rx_next_st <= st_idle;
        end if;
      when st_check =>
        reset_rxck <= '1';
        rx_run     <= '1';
        rx_next_st <= st_start;
      when st_start =>
        reset_rxck <= '0';
        -- if rising_edge(rx_clk) then
          rx_next_st <= st_b0;
        -- else
        --   rx_next_st <= st_start;
        -- end if;
      when st_b0 =>
        if falling_edge(rx_clk) then
          recv(0) <= inpDat;
          rx_next_st <= st_b1;
        else
          rx_next_st <= st_b0;
        end if;
      when st_b1 =>
        if falling_edge(rx_clk) then
          recv(1) <= inpDat;
          rx_next_st <= st_b2;
        else
          rx_next_st <= st_b1;
        end if;
      when st_b2 =>
        if falling_edge(rx_clk) then
          recv(2) <= inpDat;
          rx_next_st <= st_b3;
        else
          rx_next_st <= st_b2;
        end if;
      when st_b3 =>
        if falling_edge(rx_clk) then
          recv(3) <= inpDat;
          rx_next_st <= st_b4;
        else
          rx_next_st <= st_b3;
        end if;
      when st_b4 =>
        if falling_edge(rx_clk) then
          recv(4) <= inpDat;
          rx_next_st <= st_b5;
        else
          rx_next_st <= st_b4;
        end if;
      when st_b5 =>
        if falling_edge(rx_clk) then
          recv(5) <= inpDat;
          rx_next_st <= st_b6;
        else
          rx_next_st <= st_b5;
        end if;
      when st_b6 =>
        if falling_edge(rx_clk) then
          recv(6) <= inpDat;
          rx_next_st <= st_b7;
        else
          rx_next_st <= st_b6;
        end if;
      when st_b7 =>
        if falling_edge(rx_clk) then
          recv(7) <= inpDat;
          rx_next_st <= st_stop;
        else
          rx_next_st <= st_b7;
        end if;
      when st_stop =>
        if falling_edge(rx_clk) then
          rx_next_st <= st_done;
        else
          rx_next_st <= st_stop;
        end if;
      when st_done =>
        rx_run     <= '0';
        rx_next_st <= st_idle;

        write ( msg, character'val(to_integer( unsigned(recv))) );
        if recv = x"00" or recv = x"0a"  then
          writeline( output_stream, msg );      
        end if;

      when others =>
        assert false report "REMOTE RX stateMachine broken"
          & integer'image(rx_state'pos(rx_current_st)) severity failure;
    end case;
  end process U_rx;


  -- baud rate generators ---------------------------------------------

  with bit_rt select
    tx_baud_div <=      8/2 when b"000",
                       16/2 when b"001",
                       32/2 when b"010",
                      434/2 when b"011",
                      868/2 when b"100",
                     1302/2 when b"101",
                     1736/2 when b"110",
                     2604/2 when others;
                     -- 3472/2 when b"110",
                     -- 5208/2 when others;

  U_bit_rt_tx: process(clk, rst)
    variable baud_cnt : integer;
  begin
     if rst = '0' then
      baud_cnt  := 0;
      tx_clk <= '0';
    elsif rising_edge(clk) then
      if baud_cnt = tx_baud_div then
        tx_clk <= not(tx_clk);
        baud_cnt := 1;
      else
        baud_cnt := baud_cnt + 1;
      end if;
    end if;
  end process U_bit_rt_tx;


  -- RX clock daud rate
  with bit_rt select
    rx_baud_div <=      8/2 when b"000",
                       16/2 when b"001",
                       32/2 when b"010",
                      434/2 when b"011",
                      868/2 when b"100",
                     1302/2 when b"101",
                     1736/2 when b"110",
                     2604/2 when others;
                     -- 3472/2 when b"110",
                     -- 5208/2 when others;

  U_bit_rt_rx: process(clk, rst, reset_rxck, rx_run)
    variable baud_cnt : integer;
  begin
     if rst = '0' then
      baud_cnt  := 0;
      rx_clk <= '0';
    elsif reset_rxck = '1' and rising_edge(clk) then
      baud_cnt  := 1;
      rx_clk <= '0';
    elsif rx_run = '1' and rising_edge(clk) then
      if baud_cnt = rx_baud_div then
        rx_clk <= not(rx_clk);
        baud_cnt := 1;
      else
        baud_cnt := baud_cnt + 1;
      end if;
    end if;
  end process U_bit_rt_rx;

  
end behavior;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

