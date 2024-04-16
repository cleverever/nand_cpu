//----------------------------------------------------------------------------------------------------
//COUNT_TO:
//----------------------------------------------------------------------------------------------------
//Input(s): MEM[0x0000]
//Register usage: R0-10, R15
//Output(s): MEM[0x0001] - MEM[MEM[0x0000]]
//EXAMPLE
//Input: MEM[0x0000] = 3
//Output: MEM[0x0001] = 1, MEM[0x0002] = 2, MEM[0x0003] = 3
//LOOP:
CL
LD R0
CP R7
CL
CP R1
EQ R7
LI 0b0001 #1
LI 0b0001 #0
BR R0
NND R0
LI 0b1111 #1
LI 0b0101 #0
CP R9
CL //LOOP
LI 0b0001 #1
LI 0b1010 #0
CP R15
JRL R15 //INCREMENT_SUBROUTINE(R1)
CL
NND R0
NND R1
NND R0
NE R7
ST R1
BR R9 //BR LOOP
HLT #0



//----------------------------------------------------------------------------------------------------
//INCREMENT_SUBROUTINE:
//----------------------------------------------------------------------------------------------------
//Input(s): R1, R15
//R1: Number to increment
//R15: Return address
//Register usage: R0-6, R15
//Output(s): R1
//R1: R1 + 1
CL
LI 0b0001 #0
CP R3
CP R2
LI 0b1111 #3
LI 0b1111 #2
LI 0b1110 #1
LI 0b1101 #0
CP R6

CL
NND R0
NND R2
CP R4
NND R0
NND R1
CP R5
NND R0
LS R3
CP R2
CL
NND R0
NND R1
NND R4
NND R5
NND R0
CP R1
CL
NE R2
BR R6

JRL R15 //return
