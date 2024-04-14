# NAND CPU
### Current Working Iteration: Pipelined

## Abstract
The goal of this project is to create a simplified ISA and processor from scratch. Although simplistic, this processor will incorporate elements and optimizations present in modern processors. This processor is not designed to be efficient, but rather to demonstrate some performance enhancing implementations implemented in modern processors. To simplify the design, the processor will primarily use the NAND instruction for data manipulation, use a very small number of logic registers, and operate on only a small amount of data at a time.

## Description
8-bit instruction CPU with 16 16-bit logical registers. Works by accumulator architecture; R<sub>A</sub> (R<sub>0</sub>) acts as the accumulator, an implied operand and destination in most instructions. There is a special status register R<sub>S</sub> which is a single bit. It is set by comparison instructions and used to decide whether a branch is taken.

## ISA

| Name | Assembly | Machine Code | Description |
| -------- | -------- | -------- | -------- |
| Clear | CL | 00000000 | **R<sub>A</sub>** = 0 |
| Copy | CP | 0000-R4 | **R<sub>N</sub>** = **R<sub>A</sub>** |
| Nand | NND | 0001-R4 | **R<sub>A</sub>** = NAND(**R<sub>A</sub>**, **R<sub>N</sub>**) |
| Left Shift | LS | 0010-R4 | **R<sub>A</sub>** = **R<sub>A</sub>** << **R<sub>N</sub>** |
| Right Shift | RS | 0011-R4 | **R<sub>A</sub>** = **R<sub>A</sub>** >> **R<sub>N</sub>** |
| Equal | EQ | 0100-R4 | **R<sub>S</sub>** = **R<sub>A</sub>** == **R<sub>N</sub>** |
| Not Equal | NE | 0101-R4 | **R<sub>S</sub>** = **R<sub>A</sub>** != **R<sub>N</sub>** |
| Branch Register | BR | 0110-R4 | If(**R<sub>S</sub>** == 1){**PC** += **R<sub>N</sub>**} |
| Jump Register Link | JRL | 0111-R4 | **PC** = **R<sub>N</sub>**, **R<sub>N</sub>** = **PC** + 1 |
| Load Immediate | LI | 10-I2-I4 | **R<sub>A</sub>** = {**R<sub>A</sub>**[15:(**immdt2**\*4)+4], **immdt4**, **R<sub>A</sub>**[(**immdt2**\*4)-1:0]} |
| Load | LD | 1100-R4 | **R<sub>A</sub>** = **MEM**[**R<sub>N</sub>**] |
| Store | ST | 1101-R4 | **MEM**[**R<sub>N</sub>**] = **R<sub>A</sub>** |
| Interrupt | INT | 1110-I4 | (Not fully supported) |
| Halt | HLT | 1111-I4 | Halts machine with **immdt4** status code. |

## Single Cycle
<img src="/Processor/Single Cycle/Single Cycle.png" alt="Single Cycle Diagram">

## Pipelined
<img src="/Processor/Pipelined/Pipelined.png" alt="Pipelined Diagram">
