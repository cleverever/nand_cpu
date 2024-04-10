# NAND CPU
### Current Working Iteration: Pipelined

## Abstract
The goal of this project is to create a simplified ISA and processor from scratch. Although simplistic, this processor will incorporate elements and optimizations present in modern processors. This processor is not designed to be efficient, but rather to demonstrate some performance enhancing implementations implemented in modern processors. To simplify the design, the processor will primarily use the NAND instruction for data manipulation, use a very small number of logic registers, and operate on only a small amount of data at a time.

## Description
8-bit instruction CPU with 16 16-bit logical registers. Works by accumulator architecture; R0 acts as the accumulator, an implied operand and destination in most instructions. There is a special status register RS which is a single bit. It is set by instructions EQ and NE and used to decide whether to take a BR instruction.

## ISA

| Name | Assembly | Machine Code | Description |
| -------- | -------- | -------- | -------- |
| Clear | CL | 00000000 | A = 0 |
| Copy | CP | 0000-R4 | R = A |
| Nand | NND | 0001-R4 | A = NAND(A, R) |
| Left Shift | LS | 0010-R4 | A = A << R |
| Right Shift | RS | 0011-R4 | A = A >> R |
| Equal | EQ | 0100-R4 | S = A == R |
| Not Equal | NE | 0101-R4 | S = A != R |
| Branch Register | BR | 0110-R4 | If(S == 1){PC += R} |
| Jump Register Link | JRL | 0111-R4 | PC = R, R = PC + 1 |
| Load Immediate | LI | 10-I2-I4 | Loads 4 bits into A shifted by immdt2 x 4. Other bits in A remain unchanged. |
| Load | LD | 1100-R4 | A = MEM[R] |
| Store | ST | 1101-R4 | MEM[R] = A |
| Interrupt | INT | 1110-I4 | (Not fully supported) |
| Halt | HLT | 1111-I4 | Halts machine with immdt4 status code. |
