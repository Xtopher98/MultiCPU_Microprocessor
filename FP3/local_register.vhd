---------------------------------------------------------------------
-- three-port register file
---------------------------------------------------------------------
-- TODO: Worth cutting down on num registers. Many will never be used
library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;
use work.gpu.ALL;

entity localRegister is
  port(clk:           in  STD_LOGIC;
       regWrite, globalStore:           in  STD_LOGIC;
	   -- determine number of address bits based on generic width
       ra1, ra2, wa3: in  STD_LOGIC_VECTOR( (integer(ceil(log2(real(bitwidth))))-1) downto 0);
       wd3:           in  STD_LOGIC_VECTOR((bitwidth-1) downto 0);
       rd1, rd2:      out STD_LOGIC_VECTOR((bitwidth-1) downto 0));
end;

architecture behave of localRegister is
  type ramtype is array ((bitwidth-1) downto 0) of STD_LOGIC_VECTOR((bitwidth-1) downto 0);
  signal mem: ramtype;
begin

  -- three-ported register file
  
  -- write to the third port on rising edge of clock
  -- write address is in wa3
  process(clk) begin
    if rising_edge(clk) then
        if regWrite = '1' then 
            if(globalStore = '0') then
                mem(to_integer(unsigned(wa3))) <= wd3;
            end if;
		end if;
    end if;
  end process;
  
  -- read mem from two separate ports 1 and 2 
  -- addresses are in ra1 and ra2
  process(ra1, ra2, mem) begin
    if ( to_integer(unsigned(ra1)) = 0) then 
		rd1 <= (others => '0'); -- register 0 holds 0
    else 
		rd1 <= mem(to_integer(unsigned(ra1)));
    end if;
	
    if ( to_integer(unsigned(ra2)) = 0) then 
		rd2 <= (others => '0'); -- register 0 holds 0
    else 
		rd2 <= mem(to_integer( unsigned(ra2)));
    end if;
  end process;
  
end;