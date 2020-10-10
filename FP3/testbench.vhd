library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all; -- use this instead of STD_LOGIC_ARITH

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS
component custom_gpu is 
  port(
      clk: in STD_LOGIC
       );
end component;

--Inputs
signal clk_tick : STD_LOGIC := '0';

BEGIN
   uut: custom_gpu PORT MAP ( clk => clk_tick );
   stim_proc: process
   begin
      for i in 0 to 512
      loop
            clk_tick <= not clk_tick;
            wait for 2 ns;
      end loop;
      wait;
      
   end process;
END;
