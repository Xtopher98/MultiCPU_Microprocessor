---------------------------------------------------------------
-- Arithmetic/Logic unit with add/sub, AND, OR, set less than
---------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity alu is 
  generic(width: integer := 32);
  port(a, b:       in  STD_LOGIC_VECTOR((width-1) downto 0);
       alucontrol: in  STD_LOGIC_VECTOR(3 downto 0);
       result:     inout STD_LOGIC_VECTOR((width-1) downto 0)
       );
end;

architecture behave of alu is
  signal b2, sum, shiftLL, shiftRL: STD_LOGIC_VECTOR((width-1) downto 0);
begin

  -- hardware inverter for 2's complement 
  b2 <= not b when alucontrol(3) = '1' else b;
  
  -- hardware adder
  sum <= a + b2 + alucontrol(3);
  
  
  -- shift left
  process(alucontrol, a, b2)
   begin
      for i in 0 to width-1 loop
          if b2 = std_logic_vector(to_unsigned(i,width)) then
              shiftLL <= std_logic_vector( unsigned(a) sll i );
          end if;
      end loop;
   end process;
   
   -- shift right
  process(alucontrol, a, b2)
   begin
      for i in 0 to width-1 loop
          if b2 = std_logic_vector(to_unsigned(i,width)) then
              shiftRL <= std_logic_vector( unsigned(a) sll i );
          end if;
      end loop;
   end process;
  
  -- determine alu operation from alucontrol bits 0 and 1
  with alucontrol(2 downto 0) select result <=
    a and b when "101",
    sum     when "000",
    shiftLL when "010",
    shiftRL when "011",
    not a   when others; --Error handling defaults to not a. Not is usually sent as 1111
end;
