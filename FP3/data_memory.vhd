------------------------------------------------------------------------------
-- Data Memory
------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use STD.TEXTIO.all;
use IEEE.STD_LOGIC_UNSIGNED.all;  
use IEEE.NUMERIC_STD.all;


use work.gpu.all;

entity dmem is -- data memory
  
  port(clk, memWrite, globalStore:  in STD_LOGIC;
       a, sw:    in STD_LOGIC_VECTOR((bitwidth-1) downto 0);
       sa:       in ARRAYBUS;
       rw:       out STD_LOGIC_VECTOR((bitwidth-1) downto 0);
       ra:       out ARRAYBUS);
end;



architecture behave of dmem is
  type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR((bitwidth-1) downto 0);
  -- function to initialize the instruction memory from a data file
  impure function InitRamFromFile ( RamFileName : in string ) return RamType is

    variable ch: character;
    variable index : integer;
    variable result: signed((bitwidth-1) downto 0);
    variable tmpResult: signed(63 downto 0);
    file mem_file: TEXT is in RamFileName;
    variable L: line;
    variable RAM : ramtype;
    begin
      -- initialize memory from a file
      for i in 0 to 63 loop -- set all contents low
        RAM(i) := std_logic_vector(to_unsigned(0, instrwidth));
      end loop;
      index := 0;
      while not endfile(mem_file) loop
        -- read the next line from the file
        readline(mem_file, L);
        result := to_signed(0,instrwidth);
        for i in 1 to 8 loop
          -- read character from the line just read
          read(L, ch);
          --  convert character to a binary value from a hex value
          if '0' <= ch and ch <= '9' then
            tmpResult := result*16 + character'pos(ch) - character'pos('0') ;
            result := tmpResult(31 downto 0);
          elsif 'a' <= ch and ch <= 'f' then
            tmpResult := result*16 + character'pos(ch) - character'pos('a')+10 ;
            result := tmpResult(31 downto 0);
          else report "Format error on line " & integer'image(index)
            severity error;
          end if;
        end loop;
  
        -- set the width bit binary value in ram
        RAM(index) := std_logic_vector(result);
        index := index + 1;
      end loop;
      -- return the array of instructions loaded in RAM
      return RAM;
    end function;

    -- use the impure function to read RAM from a file and store in the FPGA's ram memory
  signal mem: ramtype := InitRamFromFile("memoryfile.dat");

begin
  process ( clk, a ) is
    variable temp: unsigned(5 downto 0);
  begin
    if clk'event and clk = '1' then
        if (memWrite = '1') then 
            if(globalStore= '1') then
            mem( to_integer(unsigned(a(5 downto 0))) ) <= sw;
            else
            for i in 0 to (gpuSize-1) loop
                mem(to_integer(unsigned(a(5 downto 0)))+i) <= sa(i);
                end loop;
            end if;
        end if;
    end if;
    rw <= mem( to_integer(unsigned(a(5 downto 0))) );
    
    for i in 0 to (gpuSize-1) loop
      temp := unsigned(a(5 downto 0))+i;
        if( temp < 64) then
          ra(i) <= mem(to_integer(temp)); 
        end if;
     end loop;
    
  end process;
end;