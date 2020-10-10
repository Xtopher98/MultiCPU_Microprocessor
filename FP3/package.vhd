library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package gpu is
    constant bitwidth : integer := 32;  --bits wide
    constant width : integer:=32; --for finding misuses
    constant gpuSize    : integer := 16; --numCores
    constant instrWidth : integer := 32;
    type ARRAYBUS is array ((gpuSize-1) downto 0) of STD_LOGIC_VECTOR((bitwidth-1) downto 0);
end package gpu;