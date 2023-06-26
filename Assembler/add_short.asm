//MEM[0x0004] = MEM[0x0000] + MEM[0x0002]
//Initialize variables
CL
CP R1 //R1 = 0
LI 0b0001 #0
CP R2 //R3 = 1
LI 0b0010 #0
CP R3 //R2 = 2
LD R1 //R0 = MEM[0x0000]
CP R1 //R1 = MEM[0x0000]
LD R2 //R0 = MEM[0x0002]
CP R2 //R2 = MEM[0x0002]
LI 0b0000 #3
LI 0b0000 #2
LI 0b0000 #1
LI 0b0100 #0
CP R7
LI 0b1111 #3
LI 0b1111 #2
LI 0b1110 #1
LI 0b1101 #0
CP R6

//Cyclic carry addition
CL
NND R0
NND R1 //R0 = ~R1
CP R4 //R4 = ~R1
NND R0 //R0 = R1
NND R2 //R0 = ~(R1 & R2)
CP R5 //R5 = ~(R1 & R2)
NND R0 //R0 = R1 & R2
LS R3 //R0 = R1 & R2 << 1
CP R1 //R1 = R1 & R2 << 1
CL
NND R0
NND R2 //R0 = ~R2
NND R3 //R0 = R1 | R2
NND R4 //R0 = R1 XNOR R2
NND R0 //R0 = R1 XOR R2
CP R2 //R2 = R1 XOR R2
CL
NE R1
BR R6

//Storing result
CL
NND R0
NND R2
NND R0
ST R7

HLT #0