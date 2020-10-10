# Digital Design and Computer Architecture
## FP_2: DPU and ALU Design and Integration

# Introduction    
In this lab you will design the Data Path Unit for your processor and verify that your instructions are working correctly.  The Data Path Unit is the core hardware of your machine that executes instructions.  It takes the instruction from the instruction memory and routes the registers, immediate values, etc. to the ALU. The result of ALU computations then route to either the data memory or back to the registers.  

You will first design the final ALU for your processor and then, design the data path unit (i.e. the connections between the ALU, registers, and external memory).  This means that besides the ALU and the DPU, you will start thinking about how you want to implement the memory for your device.  For now, it makes sense to keep the memory implementation on the FPGA because interfacing to an external memory can be complex. You may wish to include a port for an external input/output devices, but your microprocessor should be able to function without this (just like the MIPS design was able to function without an external memory or I/O)  

# ALU Update or New Design
In the first part of this lab, you will design an ALU with operations to support your language. Here are some suggestions for ALU operation, however, you are not required to implement these if your processor does not require them: 

* shifters (shl, shr) 
* arithmetic (add, sub, mul, div) 
* comparison (lt, gt, lte, gte, eq) 
* bitwise logical operations (and, or, xor, inv, etc.) 

Additionally, if you are going to have more than one “core” for supporting parallelism, you will want to keep the ALU as simple as possible.  Remember that multiplication can actually be done in software with a shift/add algorithm if you need to make a super simple ALU.  

Finally, start thinking about the future. After you add the control unit (in a future lab), you will be required to add I/O capability to your processor. Will you have a dedicated I/O instruction or will you treat I/O like memory and read / write to a specific memory address? 

## What to Hand In
All of the following materials (except individual reflections) should be pushed to the __group repository__ on Whitgit. 

Individual reflections will be placed in this document pushed to your private CS401 version of this repository on Whitgit.

## Make sure to have a correct .gitignore for the VHDL code!

## Exercise 1: Update ALU or New ALU Desgin
Make sure to work as a group and that all members contribute.  Make sure all members understand all parts of the design and implementation.  

As a group, choose your ALU operations carefully: 
### ALU Design:
| Name     | Inputs |Output  |aluop|
|:--------:|:------:|:------:|:----------:|
| Add      | A, B   | A+B    |0000
| Sub      | A, B   | A-B    |1000
| Shift L  | A, B   | A<<B   |0010
| Shift R  | A, B   | A>>B   |0011
| Not      | A, B   | ~A     |0100
| And      | A, B   | A&B    |0101


* Given the language you designed in the previous project MP1, you will identify all the mathematical operations required by the ALU. Make a table of the chosen ALU operations with a description of each operation. Leave space for adding additional operations if needed. (See page 249 in your textbook for an example table) Include the table here: 

* Draw a neat, accurate, detailed hardware diagram of your ALU. I recommend doing this with an online Electronics CAD program or by using VHDL modules. Include your hardware diagram here. Again, I highly encourage you to use a schematic drawing tool or make the diagram with VHDL modules.  There are several free schematic tools available online, you can even use LTSpice if you wish, but, please create a professional looking hardware diagram. 

* Create the VHDL implementation for just the ALU. Be sure to comment your code adequately. Include your neatly formatted VHDL code for the ALU here: 
```vhdl
---------------------------------------------------------------
-- Arithmetic/Logic unit with add/sub, AND, OR, set less than
---------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity alu is 
  generic(width: integer := 32);
  port(a, b:       in  STD_LOGIC_VECTOR((width-1) downto 0);
       alucontrol: in  STD_LOGIC_VECTOR(3 downto 0);
       result:     inout STD_LOGIC_VECTOR((width-1) downto 0)
       );
end;

architecture behave of alu is
  signal b2, sum, shiftLL, shiftRL: STD_LOGIC_VECTOR((width-1) downto 0);
begin

  -- hardware inverter for 2's complement 
  b2 <= not b when alucontrol(3) = '1' else b;
  
  -- hardware adder
  sum <= a + b2 + alucontrol(3);
  
  
  -- shift left
  process(alucontrol, a, b2)
   begin
      for i in 0 to width-1 loop
          if b2 = std_logic_vector(to_unsigned(i,width)) then
              shiftLL <= std_logic_vector( unsigned(a) sll i );
          end if;
      end loop;
   end process;
   
   -- shift right
  process(alucontrol, a, b2)
   begin
      for i in 0 to width-1 loop
          if b2 = std_logic_vector(to_unsigned(i,width)) then
              shiftRL <= std_logic_vector( unsigned(a) sll i );
          end if;
      end loop;
   end process;
  
  -- determine alu operation from alucontrol bits 0 and 1
  with alucontrol(2 downto 0) select result <=
    a and b when "101",
    sum     when "000",
    shiftLL when "010",
    shiftRL when "011",
    not a   when others; --Error handling defaults to not a. Not is usually sent as 1111
end;

```

* Make a VHDL test bench to verify that the hardware for the new ALU design works. Be sure to comment your test bench code for your ALU adequately. Include your neatly formatted VHDL test bench code here: 

```vhdl
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
```


## Exercise 2: Data Path Unit Design


                                                                                 
| Function |       Inputs        | OpCode  |aluop |memWrite|globalStore|regWrite|loadFlag|immFlag|globalB|jump|brchZ|brchN|
|:--------:|:-------------------:|:-------:|:----:|:------:|:---------:|:------:|:------:|:-----:|:-:|:-:|:-:|:-:
| add      | Local, Local        | 10 0000 | 0000 |   0    |    0      |    1   | 0      |0      |0  | 0 | 0 | 0
| not      | Local               | 10 0001 | 0100 |   0    |    0      |    1   | 0      |0      |x  | 0 | 0 | 0
| and      | Local, Local        | 10 0010 | 0101 |   0    |    0      |    1   | 0      |0      |0  | 0 | 0 | 0
| sub      | Local, Local        | 10 0011 | 1000 |   0    |    0      |    1   | 0      |0      |0  | 0 | 0 | 0
| shl      | Local, Global       | 10 0100 | 0010 |   0    |    0      |    1   | 0      |0      |1  | 0 | 0 | 0
| shr      | Local, Global       | 10 0101 | 0011 |   0    |    0      |    1   | 0      |0      |1  | 0 | 0 | 0
| and      | Local, Global       | 10 0110 | 0101 |   0    |    0      |    1   | 0      |0      |1  | 0 | 0 | 0
| add      | Local, Global       | 10 0111 | 0000 |   0    |    0      |    1   | 0      |0      |1  | 0 | 0 | 0
| sub      | Local, Global       | 10 1000 | 1000 |   0    |    0      |    1   | 0      |0      |1  | 0 | 0 | 0
| not      | Global              | 10 1001 | 0100 |   0    |    1      |    1   | 0      |0      |x  | 0 | 0 | 0
| add      | Global, Global      | 10 1010 | 0000 |   0    |    1      |    1   | 0      |0      |x  | 0 | 0 | 0
| sub      | Global, Global      | 10 1011 | 1000 |   0    |    1      |    1   | 0      |0      |x  | 0 | 0 | 0
| and      | Global, Global      | 10 1100 | 0101 |   0    |    1      |    1   | 0      |0      |x  | 0 | 0 | 0
| add      | Global, Imm         | 11 0000 | 0000 |   0    |    1      |    1   | 0      |1      |x  | 0 | 0 | 0
| sub      | Global, Imm         | 11 0001 | 1000 |   0    |    1      |    1   | 0      |1      |x  | 0 | 0 | 0
| shl      | Global, Imm         | 11 0010 | 0010 |   0    |    1      |    1   | 0      |1      |x  | 0 | 0 | 0
| shr      | Global, Imm         | 11 0011 | 0011 |   0    |    1      |    1   | 0      |1      |x  | 0 | 0 | 0
| and      | Global, Imm         | 11 0100 | 0101 |   0    |    0      |    1   | 0      |1      |x  | 0 | 0 | 0
| sa       | Local, Imm Addr     | 01 0000 | xxxx |   1    |    0      |    0   | 0      |1      |x  | 0 | 0 | 0
| la       | Imm Addr            | 01 0001 | xxxx |   0    |    0      |    1   | 1      |1      |x  | 0 | 0 | 0
| sw       | Global, Imm Addr    | 01 0010 | xxxx |   1    |    1      |    0   | 0      |1      |x  | 0 | 0 | 0
| sa       | Local, Global Addr  | 00 0000 | xxxx |   1    |    0      |    0   | 0      |0      |x  | 0 | 0 | 0
| la       | Global Addr         | 00 0001 | xxxx |   0    |    0      |    1   | 1      |0      |x  | 0 | 0 | 0
| sw       | Global, Global Addr | 00 0010 | xxxx |   1    |    1      |    0   | 0      |0      |x  | 0 | 0 | 0
| lw       | Global Addr         | 00 0011 | xxxx |   0    |    1      |    1   | 1      |0      |x  | 0 | 0 | 0
| lw       | Imm Addr            | 01 0011 | xxxx |   0    |    1      |    1   | 1      |1      |x  | 0 | 0 | 0
| bz       | Imm Addr            | 01 0100 | xxxx |   0    |    0      |    0   | x      |x      |x  | 0 | 1 | 0 
| bn       | Imm Addr            | 01 0101 | xxxx |   0    |    0      |    0   | x      |x      |x  | 0 | 0 | 1
| j        | Immediate address   | 01 0110 | xxxx |   1    |    0      |    0   | x      |x      |x  | 1 | 0 | 0

    


Make sure to work as a group and that all members contribute.  Make sure all members understand all parts of the design and implementation.  

Review the slides and the examples given in the textbook (pages 377-381) for the Data Path Unit design.  Now that you know your target processor application, and you know your ALU’s capabilities, lay out data communication pathways required for your instructions to execute.  Do NOT include the control unit, however, for each component in the DPU you may show the input control signals (to be connected up later). 

### Hints:
Have your Assembly Language design easily accessible while you work on DPU/ALU design.  You will want to work on this as a group.

Start with the __most complex instruction__ and consider the following questions (this is not an exhaustive list of questions you should ask yourselves. This is to get you started...)

* What memory is required (i.e instruction, data, combined instruction/data) ? 
* How does memory connect with/route to your registers? 
* How do registers connect with/route to your ALU? 
* What multiplexors are required?
  
Following a process similar to what we followed from the book when it layed out the DPU/ALU for the MIPS lw/sw instrucitons, lay out the basic architecture of your machine. 

You should use either an online electronics CAD program or LT Spice, or VHDL to lay out your modules and the connections between them. You can look back to the lecture notes on MIPS where we laid out the MIPS architecture for lw in order to layout your design.

In your group, discuss the following questions before you start on the DPU design: 

* Are you planning to create a Harvard architecture or a Von Neumann architecture? 
* Are you making a single cycle or multi-cycle processor? Why? 
* How will your program counter update? Will it reuse the ALU (hence you need a multi-cycle processor) or will you have a separate adder to update the program counter? 
* What about registers? What is your register naming scheme, and how many registers will you have? 
* Will your processor need to compute branch addresses or offset addresses? If so how will that be handled? 
* You will be required to add I/O your processor in the future, do you want memory mapped I/O (treat it like a memory address) or do you want a specific instructions that does I/O? 

### Data Path Unit Design  

Draw a neat, accurate, detailed hardware diagram of your Data Path Unit. Include your hardware diagram here. I encourage you to use a schematic drawing tool.  There are several free schematic tools available online, you can even use LTSpice if you wish, but, please create a professional looking hardware diagram. 

### Data Path Unit Design Schematic

Include your schematic here:

![FP2.png](./FP2.png)


## Exercise 3: Design Walkthrough an FP_2 Mini Presentations
On the due date for this design, groups will take 5-6 minutes (max) and present their assembly language designs to the class. You will be graded on whether you present the following items.  Do not use more than 4 or 5 slides to summarize your algorithm.  

* Minute 1: Does your new ALU design differ from previous designs (if so why, if not, why not)? Show a hardware diagram of your ALU. 
* Minute 2-3: Show a hardware diagram of your DPU and talk about your design. Will there be enough resources on the FPGA to do what you want to do.  
* Minutes 4-5: Summary. What went well? What not so well?  Did you do anything above and beyond the requirements (not required)?  What are you most proud of in your design?  

## Exercise 4: DPU Reflection (private individual reflections)
Place your individual reflection in this document in your individual repository on Whitgit. 

* How did your group work together?  
* Did you feel like your ideas were listened to by the other group members?
* Did group members treat each other with respect?
* What challenges did you face? 
* Did you contribute at the level you wanted to? 
* What steps will you take for the last two projects to make sure things go smoothly in your group?  


 | CATEGORY | Poor or missing attempt | Beginning  | Satisfactory | Excellent  |
|:--------:|:--------:|:--------:|:--------:|:--------:|
| Exercise 1: New ALU Design |Missing or extremely poor quality.   |  No justification for the ALU design chosen, and simply copied the MIPS ALU without modification. Weak comments in the VHDL code. | Adequate justification of ALU design chosen.  Rudimentary testbench verifies some of the operations in the ALU. ALU hardware diagram adequate but could be better.   | Excellent ALU design. Excellent justifications given for both the design and the number of ALU operations implemented/ Neat professional ALU hardware diagram and neat tables. |
|Exercise 2: DPU Design  | Missing or extremely poor quality.  | Little thought given to questions about the DPU design. Messy hardware diagram. Missing control signals and signal names.  | Adequate hardware design. Some signals adequately documented.   | Excellent DPU design. Neat professional diagram (not hand drawn) Clear effort to consider all planned instruction data paths. Neatly documented control signals ready for control unit design in the next project. |
|Exercise 3: Design Walkthough  | Missing or extremely poor quality.  | Addressed some of the required items.   | Adequate address of the required items. Showed and discussed the hardware DPU design.  | Excellent presentation of both the ALU and the DPU. Clear consideration of tradeoffs in design. . |
|Exercise 4: Self Reflection (individual)  | Missing or extremely poor quality.  | Addressed some of the contributions made to the project. Described some of the group dynamics, without thought of how to make it better.  |Adequate discussion of the group dynamics. Some thought given to how the group can work better in the future. Did one person do all the work? Did you all collaborate?    |Excellent discussion of group dynamics with clear suggestions for how your group will do better on the final two projects. How did your group manage it’s time? What can you do better?  |