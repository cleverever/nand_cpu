//----------------------------------------------------------------------------------------------------
//COUNT_TO:
//----------------------------------------------------------------------------------------------------
//Input(s): MEM[0x0000]
//Register usage: R0-10, R15
//Output(s): MEM[0x0001] - MEM[MEM[0x0000]]
//EXAMPLE
//Input: MEM[0x0000] = 3
//Output: MEM[0x0001] = 1, MEM[0x0002] = 2, MEM[0x0003] = 3
CL
LD R0 //R0 = MEM[0x0000]
CP R7 //R7 = MEM[0x0000]
CL
CP R1
EQ R7
LI 0b0001 #1
LI 0b0001 #0
BR R0 //if(MEM[0x0000] == 0){goto HLT}
NND R0
LI 0b1111 #1
LI 0b0101 #0
CP R9

//LOOP:
CL
LI 0b0001 #1
LI 0b1010 #0
CP R15
JRL R15 //INCREMENT_SUBROUTINE()
CL
NND R0
NND R1 //R0 = ~R1
NND R0 //R0 = R1
NE R7
ST R1 //MEM[R1] = R1
BR R9 //if(R1 != MEM[0x0000]){goto LOOP}
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
CP R3 //R3 = 1
CP R2 //R2 = 1

//R6 contains branch address
LI 0b1111 #3
LI 0b1111 #2
LI 0b1110 #1
LI 0b1101 #0
CP R6

//LOOP:
CL
NND R0
NND R2 //R0 = ~R2
CP R4 //R4 = ~R2
NND R0 //R0 = R2
NND R1 //R0 = ~(R1 & R2)
CP R5 //R5 = ~(R1 & R2)
NND R0 //R0 = R1 & R2
LS R3 //R0 = (R1 & R2) << 1
CP R2 //R2 = (R1 & R2) << 1
CL
NND R0
NND R1 //R0 = ~R1
NND R4 //R0 = R1 | R2
NND R5 //R0 = R1 XNOR R2
NND R0 //R0 = R1 XOR R2
CP R1 //R1 = R1 XOR R2
CL
NE R2
BR R6 //if(R2 != 0){goto LOOP}

JRL R15 //return
