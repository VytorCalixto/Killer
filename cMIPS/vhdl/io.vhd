-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--  cMIPS, a VHDL model of the classical five stage MIPS pipeline.
--  Copyright (C) 2013  Roberto Andre Hexsel
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, version 3.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: print_data
--             print an integer to stdout, 32bit hexadecimal
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity print_data is
  port (rst     : in  std_logic;
        clk     : in  std_logic;
        sel     : in  std_logic;
        rdy     : out std_logic;
        wr      : in  std_logic;
        addr    : in  reg32;
        data    : in  reg32);
end print_data;

architecture behavioral of print_data is

  file output : text open write_mode is "STD_OUTPUT";

begin

  rdy <= '1';

  U_WRITE_OUT: process(sel,clk)
    variable msg : line;
  begin
    if falling_edge(clk) and sel = '0' then
      write ( msg, string'(SLV32HEX(data)) );
      writeline( output, msg );
    end if;
  end process U_WRITE_OUT;

end behavioral;
-- ++ print_data +++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: to_stdout
--             print a signle character to stdout
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity to_stdout is
  port (rst     : in  std_logic;
        clk     : in  std_logic;
        sel     : in  std_logic;
        rdy     : out std_logic;
        wr      : in  std_logic;
        addr    : in  std_logic_vector;
        data    : in  std_logic_vector);
end to_stdout;

architecture behavioral of to_stdout is
  
  file output : text open write_mode is "STD_OUTPUT";

begin

  rdy <= '1';

  U_WRITE_OUT: process(clk,sel)
    variable msg : line;
  begin
    if falling_edge(clk) and sel = '0' then
      if (data(7 downto 0) = x"00") or (data(7 downto 0) = x"0a") then
        writeline( output, msg );
      else
        write(msg, character'val(to_integer( unsigned(data(7 downto 0)))));
      end if;
    end if;
  end process U_WRITE_OUT;
  
end behavioral;
-- ++ to_stdout +++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: write_data_to_file
--             write one 32bit integer to file "output.data"
--   if( addr(3 downto 0) ) = "0000" then write to file
--   if( addr(3 downto 0) ) = "0100" then close file
--   if( addr(3 downto 0) ) = "0111" then assert dump_ram
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity write_data_file is
  generic (OUTPUT_FILE_NAME : string := "output.data");
  port (rst      : in  std_logic;
        clk      : in  std_logic;
        sel      : in  std_logic;
        rdy      : out std_logic;
        wr       : in  std_logic;
        addr     : in  reg32;
        data     : in  reg32;
        byte_sel : in  reg4;
        dump_ram : out std_logic);
end write_data_file;

architecture behavioral of write_data_file is

  type uint_file_type is file of integer;
  file output_file: uint_file_type open write_mode is OUTPUT_FILE_NAME;

begin

  rdy <= '1';

  U_write_uint: process (clk,sel)
  begin

    dump_ram <= '0';

    if  falling_edge(clk) and sel = '0' then
      if addr(3 downto 0) = b"0000" then               -- data write
        if wr = '0' then
          write( output_file, to_integer(signed(data)) );
          -- assert FALSE
          --   report "IOwr[" & SLV32HEX(addr) &"]:"& SLV32HEX(data);
        end if;
      elsif addr(3 downto 0) = b"0100" then            -- close output file
        file_close(output_file);
      elsif addr(3 downto 0) = b"0111" then            -- dump RAM
        dump_ram <= '1';
      end if;
    end if;
    
  end process U_write_uint;

end behavioral;                         -- write_file_data
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: read_data_from_file
--             read one 32bit integer from file "input.data"
--  if not EOF then write data to file
--  else status <= 1
--  on a read, return last status (EOF=1 or otherwise=0)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity read_data_file is
  generic (INPUT_FILE_NAME : string := "input.data");
  port (rst      : in  std_logic;
        clk      : in  std_logic;
        sel      : in  std_logic;
        rdy      : out std_logic;
        wr       : in  std_logic;
        addr     : in  reg32;
        data     : out reg32;
        byte_sel : in  reg4);
end read_data_file;

architecture behavioral of read_data_file is

  type uint_file_type is file of integer;
  file input_file: uint_file_type open read_mode is INPUT_FILE_NAME;

  signal status : reg32 := (others => '0');

begin

  rdy <= '1';


  U_read_uint: process(clk,sel)
    variable datum : integer := 0;
    variable value : reg32;                 -- for debugging only
  begin

    data <= (others => 'X');

    if falling_edge(clk) and sel = '0' then
      if addr(3 downto 0) = b"0000" then               -- data read
        if wr = '1' then
          if not endfile(input_file) then
            read( input_file, datum );
            data <= std_logic_vector(to_signed(datum, 32));
            status <= x"00000000";        -- NOT_EndOfFile
            -- value := std_logic_vector(to_signed(datum, 32));   -- DEBUG
            -- assert FALSE
            --   report "IOrd[" & SLV32HEX(addr) &"]:"& SLV32HEX(value);
          else
            status <= x"00000001";        -- EndOfFile
          end if;
        else
          data <= (others => 'X');
        end if;
      else                                -- status read
        if wr = '1' then
          data <= status;
        else
          data <= (others => 'X');
        end if;
      end if;
    end if;
    
  end process U_read_uint;

end behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: generate interrupt after N clock cycles
--   Generates an interrupt after N cycles, N <= 2**30
--   Counting stops on reaching limit stored to counter.
--   data(31) = 1 enables interrupt on reaching limit;
--   data(31) = 0 disables interrupts
--   data(30) = 1 enables counting
--   data(30) = 0 stops counter and delays interrupt (forever?)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_wires.all;

entity do_interrupt is
  port (rst      : in    std_logic;
        clk      : in    std_logic;     -- clock pulses counted
        sel      : in    std_logic;
        rdy      : out   std_logic;
        wr       : in    std_logic;
        addr     : in    std_logic_vector;
        data_inp : in    std_logic_vector;
        data_out : out   std_logic_vector;
        irq      : out   std_logic);
  constant NUM_BITS : integer := 30;
  subtype c_width is std_logic_vector(NUM_BITS - 1 downto 0);
  constant START_COUNT : c_width := (others => '0');
end do_interrupt;

architecture behavioral of do_interrupt is

  component registerN is
    generic (NUM_BITS: integer; INIT_VAL: std_logic_vector);
    port(clk, rst, ld: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector);
  end component registerN;

  component countNup is
    generic (NUM_BITS: integer);
    port(clk, rst, ld, en: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector;
         co:           out std_logic);
  end component countNup;

  component FFD is
    port(clk, rst, set : in std_logic;
         D : in  std_logic;
         Q : out std_logic);
  end component FFD;

  signal Dlimit, Qlimit, Q: c_width;
  signal ld_cnt, ld_reg, en, cnt_en, int_en, equals : std_logic;
  signal i_ena, c_ena : std_logic;
begin

  ld_reg <= wr when sel = '0' else '1';
  ld_cnt <= not ld_reg;
  
  Dlimit <= data_inp(NUM_BITS-1 downto 0);

  U_LIMIT: registerN  generic map (NUM_BITS, START_COUNT)
    port map (clk, rst, ld_reg, Dlimit, Qlimit);

  en <= cnt_en and (not equals);

  U_COUNTER: countNup generic map (NUM_BITS)
    port map (clk, rst, ld_cnt, en, START_COUNT, Q, open);

  i_ena <= data_inp(31) when (sel='0' and wr='0') else int_en;
  U_INTERR_EN: FFD port map (clk, rst, '1', i_ena, int_en);

  c_ena <= data_inp(30) when (sel='0' and wr='0') else cnt_en;
  U_COUNT_EN:  FFD port map (clk, rst, '1', c_ena, cnt_en);

  equals <= '1' when (Q = Qlimit(NUM_BITS-1 downto 0)) else '0';
  
  irq <= '1' when (equals = '1' and int_en = '1') else '0';

  data_out <= int_en & cnt_en & Q;

  rdy <= '1';  -- never generates wait states

end behavioral;
-- ++ do_interrupt +++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: simple UART
--   8 data bits, no parity, 1 stop bit (8N1), catches: framing, overrun
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_wires.all;

entity simple_uart is
  port (rst     : in    std_logic;
        clk     : in    std_logic;      -- processor clock
        sel     : in    std_logic;
        rdy     : out   std_logic;
        wr      : in    std_logic;
        addr    : in    std_logic;
        data_inp : in   std_logic_vector;
        data_out : out  std_logic_vector;
        txdat   : out   std_logic;      -- serial transmission (output)
        rxdat   : in    std_logic;      -- serial reception (input)
        rts     : out   std_logic;
        cts     : in    std_logic;
        irq     : out   std_logic;      -- interrupt request
        bit_rt  : out   std_logic_vector); -- communication speed; for TB only
end simple_uart;

architecture behavioral of simple_uart is

  component uart_int is
    port(clk, rst: in std_logic;
         s_ctrl, s_stat, s_tx, s_rx: in std_logic;  -- select 4 registers
         d_inp:  in  std_logic_vector;  -- 32 bit input
         d_out:  out std_logic_vector;  -- 32 bit output
         txdat:  out std_logic;         -- serial transmission (output)
         rxdat:  in  std_logic;         -- serial reception (input)
         rts:    out std_logic;
         cts:    in  std_logic;
         interr: out std_logic;         -- interrupt request
         bit_rt: out std_logic_vector); -- communication speed - for TB only
  end component uart_int;
  
  signal s_ctrl, s_stat, s_tx, s_rx: std_logic;
  signal d_inp, d_out : reg32;

begin

  rdy <= '1';

  U_UART: uart_int port map (clk, rst, s_ctrl,s_stat, s_tx,s_rx,
                             d_inp,d_out, txdat,rxdat, rts,cts, irq, bit_rt);
  
  -- a2  wr  register (aligned to word addresses)
  --  0  0  control
  --  0  1  status
  --  1  0  transmission
  --  1  1  reception
  s_ctrl <= '1' when sel = '0' and addr = '0' and wr = '0' else '0';
  s_stat <= '1' when sel = '0' and addr = '0' and wr = '1' else '0';
  s_tx   <= '1' when sel = '0' and addr = '1' and wr = '0' else '0';
  s_rx   <= '1' when sel = '0' and addr = '1' and wr = '1' else '0';
  
  data_out <= d_out ;
  
  d_inp <= data_inp;
  
end behavioral;
-- ++ simple uart +++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: system statistics: gather statistics in one peripheral
-- processor reads performance counters, on word boundaries, adressed as
-- cnt_dc_ref    when "00000", 0
-- cnt_dc_rd_hit when "00100", 4
-- cnt_dc_wr_hit when "01000", 8
-- cnt_dc_flush  when "01100", 12
-- cnt_ic_ref    when "10000", 16
-- cnt_ic_hit    when "10100", 20
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;

entity sys_stats is
  port (rst     : in    std_logic;
        clk     : in    std_logic;
        sel     : in    std_logic;
        rdy     : out   std_logic;
        wr      : in    std_logic;
        addr    : in    reg32;
        data    : out   reg32;
        cnt_dc_ref    : in  integer;
        cnt_dc_rd_hit : in  integer;
        cnt_dc_wr_hit : in  integer;
        cnt_dc_flush  : in  integer;
        cnt_ic_ref : in  integer;
        cnt_ic_hit : in  integer);
end sys_stats;

architecture behavioral of sys_stats is
begin

  U_SYNC_OUTPUT: process(clk,sel)
    variable i_c : integer := 0;
  begin
    data <= (others => '0');

    if falling_edge(clk) and sel = '0' then
      case addr(4 downto 2) is
        when "000" => i_c := cnt_dc_ref;
        when "001" => i_c := cnt_dc_rd_hit;
        when "010" => i_c := cnt_dc_wr_hit;
        when "011" => i_c := cnt_dc_flush;
        when "100" => i_c := cnt_ic_ref;
        when "101" => i_c := cnt_ic_hit;
        when others => i_c := 0;
      end case;
    end if;
    
    data <= std_logic_vector(to_signed(i_c,32));

  end process U_SYNC_OUTPUT;

  
  rdy <= '1';

end behavioral;
-- ++ system statistics ++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: to_7seg
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use work.p_wires.all;

entity to_7seg is
  port (rst      : in  std_logic;
        clk      : in  std_logic;
        sel      : in  std_logic;
        rdy      : out std_logic;
        wr       : in  std_logic;
        data     : in  std_logic_vector;
        display0 : out reg8;
        display1 : out reg8);
  constant NUM_BITS : integer := 10;    -- 2 decimal points, 2 hex digits
  subtype c_width is std_logic_vector(NUM_BITS - 1 downto 0);
  constant START_COUNT : c_width := (others => '0');
end to_7seg;

architecture behavioral of to_7seg is

  component registerN is
    generic (NUM_BITS: integer; INIT_VAL: std_logic_vector);
    port(clk, rst, ld: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector);
  end component registerN;

  component display_7seg is
    port(data_i      : in  std_logic_vector(3 downto 0);
         decimal_i   : in  std_logic;
         disp_7seg_o : out std_logic_vector(7 downto 0));
  end component display_7seg;
  
  signal value : std_logic_vector(NUM_BITS-1 downto 0);
  
begin
  
  U_HOLD_data: registerN generic map (NUM_BITS, START_COUNT)
    port map (clk, rst, sel, data(NUM_BITS-1 downto 0), value);

  U_DSP1: display_7seg port map (value(7 downto 4), value(9), display1);

  U_DSP0: display_7seg port map (value(3 downto 0), value(8), display0);

  rdy <= '1';
  
  U_sim: process(sel,rst)
  begin
    if rst = '1' then
      assert not(rising_edge(sel))
        report "dsp7seg: "&  SLV32HEX(data) severity NOTE;
    end if;
  end process;

end behavioral;
-- ++ to_7seg +++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: read_keys
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;

entity read_keys is
  generic (DEB_CYCLES: natural);        -- debouncing interval
  port (rst      : in  std_logic;
        clk      : in  std_logic;
        sel      : in  std_logic;
        rdy      : out std_logic;
        data     : out reg32;
        kbd      : in  std_logic_vector (11 downto 0);
        sw       : in  std_logic_vector (3 downto 0));
  constant DEB_BITS : integer := 16;    -- debounce counter width
  constant CNT_MAX : integer := (2**DEB_BITS - 1);
  constant x_DEB_CYCLES : std_logic_vector(DEB_BITS-1 downto 0)
    := std_logic_vector(to_signed((CNT_MAX - DEB_CYCLES),DEB_BITS));
  constant NUM_BITS : integer := 4;     -- four bits to hold key number
  subtype c_width is std_logic_vector(NUM_BITS - 1 downto 0);
  constant NO_KEY : c_width := (others => '0');
end read_keys;

architecture behavioral of read_keys is
  
  component FFD is
    port(clk, rst, set : in std_logic;
         D : in  std_logic; Q : out std_logic);
  end component FFD;

  component registerN is
    generic (NUM_BITS: integer; INIT_VAL: std_logic_vector);
    port(clk, rst, ld: in  std_logic;
         D:            in  std_logic_vector(NUM_BITS-1 downto 0);
         Q:            out std_logic_vector(NUM_BITS-1 downto 0));
  end component registerN;
  
  component countNup is
  generic (NUM_BITS: integer := 16);
  port(clk, rst, ld, en: in  std_logic;
       D:                in  std_logic_vector((NUM_BITS - 1) downto 0);
       Q:                out std_logic_vector((NUM_BITS - 1) downto 0);
       co:               out std_logic);
  end component countNup;

  type kbd_state is (st_idle, st_start, st_wait, st_load, st_release);
  signal kbd_current_st, kbd_next_st : kbd_state;
  -- signal kbd_dbg_st : integer;    -- debugging only
  
  signal cnt_ld, cnt_en, new_ld : std_logic;
  signal press, debounced, rdy_clr, ready : std_logic;
  signal keys_data, cpu_data : reg4;
  signal d : reg2;
  -- signal count : std_logic_vector(DEB_BITS-1 downto 0);  -- debugging only
begin
  
  data(31) <= ready;
  data(30 downto 8) <= (others => '0');
  
  data(7) <= sw(3);
  data(6) <= sw(2);
  data(5) <= sw(1);
  data(4) <= sw(0);
  data(3 downto 0) <= cpu_data(3 downto 0);
  
  rdy <= '1';

  U_DEBOUNCER: countNup generic map (DEB_BITS)
    port map (clk=>clk, rst=>rst, ld=>cnt_ld, en=>cnt_en,
              D=>x_DEB_CYCLES, Q=>open, co=>debounced); 
  
  U_NEW_DATA: registerN  generic map (4, NO_KEY)
    port map (clk, rst, new_ld, keys_data, cpu_data);

  d <= new_ld & sel;                    -- new_ld, sel active in '0'
  with d select
    rdy_clr <= '1' when "00",
               '1' when "01",
               '0' when "10",
               ready when others;

  U_READY: FFD port map (clk, rst, '1', rdy_clr, ready);
  
  press <= BOOL2SL(keys_data /= b"0000");
  
  -- translate key position to key code
  -- code for key 0 cannot be zero; value-holding register is reset to "0000"
  with kbd select
    keys_data <= "0001" when "000000000001",   -- 1
                 "0010" when "000000000010",   -- 2
                 "0011" when "000000000100",   -- 3
                 "0100" when "000000001000",   -- 4
                 "0101" when "000000010000",   -- 5
                 "0110" when "000000100000",   -- 6
                 "0111" when "000001000000",   -- 7
                 "1000" when "000010000000",   -- 8
                 "1001" when "000100000000",   -- 9
                 "1010" when "001000000000",   -- *
                 "1111" when "010000000000",   -- 0, cannot be "0000"
                 "1011" when "100000000000",   -- #
                 "0000" when others; -- no key depressed


  -- ---------------------------------------------------------------------
  U_KBD_st_reg: process(rst,clk)
  begin
    if rst = '0' then
      kbd_current_st <= st_idle;
    elsif rising_edge(clk) then
      kbd_current_st <= kbd_next_st;
    end if;
  end process U_KBD_st_reg; ----------------------------------------------

  -- kbd_dbg_st <= integer(kbd_state'pos(kbd_current_st)); -- for debugging

  U_KBD_st_transitions: process(kbd_current_st, press, debounced) --------
  begin
    case kbd_current_st is
      when st_idle =>                   -- 0
        if press = '1' then
          kbd_next_st <= st_start;
        else
          kbd_next_st <= st_idle;
        end if;
      when st_start =>                  -- 1
        kbd_next_st <= st_wait;
      when st_wait =>                   -- 2
        if debounced = '1' then
          kbd_next_st <= st_load;
        else
          kbd_next_st <= st_wait;
        end if;
      when st_load =>                   -- 3
        kbd_next_st <= st_release;
      when st_release =>                -- 4
        if press = '1' then
          kbd_next_st <= st_release;
        else
          kbd_next_st <= st_idle;
        end if;
    end case;
  end process U_KBD_st_transitions;   ------------------------------------

  U_KBD_outputs: process(kbd_current_st)  ------------------------------
  begin
    case kbd_current_st is
      when st_idle  |st_release =>      -- 0,4
        new_ld  <= '1';
        cnt_ld  <= '0';
        cnt_en  <= '0';
      when st_start =>                  -- 1
        new_ld  <= '1';
        cnt_ld  <= '1';
        cnt_en  <= '0';
      when st_wait =>                   -- 2
        new_ld  <= '1';
        cnt_ld  <= '0';
        cnt_en  <= '1';
      when st_load =>                   -- 3
        new_ld  <= '0';
        cnt_ld  <= '1';
        cnt_en  <= '0';
    end case;
  end process U_KBD_outputs;   -------------------------------------------

  
end behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- peripheral: LCD display controller
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_wires.all;

entity LCD_display is
  port (rst      : in    std_logic;
        clk      : in    std_logic;
        sel      : in    std_logic;
        rdy      : out   std_logic;
        wr       : in    std_logic;
        addr     : in    std_logic; -- 0=constrol, 1=data
        data_inp : in    std_logic_vector(31 downto 0);
        data_out : out   std_logic_vector(31 downto 0);
        LCD_DATA : inout std_logic_vector(7 downto 0);  -- bidirectional bus
        LCD_RS   : out   std_logic; -- LCD register select 0=ctrl, 1=data
        LCD_RW   : out   std_logic; -- LCD read=1, 0=write
        LCD_EN   : out   std_logic; -- LCD enable=1
        LCD_BLON : out   std_logic);
  constant NUM_BITS : integer := 8;
  subtype c_width is std_logic_vector(NUM_BITS - 1 downto 0);
  constant START_VALUE : c_width := (others => '0');
end LCD_display;

architecture behavioral of LCD_display is

  component wait_states is
    generic (NUM_WAIT_STATES :integer);
    port(rst   : in  std_logic;
       clk     : in  std_logic;
       sel     : in  std_logic;         -- active in '0'
       waiting : out std_logic);        -- active in '1'
  end component wait_states;
  
  component registerN is
    generic (NUM_BITS: integer; INIT_VAL: std_logic_vector);
    port(clk, rst, ld: in  std_logic;
         D:            in  std_logic_vector;
         Q:            out std_logic_vector);
  end component registerN;

  component FFD is
    port(clk, rst, set, D : in std_logic; Q : out std_logic);
  end component FFD;

  type lcd_state is (st_init, st_idle, st_n, st_n1, st_n2, st_n3,
                     st_n4, st_n5, st_n6, st_n7, st_n8, st_n9, st_na, st_nb);
  attribute SYN_ENCODING of lcd_state : type is "safe";
  signal lcd_current_st, lcd_next_st : lcd_state;
  signal lcd_current : integer;         -- debugging only

  signal waiting, wait1, wait2, n_sel: std_logic;
  signal sel_rs, RS, sel_rw, RW,lcd_enable,lcd_read : std_logic;
  signal inp_data, out_data : reg8;
  
begin

  n_sel <= not(sel);
  
  U_WAIT_ON_READS: component wait_states generic map (1)
    port map (rst, clk, sel, wait1);

  U_WAIT2: FFD port map (clk, rst, '1', wait1, wait2);

  rdy <= not(wait1) and not(wait2) and waiting;

  sel_rs <= addr when sel = '0' else RS;
  U_INPUT_RS: FFD port map (clk, rst, '1', sel_rs, RS);

  U_INPUT: registerN generic map (NUM_BITS, START_VALUE)
  port map (clk, rst, sel, data_inp(NUM_BITS-1 downto 0), inp_data);

  U_OUTPUT: registerN generic map (NUM_BITS, START_VALUE)
  port map (clk, rst, lcd_read, out_data, data_out(NUM_BITS-1 downto 0));
  data_out(31 downto NUM_BITS) <= (others => '0');

  -- TESTING ONLY
  out_data <= b"00000000" when RW = '1' else (others => 'X');
  -- out_data <= LCD_DATA when RW = '1' else (others => 'Z');
  
  LCD_DATA <= inp_data when RW = '0' else (others => 'Z');

  LCD_RS  <= RS;          -- LCD register select 0=ctrl, 1=data

  sel_rw <= wr when sel = '0' else RW;
  U_INPUT_RW: FFD port map (clk, '1', rst, sel_rw, RW);

  LCD_RW   <= RW;         -- LCD read=1, 0=write

  LCD_EN   <= lcd_enable; -- LCD enable=1

  LCD_BLON <= '1';        -- LCD backlight
 
  -- state register----------------------------------------------------
  U_st_reg: process(rst,clk)
  begin
    if rst = '0' then
      lcd_current_st <= st_init;
    elsif rising_edge(clk) then
      lcd_current_st <= lcd_next_st;
    end if;
  end process U_st_reg;

  lcd_current <= lcd_state'pos(lcd_current_st);  -- debugging only

  U_st_transitions: process(lcd_current_st, RW, sel)
  begin
    case lcd_current_st is
      when st_init =>                   -- 0
        lcd_next_st <= st_idle;

      when st_idle =>                   -- 1
        if sel = '0' then
          lcd_next_st <= st_n;
        else
          lcd_next_st <= st_idle;
        end if;

      when st_n =>                      -- 2
        lcd_next_st <= st_n1;
      when st_n1 =>                     -- 3, setup for Enable is 20ns
        lcd_next_st <= st_n2;

      when st_n2 =>                     -- 4, keep Enable=1 for 200ns
        lcd_next_st <= st_n3;
      when st_n3 =>                     -- 5, data setup is 100ns
        lcd_next_st <= st_n4;
      when st_n4 =>                     -- 6
        lcd_next_st <= st_n5;
      when st_n5 =>                     -- 7
        lcd_next_st <= st_n6;
      when st_n6 =>                     -- 8
        lcd_next_st <= st_n7;
      when st_n7 =>                     -- 9
        lcd_next_st <= st_n8;

      when st_n8 =>                     -- 10
        lcd_next_st <= st_n9;
      when st_n9 =>                     -- 11, data hold for Enable is >40ns
        lcd_next_st <= st_na;
      when st_na =>                     -- 12
        lcd_next_st <= st_nb;
      when st_nb =>                     -- 13
        lcd_next_st <= st_idle;
        
      when others =>                    -- ??
        lcd_next_st <= st_idle;         --  Enable cycle >500ns
    end case;
  end process U_st_transitions;

  U_st_outputs: process(lcd_current_st)
  begin
    case lcd_current_st is
      when st_init =>        
        lcd_enable <= '0';              -- disable
        lcd_read   <= '1';
        waiting    <= '1';

      when st_idle =>
        lcd_enable <= '0';              -- disable
        lcd_read   <= '1';
        waiting    <= '1';

      when st_n | st_n1 =>
        lcd_enable <= '0';              -- disable, waiting for setup
        lcd_read   <= '1';
        waiting    <= '0';

      when st_n2 | st_n3 | st_n4 | st_n5 | st_n6 | st_n7 =>
        lcd_enable <= '1';              -- enable, waiting
        lcd_read   <= '1';
        waiting    <= '0';
        
      when st_n8 =>
        lcd_enable <= '1';              -- enable, still waiting
        lcd_read   <= '0';
        waiting    <= '0';

      when st_n9 =>
        lcd_enable <= '1';              -- enable, still waiting
        lcd_read   <= '1';
        waiting    <= '0';

      when st_na =>
        lcd_enable <= '0';              -- disable, stop waiting
        lcd_read   <= '1';              --  hold inp data for 40ns
        waiting    <= '0';

      when st_nb =>
        lcd_enable <= '0';              -- disable, stop waiting
        lcd_read   <= '1';              --  hold inp data for 40ns
        waiting    <= '1';

      when others =>
        lcd_enable <= '0';              -- disable
        waiting    <= '1';
    end case;
  end process U_st_outputs;

end behavioral;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

