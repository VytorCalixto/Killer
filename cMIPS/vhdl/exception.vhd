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


-------------------------------------------------------------------------
-- Interrupt/exception pipeline registers
-------------------------------------------------------------------------


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- exception IF-RF
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_WIRES.all;
use work.p_EXCEPTION.all;
entity reg_excp_IF_RF is
  port(clk, rst, ld: in  std_logic;
       IF_excp_type: in  exception_type;
       RF_excp_type: out exception_type;
       PC_abort:     in  boolean;
       RF_PC_abort:  out boolean;
       IF_PC:        in  reg32;
       RF_PC:        out reg32);
end reg_excp_IF_RF;

architecture funcional of reg_excp_IF_RF is
begin
  process(clk, rst, ld)
  begin
    if rising_edge(clk) then
      if ld = '0' then
        RF_excp_type <= IF_excp_type ;
        RF_PC_abort  <= PC_abort     ;
        RF_PC        <= IF_PC        ;
      end if;
    end if;
  end process;
end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- exception RF-EX
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_WIRES.all;
use work.p_EXCEPTION.all;
entity reg_excp_RF_EX is
  port(clk, rst, ld: in  std_logic;
       RF_can_trap:     in  reg2;
       EX_can_trap:     out reg2;
       RF_exception:    in  exception_type;
       EX_exception:    out exception_type;
       RF_trap_instr:   in  instr_type;
       EX_trap_instr:   out instr_type;
       RF_cop0_reg:     in  reg5;
       EX_cop0_reg:     out reg5;
       RF_cop0_sel:     in  reg3;
       EX_cop0_sel:     out reg3;
       RF_is_delayslot: in  std_logic;
       EX_is_delayslot: out std_logic;
       RF_PC_abort:     in  boolean;
       EX_PC_abort:     out boolean;
       RF_PC:           in  reg32;
       EX_PC:           out reg32;
       RF_nmi:          in  std_logic;
       EX_nmi:          out std_logic;       
       RF_interrupt:    in  std_logic;
       EX_interrupt:    out std_logic;
       RF_int_req:      in  reg8;
       EX_int_req:      out reg8;
       RF_tr_is_equal:  in  std_logic;
       EX_tr_is_equal:  out std_logic;
       RF_tr_less_than: in  std_logic;
       EX_tr_less_than: out std_logic);
end reg_excp_RF_EX;

architecture funcional of reg_excp_RF_EX is
begin
  process(clk, rst, ld)
  begin
    if rst = '0' then
      EX_can_trap     <= b"00";
      EX_is_delayslot <= '0';
    elsif rising_edge(clk) then
      if ld = '0' then
        EX_can_trap     <= RF_can_trap     ;
        EX_exception    <= RF_exception    ;
        EX_trap_instr   <= RF_trap_instr   ;
        EX_cop0_reg     <= RF_cop0_reg     ;
        EX_cop0_sel     <= RF_cop0_sel     ;
        EX_is_delayslot <= RF_is_delayslot ;
        EX_PC_abort     <= RF_PC_abort     ;
        EX_PC           <= RF_PC           ;
        EX_nmi          <= RF_nmi          ;
        EX_interrupt    <= RF_interrupt    ;
        EX_int_req      <= RF_int_req      ;
        EX_tr_is_equal  <= RF_tr_is_equal  ;
        EX_tr_less_than <= RF_tr_less_than ;
      end if;
    end if;
  end process;
end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- exception EX-MEM
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_WIRES.all;
use work.p_EXCEPTION.all;
entity reg_excp_EX_MM is
  port(clk, rst, ld:  in  std_logic;
       EX_can_trap:   in  reg2;
       MM_can_trap:   out reg2;
       EX_excp_type:  in  exception_type;
       MM_excp_type:  out exception_type;
       EX_PC:         in  reg32;
       MM_PC:         out reg32;
       EX_cop0_LLbit: in  std_logic;
       MM_cop0_LLbit: out std_logic;
       addrError:     in  boolean;
       MM_abort:      out boolean;
       EX_is_delayslot: in  std_logic;
       MM_is_delayslot: out std_logic;
       EX_cop0_a_c:   in  reg5;
       MM_cop0_a_c:   out reg5;
       EX_cop0_val:   in  reg32;
       MM_cop0_val:   out reg32;
       EX_trapped:    in  std_logic;
       MM_ex_trapped: out std_logic;
       EX_mfc0:       in  std_logic;
       MM_mfc0:       out std_logic);
end reg_excp_EX_MM;

architecture funcional of reg_excp_EX_MM is
begin
  process(clk, rst, ld)
  begin
    if rst = '0' then
      MM_can_trap   <= b"00";
      MM_cop0_LLbit <= '0';
      MM_ex_trapped <= '0';
    elsif rising_edge(clk) then
      if ld = '0' then
        MM_excp_type    <= EX_excp_type  ;
        MM_can_trap     <= EX_can_trap   ;
        MM_PC           <= EX_PC         ;
        MM_cop0_LLbit   <= EX_cop0_LLbit ;
        MM_abort        <= addrError     ;
        MM_is_delayslot <= EX_is_delayslot;
        MM_cop0_a_c     <= EX_cop0_a_c   ;
        MM_cop0_val     <= EX_cop0_val   ;
        MM_ex_trapped   <= EX_trapped    ;
        MM_mfc0         <= EX_mfc0       ;
      end if;
    end if;
  end process;
end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- exception MEM-WB
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use work.p_WIRES.all;
use work.p_EXCEPTION.all;
entity reg_excp_MM_WB is
  port(clk, rst, ld:  in  std_logic;
       MM_can_trap:   in  reg2;
       WB_can_trap:   out reg2;
       MM_excp_type:  in  exception_type;
       WB_excp_type:  out exception_type;
       MM_PC:         in  std_logic_vector;
       WB_PC:         out std_logic_vector;
       MM_cop0_LLbit: in  std_logic;
       WB_cop0_LLbit: out std_logic;
       MM_abort:      in  boolean;
       WB_abort:      out boolean;
       MM_is_delayslot: in  std_logic;
       WB_is_delayslot: out std_logic;
       MM_cop0_a_c:   in  reg5;
       WB_cop0_a_c:   out reg5;
       MM_cop0_val:   in  reg32;
       WB_cop0_val:   out reg32);
end reg_excp_MM_WB;

architecture funcional of reg_excp_MM_WB is
begin
  process(clk, rst, ld)
  begin
    if rst = '0' then
      WB_can_trap   <= b"00";
      WB_cop0_LLbit <= '0';
      WB_abort      <=  FALSE;
    elsif rising_edge(clk) then
      if ld = '0' then
        WB_excp_type    <= MM_excp_type  ;
        WB_PC           <= MM_PC         ;
        WB_can_trap     <= MM_can_trap   ;
        WB_cop0_LLbit   <= MM_cop0_LLbit ;
        WB_abort        <= MM_abort      ;
        WB_is_delayslot <= MM_is_delayslot;
        WB_cop0_a_c     <= MM_cop0_a_c   ;
        WB_cop0_val     <= MM_cop0_val   ;
      end if;
    end if;
  end process;

end funcional;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

