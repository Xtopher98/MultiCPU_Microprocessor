library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all; -- use this instead of STD_LOGIC_ARITH

ENTITY alu_sim IS
END alu_sim;

ARCHITECTURE behavior OF alu_sim IS
COMPONENT alu
      generic(width: integer := 32);
      port(a, b:       in  STD_LOGIC_VECTOR((width-1) downto 0);
           alucontrol: in  STD_LOGIC_VECTOR(3 downto 0);
           result:     inout STD_LOGIC_VECTOR((width-1) downto 0)
           );
END COMPONENT;

--Inputs
signal a : std_logic_vector(3 downto 0) := (others => '0');
signal b : std_logic_vector(3 downto 0) := (others => '0');
signal op : std_logic_vector(3 downto 0) := (others => '0');
--Outputs
signal y : std_logic_vector(3 downto 0);
BEGIN
   uut: alu generic map(width=>4) PORT MAP ( a => std_logic_vector(a), b=>std_logic_vector(b), alucontrol=>std_logic_vector(op), result => y );
   stim_proc: process
   variable i: unsigned(11 downto 0) := (others=>'0');
   variable tempI: std_logic_vector(11 downto 0) := (others=>'0');
   variable shiftLL: std_logic_vector(3 downto 0) := (others=>'0');
   variable shiftRL: std_logic_vector(3 downto 0) := (others=>'0');


   begin
      loop
            i := i+1;
            tempI := std_logic_vector(i);
            a <= tempI(3 downto 0);
            b <= tempI(7 downto 4);
            op <= tempI(11 downto 8);
            
            wait for 2 ns;
            -- shift left
            for i in 0 to 3 loop
                  if b = std_logic_vector(to_unsigned(i,4)) then
                        shiftLL := std_logic_vector( unsigned(a) sll i );
                  end if;
            end loop;
      
            -- shift right
            for i in 0 to 3 loop
                  if b = std_logic_vector(to_unsigned(i,4)) then
                        shiftRL := std_logic_vector( unsigned(a) sll i );
                  end if;
            end loop;
      
      if op = "0000" then
            assert y=(a+b) report "Failed for a = " & integer'image(to_integer(unsigned(a))) & ", b = " &integer'image(to_integer(unsigned(b))) & " and op = " &integer'image(to_integer(unsigned(op)));
      elsif op = "0010" then
            assert y=shiftLL report "Failed for a = " & integer'image(to_integer(unsigned(a))) & ", b = " &integer'image(to_integer(unsigned(b))) & " and op = " &integer'image(to_integer(unsigned(op)));
      elsif op = "0011" then
            assert y=shiftRL report "Failed for a = " & integer'image(to_integer(unsigned(a))) & ", b = " &integer'image(to_integer(unsigned(b))) & " and op = " &integer'image(to_integer(unsigned(op))); 
      elsif op = "0101" then
            assert y=(a and b) report "Failed for a = " & integer'image(to_integer(unsigned(a))) & ", b = " &integer'image(to_integer(unsigned(b))) & " and op = " &integer'image(to_integer(unsigned(op)));
      elsif op = "1000" then
            assert y=(a-b) report "Failed for a = " & integer'image(to_integer(unsigned(a))) & ", b = " &integer'image(to_integer(unsigned(b))) & " and op = " &integer'image(to_integer(unsigned(op))); 
      elsif op = "1111" then
            assert y = (not a) report "Failed for a = " & integer'image(to_integer(unsigned(a))) & ", b = " &integer'image(to_integer(unsigned(b))) & " and op = " &integer'image(to_integer(unsigned(op))); 
      end if;
      end loop;
      wait;
      
   end process;
END;
