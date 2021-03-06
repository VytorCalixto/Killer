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
-- testbench for classicalMIPS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library altera;
use altera.altera_syn_attributes.all;

use work.p_wires.all;
use work.p_memory.all;

entity tb_cMIPS is
        port
        (
-- {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!
                clock_50mhz   : in std_logic;
                clock1_50mhz  : in std_logic;
                clock2_50mhz  : in std_logic;
                clock3_50mhz  : in std_logic;
                
                gpio0_clkin  : in std_logic_vector(1 downto 0);
                gpio0_clkout : in std_logic_vector(1 downto 0);
                gpio0_d      : in std_logic_vector(31 downto 0);

                gpio1_clkin  : in std_logic_vector(1 downto 0);
                gpio1_clkout : in std_logic_vector(1 downto 0);
                gpio1_d      : in std_logic_vector(31 downto 0);
                
                i2c_overtempn : in std_logic;
                i2c_scl : in std_logic;
                i2c_sda : in std_logic;

                key   : in  std_logic_vector(11  downto 0);
                
                lcd_backlight : out std_logic;
                lcd_d  : inout std_logic_vector(7 downto 0);
                lcd_en : out std_logic;
                lcd_rs : out std_logic;
                lcd_rw : out std_logic;

                ledm_c  : in std_logic_vector(4 downto 0);
                ledm_r  : in std_logic_vector(7 downto 0);

                led_r : out std_logic;
                led_g : out std_logic;
                led_b : out std_logic;
                
                proto_a  : in std_logic_vector(7 downto 0);
                proto_b  : in std_logic_vector(7 downto 0);

                sw    : in  std_logic_vector(3 downto 0);

                disp1 : out std_logic_vector (7 downto 0);
                disp0 : out std_logic_vector (7 downto 0);
                
                dac_sclk : in std_logic;
                dac_din  : in std_logic;
                dac_clr  : in std_logic;
                dac_csn  : in std_logic;
                
                adc_ub    : in std_logic;
                adc_sel   : in std_logic;
                adc_sd    : in std_logic;
                adc_sclk  : in std_logic;
                adc_refsel : in std_logic;
                adc_dout2 : in std_logic;
                adc_dout1 : in std_logic;
                adc_csn   : in std_logic;
                adc_cnvst : in std_logic;

                vga_b  : in  std_logic_vector(3 downto 0);
                vga_g  : in  std_logic_vector(3 downto 0);
                vga_r  : in  std_logic_vector(3 downto 0);
                vga_hs : in std_logic;
                vga_vs : in std_logic;
                
                uart_cts : in  std_logic;
                uart_rts : out std_logic;
                uart_rxd : in  std_logic;
                uart_txd : out std_logic;

                usb_d    : in  std_logic_vector(7 downto 0);
                usb_powerenn : in std_logic;
                usb_rd   : in std_logic;
                usb_rxfn : in std_logic;
                usb_txen : in std_logic;
                usb_wr   : in std_logic;

                sma_clkin  : in std_logic;
                sma_clkin1 : in std_logic;
                sma_clkout : in std_logic;
                
                sd_cdn : in std_logic;
                sd_clk : in std_logic;
                sd_cmd : in std_logic;
                sd_d   : in std_logic_vector(3 downto 0);

                eth_col : in std_logic;
                eth_crs : in std_logic;
                eth_mdc : in std_logic;
                eth_mdio : in std_logic;
                eth_rstn : in std_logic;
                eth_rxc : in std_logic;
                eth_rxd : in  std_logic_vector(3 downto 0);
                eth_rxdv : in std_logic;
                eth_rxer : in std_logic;
                eth_txc : in std_logic;
                eth_txd : in  std_logic_vector(3 downto 0);
                eth_txen : in std_logic;
                eth_txer : in std_logic;

                sdram_a   : in std_logic_vector(12 downto 0);
                sdram_ba  : in std_logic_vector(1 downto 0);
                sdram_cke : in std_logic;
                sdram_clk : in std_logic;
                sdram_csn : in std_logic;
                sdram_d   : in std_logic_vector(15 downto 0);
                sdram_ldqm : in std_logic;
                sdram_rasn : in std_logic;
                sdram_udqm : in std_logic;
                sdram_wen : in std_logic;
                sdram_casn : in std_logic

                -- flash_data0 : in  std_logic;
                -- flash_dclk :  in  std_logic;
                -- flash_cs0n :  out std_logic;
                -- flash_asdo :  out std_logic

-- {ALTERA_IO_END} DO NOT REMOVE THIS LINE!

        );

-- {ALTERA_ATTRIBUTE_BEGIN} DO NOT REMOVE THIS LINE!
-- {ALTERA_ATTRIBUTE_END} DO NOT REMOVE THIS LINE!
end tb_cMIPS;

architecture ppl_type of tb_cMIPS is
-- architecture ppl_type of tb_cMIPS is

-- {ALTERA_COMPONENTS_BEGIN} DO NOT REMOVE THIS LINE!
-- {ALTERA_COMPONENTS_END} DO NOT REMOVE THIS LINE!

  component FFD is
    port(clk, rst, set, D : in std_logic; Q : out std_logic);
  end component FFD;

  component LCD_display is
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
  end component LCD_display;

  component to_7seg is
    port (rst      : in  std_logic;
          clk      : in  std_logic;
          sel      : in  std_logic;
          rdy      : out std_logic;
          wr       : in  std_logic;
          data     : in  std_logic_vector;
          display0 : out std_logic_vector;
          display1 : out std_logic_vector);
  end component to_7seg;

  component read_keys is
    generic (DEB_CYCLES : natural);
    port (rst      : in  std_logic;
          clk      : in  std_logic;
          sel      : in  std_logic;
          rdy      : out std_logic;
          data     : out reg32;
          kbd      : in  std_logic_vector (11 downto 0);
          sw       : in  std_logic_vector (3 downto 0));
  end component read_keys;


  component print_data is
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          rdy     : out std_logic;
          wr      : in  std_logic;
          addr    : in  std_logic_vector;
          data    : in  std_logic_vector);
  end component print_data;

  component to_stdout is
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          rdy     : out std_logic;
          wr      : in  std_logic;
          addr    : in  std_logic_vector;
          data    : in  std_logic_vector);
  end component to_stdout;

  component write_data_file is
    generic (OUTPUT_FILE_NAME : string);
    port (rst      : in  std_logic;
          clk      : in  std_logic;
          sel      : in  std_logic;
          rdy      : out std_logic;
          wr       : in  std_logic;
          addr     : in  std_logic_vector;
          data     : in  std_logic_vector;
          byte_sel : in  std_logic_vector;
          dump_ram : out std_logic);
  end component write_data_file;

  component read_data_file is
    generic (INPUT_FILE_NAME : string);
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          rdy     : out std_logic;
          wr      : in  std_logic;
          addr    : in  std_logic_vector;
          data    : out std_logic_vector;
          byte_sel: in  std_logic_vector);
  end component read_data_file;

  component do_interrupt is
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          wr      : in    std_logic;
          addr    : in    std_logic_vector;
          data_inp : in   std_logic_vector;
          data_out : out  std_logic_vector;
          irq      : out  std_logic);
  end component do_interrupt;

  component simple_uart is
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          wr      : in    std_logic;
          addr    : in    std_logic;
          data_inp : in   std_logic_vector;
          data_out : out  std_logic_vector;
          txdat   : out   std_logic;
          rxdat   : in    std_logic;
          rts     : out   std_logic;
          cts     : in    std_logic;
          irq     : out   std_logic;
          bit_rt  : out   std_logic_vector);-- communication speed - TB only
  end component simple_uart;

  component remota is
    generic(OUTPUT_FILE_NAME : string; INPUT_FILE_NAME : string);
    port(rst, clk  : in  std_logic;
         start     : in  std_logic;
         inpDat    : in  std_logic;    -- serial input
         outDat    : out std_logic;    -- serial output
         bit_rt    : in  std_logic_vector);
  end component remota;

  component sys_stats is
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          wr      : in    std_logic;
          addr    : in    std_logic_vector;
          data    : out   std_logic_vector;
          cnt_dc_ref    : in  integer;
          cnt_dc_rd_hit : in  integer;
          cnt_dc_wr_hit : in  integer;
          cnt_dc_flush  : in  integer;
          cnt_ic_ref : in  integer;
          cnt_ic_hit : in  integer);
  end component sys_stats;

  component ram_addr_decode is
    port (rst         : in  std_logic;
          cpu_d_aVal  : in  std_logic;
          addr        : in  std_logic_vector;
          aVal        : out std_logic;
          dev_select  : out std_logic_vector);
  end component ram_addr_decode;

  component io_addr_decode is
    port (rst         : in  std_logic;
          clk         : in  std_logic;    -- no use, except in synch-ing asserts
          cpu_d_aVal  : in  std_logic;
          addr        : in  std_logic_vector;
          dev_select  : out std_logic_vector;
          print_sel   : out std_logic;
          stdout_sel  : out std_logic;
          stdin_sel   : out std_logic;
          read_sel    : out std_logic;
          write_sel   : out std_logic;
          counter_sel : out std_logic;
          FPU_sel     : out std_logic;
          uart_sel    : out std_logic;
          sstats_sel  : out std_logic;
          dsp7seg_sel : out std_logic;
          keybd_sel   : out std_logic;
          lcd_sel     : out std_logic;
          not_waiting : in  std_logic);
  end component io_addr_decode;

  component inst_addr_decode is
    port (rst         : in  std_logic;
          cpu_i_aVal  : in  std_logic;
          addr        : in  std_logic_vector;
          aVal        : out std_logic);
  end component inst_addr_decode;
    
  component simul_ROM is 
    generic (LOAD_FILE_NAME : string);
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          strobe  : in    std_logic;
          addr    : in    std_logic_vector;
          data    : out   std_logic_vector);
  end component simul_ROM;

  component fpga_ROM is 
    generic (LOAD_FILE_NAME : string);
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          strobe  : in    std_logic;
          addr    : in    std_logic_vector;
          data    : out   std_logic_vector);
  end component fpga_ROM;

  component simul_RAM is
    generic (LOAD_FILE_NAME : string; DUMP_FILE_NAME : string);
    port (rst      : in    std_logic;
          clk      : in    std_logic;
          sel      : in    std_logic;
          rdy      : out   std_logic;
          wr       : in    std_logic;
          strobe   : in    std_logic;
          addr     : in    std_logic_vector;
          data_inp : in    std_logic_vector;
          data_out : out   std_logic_vector;
          byte_sel : in    std_logic_vector;
          dump_ram : in    std_logic);
  end component simul_RAM;

  component fpga_RAM is
    generic (LOAD_FILE_NAME : string; DUMP_FILE_NAME : string);
    port (rst      : in    std_logic;
          clk      : in    std_logic;
          sel      : in    std_logic;
          rdy      : out   std_logic;
          wr       : in    std_logic;
          strobe   : in    std_logic;          
          addr     : in    std_logic_vector;
          data_inp : in    std_logic_vector;
          data_out : out   std_logic_vector;
          byte_sel : in    std_logic_vector;
          dump_ram : in    std_logic);
  end component fpga_RAM;

  component fake_I_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          ic_reset : out   std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data : out   std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_addr : out   std_logic_vector;
          mem_data : in    std_logic_vector;
          ref_cnt  : out   integer;
          hit_cnt  : out   integer);
  end component fake_I_CACHE;

  component I_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          ic_reset : out   std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data : out   std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_addr : out   std_logic_vector;
          mem_data : in    std_logic_vector;
          ref_cnt  : out   integer;
          hit_cnt  : out   integer);
  end component I_CACHE;

  component I_CACHE_fpga is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          ic_reset : out   std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data : out   std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_addr : out   std_logic_vector;
          mem_data : in    std_logic_vector;
          ref_cnt  : out   integer;
          hit_cnt  : out   integer);
  end component I_CACHE_fpga;
  
  component fake_D_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_wr   : in    std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data_inp : in  std_logic_vector;
          cpu_data_out : out std_logic_vector;
          cpu_xfer : in    std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_wr   : out   std_logic;
          mem_addr : out   std_logic_vector;
          mem_data_inp : in  std_logic_vector;
          mem_data_out : out std_logic_vector;
          mem_xfer : out   std_logic_vector;
          ref_cnt  : out   integer;
          rd_hit_cnt : out integer;
          wr_hit_cnt : out integer;
          flush_cnt  : out integer);
  end component fake_D_CACHE;

  component D_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_wr   : in    std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data_inp : in  std_logic_vector;
          cpu_data_out : out std_logic_vector;
          cpu_xfer : in    std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_wr   : out   std_logic;
          mem_addr : out   std_logic_vector;
          mem_data_inp : in  std_logic_vector;
          mem_data_out : out std_logic_vector;
          mem_xfer : out   std_logic_vector;
          ref_cnt  : out   integer;
          rd_hit_cnt : out integer;
          wr_hit_cnt : out integer;
          flush_cnt  : out integer);
  end component D_CACHE;

  
  component core is
    port (rst    : in    std_logic;
          clk    : in    std_logic;
          phi2   : in    std_logic;
          i_aVal : out   std_logic;
          i_wait : in    std_logic;
          i_addr : out   std_logic_vector;
          instr  : in    std_logic_vector;
          d_aVal : out   std_logic;
          d_wait : in    std_logic;
          d_addr : out   std_logic_vector;
          data_inp : in  std_logic_vector;
          data_out : out std_logic_vector;
          wr     : out   std_logic;
          b_sel  : out   std_logic_vector;
          nmi    : in    std_logic;
          irq    : in    std_logic_vector);
  end component core;

  component mf_altpll port (
    inclk0          : IN  STD_LOGIC;
    c0              : OUT STD_LOGIC;
    c1              : OUT STD_LOGIC;
    c2              : OUT STD_LOGIC;
    c3              : OUT STD_LOGIC;
    c4              : OUT STD_LOGIC;
    locked          : OUT STD_LOGIC);
  end component mf_altpll;

  component mf_altpll_io port (
    areset          : IN  STD_LOGIC;
    inclk0          : IN  STD_LOGIC;
    c0              : OUT STD_LOGIC;
    c1              : OUT STD_LOGIC;
    c2              : OUT STD_LOGIC);
  end component mf_altpll_io;

  component mf_altclkctrl port (
    inclk  : IN  STD_LOGIC;
    outclk : OUT STD_LOGIC); 
  end component mf_altclkctrl;

  signal clk,clkin,clk_locked,clk_50mhz : std_logic;
  signal clk2x, clk4x,clk4x0,clk4x180 : std_logic;
  signal phi0,phi2,phi3,phi0in,phi2in,phi3in : std_logic;
  signal cpu_i_aVal, cpu_i_wait, wr, cpu_d_aVal, cpu_d_wait : std_logic;
  signal rst, ic_reset, cpu_reset : std_logic;
  signal a_reset, a_rst0,a_rst1,a_rst2,a_rst3,a_rst4,a_rst5,a_rst6,a_rst7,a_rst8,a_rst9, a_rstA, a_rstB, a_rst :std_logic;
  signal nmi : std_logic;
  signal irq : reg6;
  signal inst_aVal, inst_wait, rom_rdy : std_logic := '1';
  signal data_aVal, data_wait, ram_rdy, mem_wr, mem_strobe : std_logic;
  signal cpu_xfer, mem_xfer, dev_select, dev_select_ram, dev_select_io : reg4;
  signal io_print_sel,   io_print_wait   : std_logic := '1';
  signal io_stdout_sel,  io_stdout_wait  : std_logic := '1';
  signal io_stdin_sel,   io_stdin_wait   : std_logic := '1';
  signal io_write_sel,   io_write_wait   : std_logic := '1';
  signal io_read_sel,    io_read_wait    : std_logic := '1';
  signal io_counter_sel, io_counter_wait : std_logic := '1';
  signal io_fpu_sel,     io_fpu_wait     : std_logic := '1';
  signal io_uart_sel,    io_uart_wait    : std_logic := '1';
  signal io_sstats_sel,  io_sstats_wait  : std_logic := '1';
  signal io_7seg_sel,    io_7seg_wait    : std_logic := '1';
  signal io_keys_sel,    io_keys_wait    : std_logic := '1';
  signal io_lcd_sel,     io_lcd_wait     : std_logic := '1';
  signal d_cache_d_out, stdin_d_out, read_d_out, counter_d_out : reg32;
  signal fpu_d_out, uart_d_out, sstats_d_out, keybd_d_out : reg32;
  signal lcd_d_out : reg32;
  
  signal counter_irq : std_logic;
  signal io_wait, not_waiting : std_logic;
  signal i_addr,d_addr,p_addr : reg32;
  signal datrom, datram_inp,datram_out, cpu_instr : reg32;
  signal cpu_data_inp, cpu_data_out, cpu_data : reg32;
  signal mem_i_sel, mem_d_sel: std_logic;
  signal mem_i_addr, mem_addr, mem_d_addr: reg32;
  signal cnt_i_ref,cnt_i_hit : integer;
  signal cnt_d_ref,cnt_d_rd_hit,cnt_d_wr_hit,cnt_d_flush : integer;

  signal dump_ram : std_logic;
  
  signal uart_irq, start_remota : std_logic;
  signal bit_rt : reg3;


begin
-- {ALTERA_INSTANTIATION_BEGIN} DO NOT REMOVE THIS LINE!
-- {ALTERA_INSTANTIATION_END} DO NOT REMOVE THIS LINE!
  
  pll : mf_altpll port map (inclk0 => clock_50mhz, locked => clk_locked,
    c0 => phi0in, c1 => mem_strobe, c2 => phi2in, c3 => phi3in, c4 => clkin);

  -- pll_io : mf_altpll_io port map (areset => rst, inclk0 => clock_50mhz,
  --   c0 => clk2x, c1 => clk4x0, c2 => clk4x180);
  clk2x    <= '0';
  clk4x0   <= '0';
  clk4x180 <= '0';
  
  mf_altclkctrl_inst_clk : mf_altclkctrl port map (
    inclk => clkin, outclk => clk);

  mf_altclkctrl_inst_clk4x : mf_altclkctrl port map (
    inclk => clk4x180, outclk => clk4x);

  mf_altclkctrl_inst_phi2 : mf_altclkctrl port map (
    inclk => phi2in, outclk => phi2);

  -- mf_altclkctrl_inst_phi0 : mf_altclkctrl port map (
  --   inclk => phi0in, outclk => phi0);
  -- mf_altclkctrl_inst_phi3 : mf_altclkctrl port map (
  --   inclk => phi3in, outclk => phi3);

  -- synchronize external asynchronous reset = key(9) at lower left
  a_reset <= not(key(9));
  U_SYNC_RESET0: FFD port map (clock_50mhz, a_reset, '1', '1',    a_rst0);
  U_SYNC_RESET1: FFD port map (clock_50mhz, '1',     '1', a_rst0, a_rst1);
  U_SYNC_RESET2: FFD port map (clock_50mhz, '1',     '1', a_rst1, a_rst2);

  -- pulse extender and debounce filter
  U_SYNC_RESET3: FFD port map (clock_50mhz, '1','1', a_rst2, a_rst3);
  U_SYNC_RESET4: FFD port map (clock_50mhz, '1','1', a_rst3, a_rst4);
  U_SYNC_RESET5: FFD port map (clock_50mhz, '1','1', a_rst4, a_rst5);
  U_SYNC_RESET6: FFD port map (clock_50mhz, '1','1', a_rst5, a_rst6);
  U_SYNC_RESET7: FFD port map (clock_50mhz, '1','1', a_rst6, a_rst7);
  a_rst8 <= (a_rst7 or a_rst2) and clk_locked;

  -- synchronize reset
  U_SYNC_RESET8: FFD port map (clk, '1','1', a_rst8, a_rst9);
  U_SYNC_RESET9: FFD port map (clk, '1','1', a_rst9, rst);

  -- synchronize cache-resets and external reset to reset the processor
  a_rstA <= rst and ic_reset;
  U_SYNC_RESETa: FFD port map (clk, rst, '1', a_rstA, a_rstB);
  U_SYNC_RESETb: FFD port map (clk, rst, '1', a_rstB, cpu_reset);


  cpu_i_wait <= inst_wait;
  cpu_d_wait <= data_wait and io_wait;
  io_wait    <= io_lcd_wait;
                -- '1'; io_print_wait and io_stdout_wait and io_stdin_wait and
                -- io_write_wait and io_read_wait and
                -- io_counter_wait and -- io_uart_wait and
                -- io_sstats_wait and --  io_fpu_wait
                -- io_7seg_wait and  io_keys_wait;

  not_waiting <= (inst_wait and data_wait); -- and io_wait);

  
  -- irq <= b"000000"; -- NO interrupt requests
  irq <= b"0000" & uart_irq & counter_irq; -- uart+counter interrupts
  -- irq <= b"00000" & counter_irq; -- counter interrupts
  -- irq <= b"000000"; -- no interrupts
  nmi <= '0'; -- input port to TB


  U_CORE: core port map (cpu_reset, clk, phi2,
                         cpu_i_aVal, cpu_i_wait, i_addr, cpu_instr,
                         cpu_d_aVal, cpu_d_wait, d_addr, cpu_data_inp, cpu_data,
                         wr, cpu_xfer, nmi, irq);

  U_INST_ADDR_DEC: inst_addr_decode
    port map (rst, cpu_i_aVal, i_addr, inst_aVal);
  
  U_I_CACHE: fake_i_cache   -- or i_cache
  -- U_I_CACHE: i_cache  -- or fake_i_cache
  -- U_I_CACHE: i_cache_fpga  -- or FPGA implementation 
    port map (rst, clk4x, ic_reset,
              inst_aVal, inst_wait, i_addr,      cpu_instr,
              mem_i_sel,  rom_rdy,   mem_i_addr, datrom, cnt_i_ref,cnt_i_hit);

  -- U_ROM: simul_ROM generic map ("prog.bin")
  U_ROM: fpga_ROM generic map ("prog.bin")
    port map (rst,clk, mem_i_sel,rom_rdy, phi2, mem_i_addr,datrom);

  U_IO_ADDR_DEC: io_addr_decode
    port map (rst,clk, cpu_d_aVal, d_addr, dev_select_io,
              io_print_sel, io_stdout_sel, io_stdin_sel,io_read_sel, 
              io_write_sel, io_counter_sel, io_fpu_sel, io_uart_sel,
              io_sstats_sel, io_7seg_sel, io_keys_sel, io_lcd_sel,
              not_waiting);

  U_DATA_ADDR_DEC: ram_addr_decode
    port map (rst, cpu_d_aVal, d_addr, data_aVal, dev_select_ram);

  dev_select <= dev_select_io or dev_select_ram;
  
  with dev_select select
    cpu_data_inp <= (others => 'X') when b"0000",
                    d_cache_d_out   when b"0001",
                 --    stdin_d_out     when b"0100",
                 --    read_d_out      when b"0101",
                    counter_d_out   when b"0111",
                 --    fpu_d_out       when b"1000",
                    uart_d_out      when b"1001",
                 --    sstats_d_out    when b"1010",
                 --    ext_data_inp    when b"1100",
                 --    sstats_d_out    when b"1010",
                    keybd_d_out     when b"1100",
                    lcd_d_out       when b"1101",
                    (others => 'X') when others;

  -- U_D_MMU: mem_d_addr <=        -- access Dcache with physical addresses
  --   std_logic_vector(unsigned(d_addr) - unsigned(x_DATA_BASE_ADDR));

  U_D_CACHE: fake_d_cache  -- or d_cache
  -- U_D_CACHE: d_cache  -- or fake_d_cache
    port map (rst, clk4x,
              data_aVal, data_wait, wr,
              d_addr, cpu_data, d_cache_d_out, cpu_xfer,
              mem_d_sel, ram_rdy,   mem_wr,
              mem_addr,  datram_inp, datram_out,   mem_xfer,
              cnt_d_ref, cnt_d_rd_hit, cnt_d_wr_hit, cnt_d_flush);

  -- U_RAM: simul_RAM generic map ("data.bin", "dump.data")
  U_RAM: fpga_RAM generic map ("data.bin", "dump.data")
    port map (rst, clk, mem_d_sel, ram_rdy, mem_wr, phi2,
              mem_addr, datram_out, datram_inp, mem_xfer, dump_ram);
  dump_ram <= '0';
  
  -- U_read_inp: read_data_file generic map ("input.data")
  --   port map (rst,clk, io_read_sel,  io_read_wait,  wr, d_addr, read_d_out,
  --             cpu_xfer);

  -- U_write_out: write_data_file generic map ("output.data")
  --   port map (rst,clk, io_write_sel, io_write_wait, wr, d_addr, cpu_data,
  --             cpu_xfer, dump_ram);

  -- U_print_data: print_data
  --   port map (rst,clk, io_print_sel, io_print_wait, wr, d_addr, cpu_data);

  -- U_to_stdout: to_stdout
  --  port map (rst,clk, io_stdout_sel, io_stdout_wait, wr, d_addr, cpu_data);

  U_simple_uart: simple_uart
    port map (rst,clk, io_uart_sel, open, -- io_uart_wait,
              wr, d_addr(2), cpu_data, uart_d_out,
              uart_txd, uart_rxd, uart_rts, uart_cts, uart_irq, bit_rt);

  -- start_remota <= '0', '1' after 100*CLOCK_PER;
  
  -- U_uart_remota: remota generic map ("serial.out","serial.inp")
  --   port map (rst, clk, start_remota, txdat, rxdat, bit_rt);

  -- U_FPU: FPU
  --   port map (rst,clk, io_FPU_sel, io_FPU_wait,
  --             wr, d_addr, cpu_data);

  U_interrupt_counter: do_interrupt     -- external counter+interrupt
    port map (rst,clk, io_counter_sel, open, -- io_counter_wait,
              wr, d_addr, cpu_data, counter_d_out, counter_irq);

  U_to_7seg: to_7seg
    port map (rst,clk,io_7seg_sel,io_7seg_wait,wr,cpu_data,disp0,disp1);

  U_read_keys: read_keys generic map (1000)
    port map (rst,clk, io_keys_sel,io_keys_wait,keybd_d_out,key,sw);

  led_r <= sw(2); -- keybd_d_out(6);
  led_g <= sw(1); -- keybd_d_out(5);
  led_b <= sw(0); -- keybd_d_out(4);


  U_LCD_display: LCD_display
    port map (rst, clk, io_lcd_sel, io_lcd_wait,
              wr, d_addr(2), cpu_data, lcd_d_out,
              lcd_d, lcd_rs, lcd_rw, lcd_en, open);
  lcd_backlight <= sw(3);
  
  -- U_sys_stats: sys_stats                -- CPU reads system counters
  --   port map (cpu_reset,clk, io_sstats_sel, io_sstats_wait,
  --            wr, d_addr, sstats_d_out,
  --             cnt_d_ref,cnt_d_rd_hit,cnt_d_wr_hit,cnt_d_flush,
  --             cnt_i_ref,cnt_i_hit);

end architecture ppl_type;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- instruction address decoding 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity inst_addr_decode is              -- CPU side triggers access
  port (rst         : in  std_logic;
        cpu_i_aVal  : in  std_logic;    -- CPU instr addr valid (act=0)
        addr        : in  reg32;        -- CPU address
        aVal        : out std_logic);   -- decoded address in range (act=0)
  constant LO_ADDR  : integer := 0;
  constant HI_ADDR  : integer := log2_ceil(INST_MEM_SZ);
end entity inst_addr_decode;

architecture behavioral of inst_addr_decode is
begin

  aVal <= '0' when ( cpu_i_aVal = '0' and rst = '1'
                     and (addr(HI_SEL_BITS downto LO_SEL_BITS)
                          =
                          x_INST_BASE_ADDR(HI_SEL_BITS downto LO_SEL_BITS)) )
          else '1';
      
end architecture behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- RAM address decoding 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity ram_addr_decode is              -- CPU side triggers access
  port (rst         : in  std_logic;
        cpu_d_aVal  : in  std_logic;    -- CPU data addr valid (active=0)
        addr        : in  reg32;        -- CPU address
        aVal        : out std_logic;    -- data address (act=0)
        dev_select  : out reg4);        -- select input to CPU
  constant LO_ADDR  : integer := 0;
  constant HI_ADDR  : integer := log2_ceil(DATA_MEM_SZ);
end entity ram_addr_decode;

architecture behavioral of ram_addr_decode is
begin

  aVal <= '0' when ( cpu_d_aVal = '0' and rst = '1'
                     and (addr(HI_SEL_BITS downto LO_SEL_BITS)
                          =
                          x_DATA_BASE_ADDR(HI_SEL_BITS downto LO_SEL_BITS)) )
          else '1';

  dev_select <= b"0001"
                when(cpu_d_aVal = '0' and rst = '1' and
                     (addr(HI_SEL_BITS downto LO_SEL_BITS)
                      =
                      x_DATA_BASE_ADDR(HI_SEL_BITS downto LO_SEL_BITS)))
          else b"0000";
      
end architecture behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- I/O address decoding 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity io_addr_decode is              -- CPU side triggers access
  port (rst         : in  std_logic;
        clk         : in  std_logic;    -- no use, except synch-ing asserts
        cpu_d_aVal  : in  std_logic;    -- CPU data addr valid (active=0)
        addr        : in  reg32;        -- CPU address
        dev_select  : out reg4;         -- select input to CPU
        print_sel   : out std_logic;    -- std_out (integer)   (act=0)
        stdout_sel  : out std_logic;    -- std_out (character) (act=0)
        stdin_sel   : out std_logic;    -- std_inp (character)  (act=0)
        read_sel    : out std_logic;    -- file read  (act=0)
        write_sel   : out std_logic;    -- file write (act=0)
        counter_sel : out std_logic;    -- interrupt counter (act=0)
        FPU_sel     : out std_logic;    -- floating point unit (act=0)
        UART_sel    : out std_logic;    -- floating point unit (act=0)
        SSTATS_sel  : out std_logic;    -- system statistics (act=0)
        dsp7seg_sel : out std_logic;    -- 7 segments display (act=0)
        keybd_sel   : out std_logic;    -- telephone keyboard (act=0)
        lcd_sel     : out std_logic;    -- telephone keyboard (act=0)
        not_waiting : in  std_logic);   -- no other device is waiting
  constant LO_ADDR : integer := log2_ceil(IO_ADDR_RANGE);
  constant HI_ADDR : integer := LO_ADDR + (IO_MAX_NUM_DEVS - 1);
end entity io_addr_decode;

architecture behavioral of io_addr_decode is
  signal aVal : std_logic;
begin

  aVal <= '0' when ( cpu_d_aVal = '0' and rst = '1' and not_waiting = '1'
                     and (addr(HI_SEL_BITS downto LO_SEL_BITS)
                          =
                          x_IO_BASE_ADDR(HI_SEL_BITS downto LO_SEL_BITS)) )
          else '1';
  
  U_decode: process(aVal, addr)
    variable dev_sel    : reg4;
    constant is_noise   : integer := 0;
    constant is_print   : integer := 2;
    constant is_stdout  : integer := 3;
    constant is_stdin   : integer := 4;
    constant is_read    : integer := 5;
    constant is_write   : integer := 6;
    constant is_count   : integer := 7;
    constant is_FPU     : integer := 8;
    constant is_UART    : integer := 9;
    constant is_SSTATS  : integer := 10;
    constant is_dsp7seg : integer := 11;
    constant is_keybd   : integer := 12;
    constant is_lcd     : integer := 13;
  begin

    print_sel   <= '1';
    stdout_sel  <= '1';
    stdin_sel   <= '1';
    read_sel    <= '1';
    write_sel   <= '1';
    counter_sel <= '1';
    FPU_sel     <= '1';
    UART_sel    <= '1';
    SSTATS_sel  <= '1';
    dsp7seg_sel <= '1';
    keybd_sel   <= '1';
    lcd_sel     <= '1';

    case to_integer(signed(addr(HI_ADDR downto LO_ADDR))) is
      when  0 => dev_sel     := std_logic_vector(to_signed(is_print, 4));
                 print_sel   <= aVal;
      when  1 => dev_sel     := std_logic_vector(to_signed(is_stdout, 4));
                 stdout_sel  <= aVal;
      when  2 => dev_sel     := std_logic_vector(to_signed(is_stdin, 4));
                 stdin_sel   <= aVal;
      when  3 => dev_sel     := std_logic_vector(to_signed(is_read, 4));
                 read_sel    <= aVal;
      when  4 => dev_sel     := std_logic_vector(to_signed(is_write, 4));
                 write_sel   <= aVal;
      when  5 => dev_sel     := std_logic_vector(to_signed(is_count, 4));
                 counter_sel <= aVal;
      when  6 => dev_sel     := std_logic_vector(to_signed(is_FPU, 4));
                 FPU_sel     <= aVal;
      when  7 => dev_sel     := std_logic_vector(to_signed(is_UART, 4));
                 UART_sel    <= aVal;
      when  8 => dev_sel     := std_logic_vector(to_signed(is_SSTATS, 4));
                 SSTATS_sel  <= aVal;
      when  9 => dev_sel     := std_logic_vector(to_signed(is_dsp7seg, 4));
                 dsp7seg_sel <= aVal;
      when 10 => dev_sel     := std_logic_vector(to_signed(is_keybd, 4));
                 keybd_sel   <= aVal;
      when 11 => dev_sel     := std_logic_vector(to_signed(is_lcd, 4));
                 lcd_sel     <= aVal;
      when others => dev_sel := std_logic_vector(to_signed(is_noise, 4));
    end case;
    -- assert false report "IO_addr "& SLV32HEX(addr);--DEBUG

    if aVal = '0' then
      dev_select <= dev_sel;
    else
      dev_select <= std_logic_vector(to_signed(is_noise, 4));
    end if;
    
  end process U_decode;
      
end architecture behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- --------------------------------------------------------------
configuration CFG_TB of TB_CMIPS is
	for ppl_type
        end for;
end configuration CFG_TB;
-- --------------------------------------------------------------

