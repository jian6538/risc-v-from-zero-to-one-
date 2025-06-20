# risc-v-from-zero-to-one-
this is my journey to complete 
32-bit pipelined RISC-V core (RV32I instruction set)

5-stage pipeline (Fetch, Decode, Execute, Memory, Writeback)

Basic memory-mapped I/O

UART/LED peripheral or simple GPIO

it include resource learning material as well as step by step guide to the implementation. 

so the basic architeture of riscv and common computer is a program counter , instruction memory , instruction decoder , register file , Arithmetic Logic Unit , data memory and control unit 
Fetch: The Program Counter provides an address to the Instruction Memory.
Decode: The fetched instruction is sent to the Instruction Decoder, which also reads source operands from the Register File.
Execute: The ALU performs the calculation specified by the instruction on the data read from the register file.
Memory: The Data Memory is accessed for load or store operations, with the address often calculated by the ALU.
Writeback: The result of the execution or memory load is written back into the Register File.

Building arithmatic logic unit!!
the first and most important to step to start is by building an ALU which is very basic component in the cpu. By trying to write verilog or system verilog code on ALU, basic fundamental of digital circuit can be learned and implement. The code can be found in the folder above trying to build it yourself as well to learn more about the ALU 

next, we will design a program counter that hold the next instruction to be processed, it is very simple and easing as well as important in computer architeture, it updates every clock cycle and increase by 4.

later on , we need to design a instruction memory that get the address from the program counter and then extract the instruction from the address to process later on 

next we will have a module for register file which store data for cpu to process total of 32 register with 32bit, for common architeture the register file is 2 read port and 1 write port

later on , we need to create a module for the memory , which store all the address and data in a computer , its work is to load which is load a word from memory to the register , and store which is store the information from the register to the memory.

later on , we need to build a control module which is like a brain of computer to control all the signal and how does it flow.


the datapath is a diagram of how each of the module flow from one module to another module. 

now , we successfully design a single cycle risc v , next we will make our risv more efficient and faster by introducing pipelining 


