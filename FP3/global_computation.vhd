library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

use work.gpu.ALL;

entity globalComputation is 
  port(RD1, RD2:    in  STD_LOGIC_VECTOR((bitwidth-1) downto 0);
        instr:      in STD_LOGIC_VECTOR((bitwidth-1) downto 0);
        addr:       out STD_LOGIC_VECTOR((bitwidth-1) downto 0);
        res:        out STD_LOGIC_VECTOR((bitwidth-1) downto 0);
        alucontrol: in STD_LOGIC_VECTOR(3 downto 0);
        loadFlag:   in STD_LOGIC;
        immFlag:    in STD_LOGIC;
        RW:         in STD_LOGIC_VECTOR((bitwidth-1) downto 0)
       );
end;

architecture behave of globalComputation is
  component alu is 
  port(a, b:       in  STD_LOGIC_VECTOR((bitwidth-1) downto 0);
       alucontrol: in  STD_LOGIC_VECTOR(3 downto 0);
       result:     out STD_LOGIC_VECTOR((bitwidth-1) downto 0)
       );
  end component;

  component signext is 
  port(a: in  STD_LOGIC_VECTOR((bitwidth/2)-1 downto 0);
       y: out STD_LOGIC_VECTOR(bitwidth-1 downto 0));
    end component;

  signal bIn, aluResult, extendedInstr: STD_LOGIC_VECTOR((bitwidth-1) downto 0);
  begin
  
    globalalu: alu port map(a=>RD1,b=>bIn,alucontrol=>alucontrol,result=>aluResult);
    
    signExtend: signext port map(a=>instr(((bitwidth/2)-1) downto 0), y=>extendedInstr);

    calcbIn: process(RD2, RD1, loadFlag, immFlag, extendedInstr)
    variable a: STD_LOGIC_VECTOR((bitwidth-1) downto 0);
    begin
        if(loadFlag = '1') then
            a := RD1;
        else
            a := RD2;
        end if;
        
        if(immFlag = '1') then
            bIn <=extendedInstr;
        else
            bIn <= a;
        end if;

    end process;

    addr <= bIn;

    calcResult: process(aluResult, loadFlag, RW) begin
        if(loadFlag = '1') then
            res <= RW;
        else
            res <= aluResult;
        end if;
    end process;
end;
