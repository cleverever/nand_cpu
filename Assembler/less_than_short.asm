//----------------------------------------------------------------------------------------------------
//LESS_THAN_SHORT
//----------------------------------------------------------------------------------------------------
//Input(s): MEM[0x0000], MEM[0x0001]
//Register usage: R0-11
//Output(s): MEM[0x0002]
//MEM[0x0002]: (MEM[0x0000] < MEM[0x0001])? 1 : 0
CL
CP R1
LI 0b0001 #0
LD R0
CP R2 //R2 = MEM[0x0001]
LD R1
CP R1 //R1 = MEM[0x0000]

//Storing branch addresses in R7-11
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
NND R1 //R0 = ~R1
NND R0 //R0 = R1
NND R5 //R0 = ~R1[15]
NND R0 //R0 = R1[15]
CP R4 //R4 = R1[15]

CL
NND R0
NND R2 //R0 = ~R2
NND R0 //R0 = R2
NND R5 //R0 = ~R2[15]
NND R0 //R0 = R2[15]
CP R3 //R3 = R2[15]

//If current MSB equal, check next bit, otherwise compare
NE R4
CL
LI 0b0010 #1
LI 0b0101 #0
BR R0 //if(R1[15] != R2[15]){goto COMPARE}

//Shift bit mask to check next bit
CL
LI 0b0001 #0
CP R6 //R6 = 1
CL
NND R0
NND R5 //R0 = ~R5
NND R0 //R0 = R5
RS R6 //R0 = R5 >> 1
CP R5 //R5 = R5 >> 1

//Compare bits
//for(int i = 14; i >= 0; i--)
//LOOP:
CL
NND R0
NND R1 //R0 = ~R1
NND R0 //R0 = R1
NND R5 //R0 = ~R1[i]
NND R0 //R0 = R1[i]
CP R3 //R3 = R1[i]

CL
NND R0
NND R2 //R0 = ~R2
NND R0 //R0 = R2
NND R5 //R0 = ~R2[i]
NND R0 //R0 = R2[i]
CP R4 //R4 = R2[i]

NE R3
BR R7 //if(R1[i] != R2[i]){goto COMPARE}

//Shift bit mask to check next bit
CL
NND R0
NND R5 //R0 = ~R5
NND R0 //R0 = R5
RS R6 //R0 = R5 >> 1
CP R5 //R5 = R5 >> 1

//If bit mask is zero, no bits left to compare,
//numbers are equal and comparison is false
CL
NE R5
BR R8 //if(R5 != 0){goto LOOP}
EQ R0
BR R7 //else{goto FALSE}
//Endfor

//COMPARE:
//Determine if R3 > R4 or R3 < R4, R3 == R4 is impossible in this situation
CL
EQ R3
BR R9 //if(R3 == 0){goto TRUE}
EQ R0
BR R10 //else{goto FALSE}

//TRUE:
CL
LI 0b0010 #0
CP R1
LI 0b0001 #0
ST R1 //MEM[0x0002] = 1
BR R11 //goto HLT

//FALSE:
CL
LI 0b0010 #0
CP R1
CL
ST R1 //MEM[0x0002] = 0
HLT #0
