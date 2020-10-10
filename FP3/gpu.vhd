library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

use work.gpu.ALL;

entity custom_gpu is 
  port(
      clk: in STD_LOGIC
       );
end;

architecture behave of custom_gpu is
component globalComputation is
  port(RD1, RD2:    in  STD_LOGIC_VECTOR((bitwidth-1) downto 0);
        instr:      in STD_LOGIC_VECTOR((instrwidth-1) downto 0);
        addr:       out STD_LOGIC_VECTOR((bitwidth-1) downto 0);
        res:        out STD_LOGIC_VECTOR((bitwidth-1) downto 0);
        alucontrol: in STD_LOGIC_VECTOR(3 downto 0);
        loadFlag:   in STD_LOGIC;
        immFlag:    in STD_LOGIC;
        RW:         in STD_LOGIC_VECTOR((bitwidth-1) downto 0)
       );
end component;

component instrGetter is 
 
  port(instr:    out  STD_LOGIC_VECTOR((instrwidth-1) downto 0);
        qmarkVal:    in   STD_LOGIC_VECTOR((bitwidth-1) downto 0);
        clk, jump, brchZ, brchN: in STD_LOGIC
       );
end component;
  
component globalRegister is 
  port(clk:           in  STD_LOGIC;
       regWrite, globalStore:           in  STD_LOGIC;

	   -- determine number of address bits based on bitwidth
       ra1, ra2, wa3: in  STD_LOGIC_VECTOR( 4 downto 0 );
       wd3:           in  STD_LOGIC_VECTOR((bitwidth-1) downto 0);
       rd1, rd2, constOut:      out STD_LOGIC_VECTOR((bitwidth-1) downto 0));
end component;

component maindec is -- main control decoder
  port(op:                   in  STD_LOGIC_VECTOR(5 downto 0);
       regWrite, memWrite:   out STD_LOGIC;
       loadFlag, immFlag:    out STD_LOGIC; 
       globalStore, globalB: out STD_LOGIC;
       brchZ, brchN:         out STD_LOGIC;
       jump:                 out STD_LOGIC;
       aluop:                out STD_LOGIC_VECTOR(3 downto 0));
end component;

component localComputation is 
  port(
      globalRD2, memRA: in STD_LOGIC_VECTOR((bitwidth-1) downto 0);
      localRA1, localRA2, localWA3: in STD_LOGIC_VECTOR(4 downto 0);
      localRD1:                out STD_LOGIC_VECTOR((bitwidth-1) downto 0);
      alucontrol:               in STD_LOGIC_VECTOR(3 downto 0);
      clk, globalB, regWrite, globalStore, loadFlag: in STD_LOGIC
       );
end component;

component dmem is -- data memory
  port(clk, memWrite, globalStore:  in STD_LOGIC;
       a, sw:    in STD_LOGIC_VECTOR((bitwidth-1) downto 0);
       sa:       in ARRAYBUS;
       rw:       out STD_LOGIC_VECTOR((bitwidth-1) downto 0);
       ra:       out ARRAYBUS);
end component;

signal regWrite, memWrite, loadFlag, immFlag, globalStore, globalB , brchZ, brchN, jump: STD_LOGIC;
signal aluop: STD_LOGIC_VECTOR(3 downto 0);
signal instr: STD_LOGIC_VECTOR((instrwidth-1) downto 0);
signal qmarkVal, globalRD2, memA, globalRD1, memRW, res: STD_LOGIC_VECTOR((bitwidth-1) downto 0);
signal memRA, memSA:  ARRAYBUS;
signal WA3: STD_LOGIC_VECTOR(4 downto 0);


begin
    
calcWA3: process(instr, immFlag) begin
    if(immFlag = '1') then
        WA3 <= instr(20 downto 16);
    else
        WA3 <= instr(15 downto 11);
    end if;
end process;
    
    
CU: maindec port map(
    op => instr(31 downto 26),
    regWrite=>regWrite, 
    memWrite=>memWrite,
    loadFlag=>loadFlag, 
    immFlag=>immFlag,
    globalStore=>globalStore, 
    globalB =>globalB,
    brchZ=>brchZ, 
    brchN=>brchN,
    jump=>jump,
    aluop=>aluop
);
  
instrGet: instrGetter port map (
    instr=>instr,
    qmarkVal=>qmarkVal,
    clk=>clk, jump=>jump, brchZ=>brchZ, brchN=>brchN
);

genLocalComp: for i in 0 to (gpuSize-1) generate
localComp: localComputation port map (
    globalRD2=>globalRD2,
    memRA=>memRA(i),
    localRA1=>instr(25 downto 21),
    localRA2=>instr(20 downto 16),
    localWA3=>WA3,
    localRD1=>memSA(i),
    alucontrol=>aluop,
    clk=>clk,
    globalB=>globalB,
    regWrite=>regWrite,
    globalStore=>globalStore,
    loadFlag=>loadFlag
    );
end generate genLocalComp;

datamem: dmem port map(
    clk=>clk,
    memWrite=>memWrite, 
    globalStore=>globalStore,
    a=>memA,
    sw=>globalRD1,
    sa=>memSA,
    rw=>memRW,
    ra=>memRA
);

globalComp: globalComputation port map (
    RD1=>globalRD1,
    RD2=>globalRD2,
    instr=>instr,
    addr=>memA,
    res=>res,
    alucontrol=>aluop,
    loadFlag=>loadFlag,
    immFlag=>immFlag,
    RW=>memRW
);


globalReg: globalRegister port map(
    clk=>clk,
    regWrite=>regWrite,
    globalStore=>globalStore,
    ra1=>instr(25 downto 21),
    ra2=>instr(20 downto 16),
    wa3=>WA3,
    wd3=>res,
    rd1=>globalRD1,
    rd2=>globalRD2,
    constOut=>qmarkVal  
);


end;
