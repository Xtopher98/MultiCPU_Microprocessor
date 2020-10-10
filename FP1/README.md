# Digital Design and Computer Architecture
## fp_1: Microprocessor Language Design  
    
## Introduction
For the first half of MP1 you will start by comparing two real world processors. You will compare their intended purpose, their instruction sets, their architecture, performance etc. This step will help you understand other possibilities for instruction sets and instruction set formats. It will also help you understand the architecture behind real world processors. This first part may be more challenging if you pick an obscure processor or a proprietary processor that does not have much information available about it online. 

Fill out the answers to your work directly in this Document and submit to Whitgit.

For the second half of FP_1 
1.	You will decide on what type of processor you want to target (e.g. general purpose or special purpose dedicated processor: e.g. graphics, a.i., dsp, etc.) 
2.	You will design a new, original instruction set (i.e. assembly language) for this type of processor that can run non-trivial programs.  
3.	You will then design the machine code format for your instruction set.  
4.	You will write an assembler program that uses your new, original, assembly language (for testing purposes).
5.	You will create an assembler to convert text based assembly language into a hex code machine format.
6.	You will “assemble” (i.e. convert) each of these programs into your machine code.  

Preview of future FP labs: This lab sets the stage for the next project where you design the ALU and DPU for your original processor.  Your group must create an original processor / control unit / data path unit and NOT simply copy an existing processor design that you find out on the Internet.

# Processors of the World Comparison

Compare the hardware architectures and assembly/machine languages for any two different processors (groups of two) and three different processors (groups of 3) of your choice. Decide on the specific application area you want your processor to focus on. Are you interested in general purpose? audio? graphics? encryption? security?  We suggest that you pick at least one processer that you are interested in learning more about. Below are some suggestions that have information for them online. Each person in the group is responsible for ONE different processor and will be graded on that individually.

1.	Old Style Intel 8080 or 8085 Architecture
    * http://en.wikipedia.org/wiki/Intel_8080 
    * http://www.intel-vintage.info/intelotherresources.htm#906748189 

2.	Old Style Motorola 6502 Architecture
    * http://www.visual6502.org/welcome.html
    * http://en.wikipedia.org/wiki/MOS_Technology_6502 
    * http://opencores.org/project,t65

3.	Modern General Purpose ARM Architecture
    * http://en.wikipedia.org/wiki/ARM_architecture
    * https://www.scss.tcd.ie/~waldroj/3d1/arm_arm.pdf 

4.	Modern Application Specific NVIDIA Architecture (Graphics Processor)

5.	Modern AMD Architecture (e.g. Ryzen)

6.	Other processor of your own choice (other than MIPS) that you can find information for.


## Exercise 1: Comparing and Contrasting Processor Designs

1. What is the application area of the  processor you chose? 
   
2. What "registers" does your chosen processor use? Make a table similar to Table 6.1 MIPS Register Set on page 300 of your book
   
3. Find the instruction operation information for four different types of instructions. If possible, find the machine code format, this may not be possible for the processor you chose, but do your best to find the lowest level instruction information possible for your processor.

4. High level block diagram of your processor. Compare and contrast the design of your processor with another processor that someone in your group chose.  Here are questions that can help guide you in the comparison process. You may not be able to answer all the questions, but do your best:

    a. What does the data path look like for each processor? Find a high level architecture diagram that shows the data path for each processor. Insert both diagrams here:

    b.	What types of memory (register, cache, etc.) does each processor contain or access? 

    c.	How is/are the ALU(s) connected to the registers (refer to the diagram in part a)? 

    d.	How are instructions fetched and executed? Is there an instruction cache? 

    e.	Does the processor pipeline instructions? 

    f.	What is the clock speed of the processor? 

## Exercise 2: Processor Language Design

   Design the programmer’s view of the architecture for your processor (as a group).  Just like in part 1, you will make two tables. The first table will be the registers and the second table the instructions for your processor. 

   Our goal: Make a 16 core GPU with a handful of simple instructions.
   
   >>### TABLE 2A:  
   >>A diagram of the registers (and their purposes) for your custom processor
   
| Name     | Number   | Use  |Location (Global vs Local)|
|:--------:|:--------:|:----:|:------------------------:|
|:0        |0         |Stores zero. Read only.|   Global|
|:? |31|checked against on branch functions|Global
|[A]-[G]   |1-8       |Stores arrays of 16 32bit vals| Local|
|:a-:u |9-30|Stores standard 32bit values| Global|

Global register set has 24 registers.
Each local register set has 8 registers.
Each alu has access to its local registers and the global registers.

   >>### TABLE 2B:
   >>A list of the instructions that you are going to build into the processor. 

| Name     | Inputs         |Output Target|Function |
|:--------:|:-----------------:|:------:|:-------:|
| add      | Global, Global    | Global | Addition
| add      | Local, Global     | Local  | Addition
| add      | Local, Local      | Local  | Addition
| add      | Global, Imm       | Global | Addition
| sub      | Global, Global    | Global | Subtraction
| sub      | Local, Global     | Local  | Subtraction
| sub      | Local, Local      | Local  | Subtraction
| sub      | Global, Imm       | Global | Subtraction
| shl      | Global, Imm       | Global | Shift Left
| shl      | Local, Global     | Local  | Shift Left
| shr      | Global, Imm       | Global | Shift Right
| shr      | Local, Global     | Local  | Shift Right
| not      | Global            | Global | logical not
| not      | Local             | Local  | logical not
| and      | Global, Global    | Global | Logical and
| and      | Global, Imm       | Global | Logical and
| and      | Local, Local      | Global | Logical and
| j        | Imm Addr          | ---    | Jump to address
| bz       | Imm Addr          | ---    | jump if :? == 0
| bn       | Imm Addr          | ---    | jump if :? msb == 1  
| lw       | Global Addr       | Global | Load Global
| lw       | Imm Addr          | Global | Load Global
| sw       | Global Addr       | Global | Store Global
| sw       | Imm Addr          | Global | Store Global
| la       | Global Addr       | Local  | Load Local
| la       | Imm Addr          | Local  | Load Local
| sa       | Global Addr       | Local  | Store Local
| sa       | Imm Addr          | Local  | Store Local

#### Tips
* Don’t start with too many instructions!  
* Have some stretch instructions as well as basic instructions.  
* Each person in the group (after group consultation) must be personally responsible for the hardware of at least one instruction. 
* Your processor will need enough instructions to do useful work. You must have enough instructions to be able to run a useful program.


## Exercise 3: Assembler for your Processor
Create an assembler for your processor. Put your assembler code in a sub-folder of your group project. 

### Simpler Assembler
For example you could create a simple program that reads your assembly language program word by word and then converts each line to machine code.  Here is some possible pseudo code for a simple assembler: 

```
Read in the variable definitions from the top of the program. 

For each variable in the definitions list: 

    Determine the size of memory required 

    Insert the variable into a dictionary that
    stores the assigned memory address of the variable. 

    Compute the memory location for the next variable. 

For each line of assembly: 

    NextHexCode = “” 

    Strip comments from the line of code read 

    If line of code has a label:  

        Store memory location of the label in a dictionary 

        Determine the assembly keyword on the line of code 

        Based on assembler keyword update NextHexCode contents

    If line of code has arguments  

        Based on argument types (register, variable, immediate) 
        and instruction type update NextHexCode 

    Write NextHexCode to the output machine code file. 

End For
```
### Another Option

* Define a grammar for your assembly language and build a recursive descent parser (https://en.wikipedia.org/wiki/Recursive_descent_parser ) 
 
* Use the utilities Lexx and Yacc (you will have to learn these on your own) 

## Exercise 4: Assembly Language Code
Write an assembly language program using the language that you designed.  Use your assembler from exercise 3 to compile the assembly language into hex based machine code. 

Include your assembly language code program here (make sure your program includes comments) 


### Make sure to push your changes to Whitgit!

## Rubric



| CATEGORY | Poor or missing attempt | Beginning  | Satisfactory | Excellent  |
|:--------:|:--------:|:--------:|:--------:|:--------:|
| Exercise 1: Comparing Processors  | Missing or extremely poor quality. | Low quality comparison of processors.  Questions answered poorly and instructions not followed. | Adequate comparison of both processors architecture, machine code, and assembly language | Excellent comparison of both processors architecture, machine code, and assembly language instructions and format. |
| Exercise 2: Assembly Language Design | Missing or extremely poor quality. | Beginning design. Done quickly without much thought.. | Satisfactory design. | Excellent design. Good opcode choices and architecture. |
| Exercise 3: Assembler | Missing or extremely poor quality. | Hard coded assembler with few comments. No variables or labels (values are hard coded in the instructions)  | Adequate assembler with one of either variables or labels. Adequately commented. | Well commented, comprehensive assembler program that supports labels and variables. And a useful program. | 
| Exercise 4: Assembly Language and Machine Code | Missing or extremely poor quality. | Hex listing without assembly language. |  Adequate assembly language program and associated working machine code. | Excellent assembler with comments, excellent assembly language program  |

## What to Hand In:  

* All the answers to the questions should be formatted neatly in a markdown file and submitted to the whitgit group project folder. 
* Be sure to check the evaluation rubric given here. 

|  Name    | Inputs              |Output Target| Function            | Binary Value                            |
|:--------:|:-------------------:|:-----------:|:-------------------:|:----------------------------------------|
| add      | Global, Global      | Global      | Addition            | 0000 00aa aaab bbbb cccc c000 0000 0000 |
| add      | Local, Global       | Local       | Addition            | 0000 01aa aaab bbbb cccc c000 0000 0000 |
| add      | Local, Local        | Local       | Addition            | 0000 10aa aaab bbbb cccc c000 0000 0000 |
| add      | Global, Imm         | Global      | Addition            | 0000 11aa aaac cccc iiii iiii iiii iiii |
| sub      | Global, Global      | Global      | Subtraction         | 0001 00aa aaab bbbb cccc c000 0000 0000 |
| sub      | Local, Global       | Local       | Subtraction         | 0001 01aa aaab bbbb cccc c000 0000 0000 |
| sub      | Local, Local        | Local       | Subtraction         | 0001 10aa aaab bbbb cccc c000 0000 0000 |
| sub      | Global, Imm         | Global      | Subtraction         | 0001 11aa aaac cccc iiii iiii iiii iiii |
| shl      | Global, Imm         | Global      | Shift Left          | 0010 00aa aaac cccc iiii iiii iiii iiii |
| shl      | Local, Global       | Local       | Shift Left          | 0010 01aa aaab bbbb cccc c000 0000 0000 |
| shr      | Global, Imm         | Global      | Shift Right         | 0010 10aa aaac cccc iiii iiii iiii iiii |
| shr      | Local, Global       | Local       | Shift Right         | 0010 11aa aaab bbbb cccc c000 0000 0000 |
| not      | Global              | Global      | logical not         | 0011 00aa aaab bbbb cccc c000 0000 0000 |
| not      | Local               | Local       | logical not         | 0011 01aa aaab bbbb cccc c000 0000 0000 |
| and      | Global, Global      | Global      | Logical and         | 0011 10aa aaab bbbb cccc c000 0000 0000 |
| and      | Global, Imm         | Global      | Logical and         | 0011 11aa aaac cccc iiii iiii iiii iiii |
| and      | Local, Local        | Local       | Logical and         | 0100 00aa aaab bbbb cccc c000 0000 0000 |
| j        | Immediate address   |             | jump to address     | 0100 01ii iiii iiii iiii iiii iiii iiii |
| bz       | Imm Addr            |             | jump if :? == 0     | 0100 10ii iiii iiii iiii iiii iiii iiii |
| bn       | Imm Addr            |             | jump if :? msb == 1 | 0100 11ii iiii iiii iiii iiii iiii iiii |
| lw       | Global Addr         | Global      | Load Global         | 0101 00aa aaab bbbb cccc c000 0000 0000 |
| lw       | Imm Addr            | Global      | Load Global         | 0101 01aa aaac cccc iiii iiii iiii iiii |
| sw       | Global, Global Addr |             | Store Global        | 0101 10aa aaab bbbb cccc c000 0000 0000 |
| sw       | Global, Imm Addr    |             | Store Global        | 0101 11aa aaac cccc iiii iiii iiii iiii |
| la       | Global Addr         | Local       | Load Local          | 0110 00aa aaab bbbb cccc c000 0000 0000 |
| la       | Imm Addr            | Local       | Load Local          | 0110 01aa aaac cccc iiii iiii iiii iiii |
| sa       | Local, Global Addr  |             | Store Local         | 0110 10aa aaab bbbb cccc c000 0000 0000 |
| sa       | Local, Imm Addr     |             | Store Local         | 0110 11aa aaac cccc iiii iiii iiii iiii |

R-type = op(6) + a(5) + b(5) + c(5) + 0...
I-type = op(6) + a(5) + b(5) + imm...
J-type = op(6) + imm...