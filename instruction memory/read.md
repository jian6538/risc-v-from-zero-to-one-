instruction memory is a read only memory and it can be read and cannot be modify. It read the instruction from the address given by the program counter.
for example 
a = b + c;
in assembly learning mean 
add x5, x6, x7
since assembly need to translate to machine code thus 
| funct7 | rs2 | rs1 | funct3 | rd | opcode |
|:---|:---|:---|:---|:---|:---|
| 0000000|00111|00110| 000 |00101|0110011|
| (for ADD)|(x7) |(x6) |(for ADD)|(x5) |(R-type)|

When you group these bits together, you get the final 32-bit binary instruction:
00000000011100110000001010110011



since the memory address is in word while the program counter is in byte , thus we need to divide 4 to know which word the memory are pointing 
