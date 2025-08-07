# 1. forwarding 
sometimes, the source of next instruction used the previous instruction destination value, thus the next instruction calculate orginal of instruction instead of the latest one     

add x5, x1, x2     // Instruction 1 (writes to x5)  
sub x6, x5, x3     // Instruction 2 (used previous x5 instead of the instruction 1)

in this example , the instruction 2 calculate the orginal x5 instead of the calculated value of instruction 1.This is because the first instruction need to perform write back stage only the instruction 2 receive the latest value but the instruction 2 is at execute stage when the instruction 1 is at memory stage .Thus , we need to feed the value of x5 at e
xecute stage instead of waiting the instruction 1 go to written back stage.  

# 2. Stalling
sometimes , forwarding is not enough, lets think about this special case lw , load word mean tell the processor that go to a specific location in the memory and put into the register , thus this is the special case that the data is taken at memory stage which is quite last step 


lw x5, 0(x1)       // Instruction 1 (load to x5)  

add x6, x5, x2     // Instruction 2 (needs x5 immediately)

durng the instruction 2 instruction decode stage , it need the value of x5 immediately through the register file module, but since the instruction 1 is not at memory stage and written back stage yet thus the instruction 2 get garbage value from the destination, thus we need to produce a technique to solve the problem 
one of the technique is by waiting one more cycle and hold the instruction 2 , let the instruction 1 goes to memory stage and instruction 2 is hold , but this way will make the processor slow. Other technique used is by compiler and out of order processor that execute unrelated instruction first that do not use x5. 

# 3. Flushing
same as the above, flushing can think like you flush your toilet, this is because the instruction that are executed need to be erase so that it does not produce error this happen with the instruction branch   
0x100: beq x1, x2, L1   // Branch to address L1 if x1 == x2  

0x104: add x5, x6, x7   // <-- Incorrectly fetched if branch is taken  

0x108: sub x8, x9, x10  // <-- Incorrectly fetched if branch is taken  

0x10C: or x11, x12, x13 // <-- Incorrectly fetched if branch is taken  

...  


    
L1:    and x14, x15, x16 // The correct instruction  


this is due to the memory stage is at stage 4 but the processor is already doing the pipeline of the previous, so when the processor fetch from the memory , the previous instruction is already executed and need to be erase, this as well make the waste of resource, to prevent it engineer has invent some of the technique such as make the branch earlier , Branch Delay Slot and so forth 
