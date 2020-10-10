library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.gpu.ALL;

entity instrGetter is 
  port(instr:    out  STD_LOGIC_VECTOR((instrWidth-1) downto 0);
        qmarkVal:    in   STD_LOGIC_VECTOR((bitwidth-1) downto 0);
        clk, jump, brchZ, brchN: in STD_LOGIC
       );
end;

architecture behave of instrGetter is
  signal currentInst : STD_LOGIC_VECTOR((instrWidth -1) downto 0);
  signal current, jumpAddr: STD_LOGIC_VECTOR(5 downto 0) := (others=>'0');
  signal toFlip: STD_LOGIC;
  component imem is -- instruction memory
  port(a:  in  STD_LOGIC_VECTOR(5 downto 0);
    rd: out STD_LOGIC_VECTOR((width-1) downto 0));
  end component;

  begin
    jumpAddr <= currentInst(5 downto 0);
    instr <= currentInst;
    instructionMemory: imem port map(a => current, rd=> currentInst);
    

    process(brchZ, jump, brchN, qmarkVal) 
    variable a, b, c: STD_LOGIC;
    begin
      if(unsigned(qmarkVal) = 0) then
        a := '1';
      else
        a:='0';
      end if;
      
      if(brchZ = '1') then
        b := a;
      else
        b := jump;  
      end if;

      if(brchN = '1') then
        c := qmarkVal(bitwidth-1);
      else
        c:= b;
      end if;
      
      toFlip <= c;

    end process;

    process(clk, jumpAddr, current) begin
    if (rising_edge(clk)) then
      if (toFlip = '1') then
        current <= jumpAddr;
      else
        current <= STD_LOGIC_VECTOR(unsigned(current)+1);
      end if;
    end if;
    end process;

    

end ;
