# Digital Design and Computer Architecture
## FP_3: Control Unit Design

# Introduction    
In this lab you will design the Control Unit for your processor and verify that your instructions are working correctly.  The control unit sets the signals which tell the components in the DPU what to do.  A control unit implements what is known as the "Decode" and "Execute" stages of an instruction’s life-cycle.  

Single-cycle and multiple-cycle machines will have different types of control units. 

* In a single-cycle machine, the control unit is essentially just fancy "look-up ROM" that acts somewhat like a python dictionary or a C++ map.  The instruction op-code functions like the input "key" and the control unit then returns the "value" which is placed on the control bus. The control bus consists of the set of wires that carry control signals to the components in the Data Path Unit (DPU). Each instruction will set these control signals to appropriate values that will cause the components in the DPU to behave appropriate to that instruction.

* In a multi-cycle machine, the control unit is implemented using a finite state machine.  In this case, each instruction op-code is the input to the machine which triggers a series of control signal states. All of the instruction share the "fetch" phase of the FSM, but, after decoding, each individual instruction will step through a specific set of states required for the execute phase of the instruction.


# Exercise 1: Control Unit Design
Have your Assembly Language, ALU, and DPU designs easily accessible while you work on this design. 

1.	Make a table here to list all the op-codes for the instructions supported by your design:

| Function |       Inputs        | OpCode  |
|:--------:|:-------------------:|:-------:|
| add      | Local, Local        | 10 0000 |
| not      | Local               | 10 0001 |
| and      | Local, Local        | 10 0010 | 
| sub      | Local, Local        | 10 0011 | 
| shl      | Local, Global       | 10 0100 | 
| shr      | Local, Global       | 10 0101 | 
| and      | Local, Global       | 10 0110 | 
| add      | Local, Global       | 10 0111 |
| sub      | Local, Global       | 10 1000 | 
| not      | Global              | 10 1001 | 
| add      | Global, Global      | 10 1010 |
| sub      | Global, Global      | 10 1011 |
| and      | Global, Global      | 10 1100 |
| add      | Global, Imm         | 11 0000 | 
| sub      | Global, Imm         | 11 0001 | 
| shl      | Global, Imm         | 11 0010 |
| shr      | Global, Imm         | 11 0011 | 
| and      | Global, Imm         | 11 0100 |
| sa       | Local, Imm Addr     | 01 0000 |
| la       | Imm Addr            | 01 0001 |
| sw       | Global, Imm Addr    | 01 0010 | 
| sa       | Local, Global Addr  | 00 0000 |
| la       | Global Addr         | 00 0001 |
| sw       | Global, Global Addr | 00 0010 |
| lw       | Global Addr         | 00 0011 |
| lw       | Imm Addr            | 01 0011 | 
| bz       | Imm Addr            | 01 0100 | 
| bn       | Imm Addr            | 01 0101 | 
| j        | Immediate address   | 01 0110 |

2. Control signals lists
* aluop
* memWrite
* globalStore
* regWrite
* loadFlag
* immFlag
* globalB
* jump
* brchZ
* brchN
3.	Control Unit (CU) Design:

| Function |       Inputs        | OpCode  |aluop |memWrite|globalStore|regWrite|loadFlag|immFlag|globalB|jump|brchZ|brchN|
|:--------:|:-------------------:|:-------:|:----:|:------:|:---------:|:------:|:------:|:-----:|:-----:|:--:|:---:|:---:|
| add      | Local, Local        | 10 0000 | 0000 |   0    |    0      |    1   |    0   |    0  |   0   | 0  |  0  |  0  |
| not      | Local               | 10 0001 | 0100 |   0    |    0      |    1   |    0   |    0  |   x   | 0  |  0  |  0  |
| and      | Local, Local        | 10 0010 | 0101 |   0    |    0      |    1   |    0   |    0  |   0   | 0  |  0  |  0  |
| sub      | Local, Local        | 10 0011 | 1000 |   0    |    0      |    1   |    0   |    0  |   0   | 0  |  0  |  0  |
| shl      | Local, Global       | 10 0100 | 0010 |   0    |    0      |    1   |    0   |    0  |   1   | 0  |  0  |  0  |
| shr      | Local, Global       | 10 0101 | 0011 |   0    |    0      |    1   |    0   |    0  |   1   | 0  |  0  |  0  |
| and      | Local, Global       | 10 0110 | 0101 |   0    |    0      |    1   |    0   |    0  |   1   | 0  |  0  |  0  |
| add      | Local, Global       | 10 0111 | 0000 |   0    |    0      |    1   |    0   |    0  |   1   | 0  |  0  |  0  |
| sub      | Local, Global       | 10 1000 | 1000 |   0    |    0      |    1   |    0   |    0  |   1   | 0  |  0  |  0  |
| not      | Global              | 10 1001 | 0100 |   0    |    1      |    1   |    0   |    0  |   x   | 0  |  0  |  0  |
| add      | Global, Global      | 10 1010 | 0000 |   0    |    1      |    1   |    0   |    0  |   x   | 0  |  0  |  0  |
| sub      | Global, Global      | 10 1011 | 1000 |   0    |    1      |    1   |    0   |    0  |   x   | 0  |  0  |  0  |
| and      | Global, Global      | 10 1100 | 0101 |   0    |    1      |    1   |    0   |    0  |   x   | 0  |  0  |  0  |
| add      | Global, Imm         | 11 0000 | 0000 |   0    |    1      |    1   |    0   |    1  |   x   | 0  |  0  |  0  |
| sub      | Global, Imm         | 11 0001 | 1000 |   0    |    1      |    1   |    0   |    1  |   x   | 0  |  0  |  0  |
| shl      | Global, Imm         | 11 0010 | 0010 |   0    |    1      |    1   |    0   |    1  |   x   | 0  |  0  |  0  |
| shr      | Global, Imm         | 11 0011 | 0011 |   0    |    1      |    1   |    0   |    1  |   x   | 0  |  0  |  0  |
| and      | Global, Imm         | 11 0100 | 0101 |   0    |    0      |    1   |    0   |    1  |   x   | 0  |  0  |  0  |
| sa       | Local, Imm Addr     | 01 0000 | xxxx |   1    |    0      |    0   |    0   |    1  |   x   | 0  |  0  |  0  |
| la       | Imm Addr            | 01 0001 | xxxx |   0    |    0      |    1   |    1   |    1  |   x   | 0  |  0  |  0  |
| sw       | Global, Imm Addr    | 01 0010 | xxxx |   1    |    1      |    0   |    0   |    1  |   x   | 0  |  0  |  0  |
| sa       | Local, Global Addr  | 00 0000 | xxxx |   1    |    0      |    0   |    0   |    0  |   x   | 0  |  0  |  0  |
| la       | Global Addr         | 00 0001 | xxxx |   0    |    0      |    1   |    1   |    0  |   x   | 0  |  0  |  0  |
| sw       | Global, Global Addr | 00 0010 | xxxx |   1    |    1      |    0   |    0   |    0  |   x   | 0  |  0  |  0  |
| lw       | Global Addr         | 00 0011 | xxxx |   0    |    1      |    1   |    1   |    0  |   x   | 0  |  0  |  0  |
| lw       | Imm Addr            | 01 0011 | xxxx |   0    |    1      |    1   |    1   |    1  |   x   | 0  |  0  |  0  |
| bz       | Imm Addr            | 01 0100 | xxxx |   0    |    0      |    0   |    x   |    x  |   x   | 0  |  1  |  0  | 
| bn       | Imm Addr            | 01 0101 | xxxx |   0    |    0      |    0   |    x   |    x  |   x   | 0  |  0  |  1  |
| j        | Immediate address   | 01 0110 | xxxx |   0    |    0      |    0   |    x   |    x  |   x   | 1  |  0  |  0  |


a.	SINGLE CYCLE CU DESIGN:  Create decoder tables for your CPU (e.g. See pages 383-387 of your textbook for examples of decoder tables.)

## Exercise 2: Integrated VHDL for the Control Unit and the Data Path Unit

Using the tables and finite state machine diagrams from the previous steps, design the VHDL for the control unit of your processor.  

### SINGLE CYCLE CONTROL UNIT DESIGN:  
For an example, look at the MIPS single cycle control unit. The VHDL is on pages 431, 432 of the textbook. However there are small differences so you will also want to look at your MIPS3 processor’s control unit code.

## Exercise 3:  VHDL Testbench With Simple Adhoc Program Running Correctly
Design a simple ad-hoc test program for your processor. This should use every instruction you intend for it to execute.  Remember, you will need to put the hex code into a data file that can be read by your VHDL code. 

* IMPORTANT: Every time you change your hexcode file contents, you must verify by using the simulator in Vivado that your updated hexcode program loaded into the simulated microprocessor's instruction memory correctly. Refresh your memory on how to use the debugger in the test-bench to verify the contents of the program have loaded correctly into your instruction memory.

* Make a simple ad-hoc program that executes every instruction at least one time, and verifies that each instruction is working as intended. 

## Exercise 4: Mini Presentation FP3
1.	Show the class your control unit design. If you have a multi-cycle, you must show your bubble diagram state machine diagram. For a single-cycle machine you must show your decoder tables.
2.	Demo your ad-hoc program running (either in simulation or on the FPGA)
3.	What hardware bugs did you encounter in testing? How did you find them? How did you squash them?
4.	Did you go above and beyond the assignment requirements in any way?


## What to hand in
* List of instructions and op-codes.
* Control signals lists.
* SINGLE-CYCLE: Neatly drawn decoder tables.
* MULTI-CYCLE: Neatly drawn FSM bubble diagram and/or microcode table/spreadsheet for the multi-cycle design. 
* jpg/png files that demonstrate your microprocessor is running the ad-hoc program correctly.
  
## Make sure to have a correct .gitignore for the VHDL code!


| CATEGORY |  Beginning 0%-79% | Satisfactory 80%-89% | Excellent 90%-100% |
|:--------:|:-----------:|:------------:|:----------:|
| 25 pts. Control Unit Design | Rudimentary decoder tables. | Basic decoder tables and/or basic finite state machine bubble diagram for the control unit. | Neat, well commented, complete set of decoder tables (single cycle)  or neat, well commented complete finite state machine bubble diagram and tables  (multi-cycle). |
| 25 pts. Control Unit VHDL | VHDL code for the control unit. Few comments.	Partially working VHDL code for the control unit. Satisfactory comments. | Working VHDL code for the control unit. | Excellent comments, code formatted neatly, etc. |
| 25 pts. Control Unit Test  | Simulation test bench created but not documented well or does not work properly |	Single ad-hoc test code that tests every possible instruction. |	Both an ad-hoc program AND a more advanced program that runs correctly. |
| 25 pts. Mini Presentation | Little to no content, poor presentation. | Several of the required elements for Exercise 4 | All the required elements of Exercise 4 and a good presentation.


# FP2 TABLES ( delete later)

## ALU Design:
| Name     | Inputs |Output  |aluop|
|:--------:|:------:|:------:|:----------:|
| Add      | A, B   | A+B    |0000
| Sub      | A, B   | A-B    |1000
| Shift L  | A, B   | A<<B   |0010
| Shift R  | A, B   | A>>B   |0011
| Not      | A, B   | ~A     |0100
| And      | A, B   | A&B    |0101


 ## DPU design       
                                 
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
| j        | Immediate address   | 01 0110 | xxxx |   1    |    0      | 0      | x      |x      |x  | 1 | 0 | 0
