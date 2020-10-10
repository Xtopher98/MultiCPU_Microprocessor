library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;
use work.gpu.ALL;

entity localComputation is 
  port(
      globalRD2, memRA: in STD_LOGIC_VECTOR((bitwidth-1) downto 0);
      localRA1, localRA2, localWA3: in STD_LOGIC_VECTOR(4 downto 0);
      localRD1:                out STD_LOGIC_VECTOR((bitwidth-1) downto 0);
      alucontrol:               in STD_LOGIC_VECTOR(3 downto 0);
      clk, globalB, regWrite, globalStore, loadFlag: in STD_LOGIC
       );
end;

architecture behave of localComputation is
  component alu is 
  port(a, b:       in  STD_LOGIC_VECTOR((bitwidth-1) downto 0);
       alucontrol: in  STD_LOGIC_VECTOR(3 downto 0);
       result:     out STD_LOGIC_VECTOR((bitwidth-1) downto 0)
       );
  end component;

  component localRegister is 
  port(clk:           in  STD_LOGIC;
       regWrite, globalStore:           in  STD_LOGIC;

	   -- determine number of address bits based on generic width
       ra1, ra2, wa3: in  STD_LOGIC_VECTOR( 4 downto 0);
       wd3:           in  STD_LOGIC_VECTOR((bitwidth-1) downto 0);
       rd1, rd2:      out STD_LOGIC_VECTOR((bitwidth-1) downto 0));
  end component;

  signal lRD1, localRD2, localWD3, bIn, aluResult: STD_LOGIC_VECTOR((bitwidth-1) downto 0);
  begin
  
    mainALU: alu port map(a=>lRD1,b=>bIn,alucontrol=>alucontrol,result=>aluResult);

    mainLOCALREGISTER: localRegister port map(
        clk => clk,
        regWrite => regWrite, 
        globalStore => globalStore, 
        ra1 => localRA1, 
        ra2 => localRA2, 
        wa3 => localWA3, 
        wd3 => localWD3, 
        rd1=> lRD1, 
        rd2=> localRD2
        );
    localRD1 <= lRD1;
    bComp: process(globalB, localRD2, globalRD2) begin
        if(globalB = '1') then
            bIn <= globalRD2;
        else
            bIn <= localRD2;
        end if;
    end process;
    
    w3Result: process(loadFlag, aluResult, memRA) begin
        if(loadFlag = '1') then
            localWD3 <= memRA;
        else
            localWD3 <= aluResult;
        end if;
    end process;

end;
