# risc-v-from-zero-to-one-
this is my journey to complete 
32-bit pipelined RISC-V core (RV32I instruction set)

5-stage pipeline (Fetch, Decode, Execute, Memory, Writeback)

Basic memory-mapped I/O

UART/LED peripheral or simple GPIO

it include resource learning material as well as step by step guide to the implementation. 



Building arithmatic logic unit!!
the first and most important to step to start is by building an ALU which is very basic component in the cpu. By trying to write verilog or system verilog code on ALU, basic fundamental of digital circuit can be learned and implement. The code can be found in the folder above trying to build it yourself as well to learn more about the ALU 

next, we will design a program counter that hold the next instruction to be processed, it is very simple and easing as well as important in computer architeture, it updates every clock cycle and increase by 4.
