//R1 = MEM[0x0000]
//R2 = MEM[0x0001]
CL
CP R1
LI 0b0001 #0
LD R0
CP R2
LD R1
CP R1
CL
LI 0b1100 #0
CP R7
NND R0
LI 0b1110 #1
LI 0b1000 #0
CP R8
CL
LI 0b0011 #0
CP R9
LI 0b0111 #0
CP R10
LI 0b0101 #0
CP R11

//R5 is bit selector
CL
LI 0b1000 #3
CP R5

//First compare MSB (complement digit)
//Comparison is reversed because MSB is negative
CL
NND R0
NND R1
NND R0
NND R5
NND R0
CP R4

CL
NND R0
NND R2
NND R0
NND R5
NND R0
CP R3

//If current MSB equal, check next bit, otherwise compare
NE R4
CL
LI 0b0010 #1
LI 0b0101 #0
BR R0 //BR CMP

//Shift bit mask to check next bit
CL
LI 0b0001 #0
CP R6
CL
NND R0
NND R5
NND R0
RS R6
CP R5

//Compare bits
CL //LOOP
NND R0
NND R1
NND R0
NND R5
NND R0
CP R3

CL
NND R0
NND R2
NND R0
NND R5
NND R0
CP R4

NE R3
BR R7 //BR CMP

//Shift bit mask to check next bit
CL
NND R0
NND R5
NND R0
RS R6
CP R5

//If bit mask is zero, no bits left to compare,
//numbers are equal and comparison is false
CL
NE R5
BR R8 //BR LOOP
EQ R0
BR R7 //BR FALSE

CL //CMP
EQ R3
BR R9 //BR TRUE
EQ R0
BR R10 // BR FALSE
CL //TRUE
LI 0b0010 #0
CP R1
LI 0b0001 #0
ST R1
BR R11
CL //FALSE
LI 0b0010 #0
CP R1
CL
ST R1
HLT #0