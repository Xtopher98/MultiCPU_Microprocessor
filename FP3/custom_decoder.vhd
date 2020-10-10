
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use work.gpu.ALL;

entity maindec is -- main control decoder
  port(op:                   in  STD_LOGIC_VECTOR(5 downto 0);
       regWrite, memWrite:   out STD_LOGIC;
       loadFlag, immFlag:    out STD_LOGIC; 
       globalStore, globalB: out STD_LOGIC;
       brchZ, brchN:         out STD_LOGIC;
       jump:                 out STD_LOGIC;
       aluop:                out STD_LOGIC_VECTOR(3 downto 0));
end;

architecture behave of maindec is
  signal controls: STD_LOGIC_VECTOR(12 downto 0);
begin
  process(op) begin
    case op is
      when "100000" => controls <= "0000001000000";
      when "100001" => controls <= "010000100X000";
      when "100010" => controls <= "0101001000000";
      when "100011" => controls <= "1000001000000";
      when "100100" => controls <= "0010001001000";
      when "100101" => controls <= "0011001001000";
      when "100110" => controls <= "0101001001000";
      when "100111" => controls <= "0000001001000";
      when "101000" => controls <= "1000001001000";
      when "101001" => controls <= "010001100X000";
      when "101010" => controls <= "000001100X000";
      when "101011" => controls <= "100001100X000";
      when "101100" => controls <= "010101100X000";
      when "110000" => controls <= "000001101X000";
      when "110001" => controls <= "100001101X000";
      when "110010" => controls <= "001001101X000";
      when "110011" => controls <= "001101101X000";
      when "110100" => controls <= "010100101X000";
      when "010000" => controls <= "XXXX10001X000";
      when "010001" => controls <= "XXXX00111X000";
      when "010010" => controls <= "XXXX11001X000";
      when "000000" => controls <= "XXXX10000X000";
      when "000001" => controls <= "XXXX00110X000";
      when "000010" => controls <= "XXXX11000X000";
      when "000011" => controls <= "XXXX01110X000";
      when "010011" => controls <= "XXXX01111X000";
      when "010100" => controls <= "XXXX000XXX010"; 
      when "010101" => controls <= "XXXX000XXX001";
      when "010110" => controls <= "XXXX000XXX100";
      when others   => controls <= "-------------"; -- illegal op
    end case;
  end process;
  
  aluop        <= controls(12 downto 9);
  memWrite     <= controls(8);
  globalStore  <= controls(7);
  regWrite     <= controls(6);
  loadFlag     <= controls(5);
  immFlag      <= controls(4);
  globalB      <= controls(3);
  jump         <= controls(2);
  brchZ        <= controls(1);
  brchN        <= controls(0);
  
end;


