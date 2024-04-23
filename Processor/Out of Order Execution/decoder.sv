`include "nand_cpu.svh"

typedef enum {EX, ST, LD, BR} BUFFER;

interface decoder_ifc;
BUFFER buffer_sel;
logic use_ra;

logic use_rt;
logic [3 : 0] rt_addr;

logic use_rw;
logic [3 : 0] rw_addr;

logic use_rs;

logic use_immdt;
logic [3 : 0] immdt;
logic [5 : 4] shift;

logic mem_access;
nand_cpu_pkg::MemOp mem_op;

logic jump;
logic branch;

logic interrupt;
logic halt;

nand_cpu_pkg::AluOp alu_op;

modport in
(
    input use_ra, use_rt, rt_addr, use_rw, rw_addr, use_rs, use_immdt,
    immdt, shift, mem_access, mem_op, jump, branch, interrupt, halt, alu_op
);
modport out
(
    output use_ra, use_rt, rt_addr, use_rw, rw_addr, use_rs, use_immdt,
    immdt, shift, mem_access, mem_op, jump, branch, interrupt, halt, alu_op
);
endinterface

module decoder
(
    input logic [7 : 0] instr,

    decoder_ifc.out out
);

always_comb begin
    port.rt_addr = instr[3 : 0];
    port.rw_addr = 4'b0000;
    port.use_rs = 1'b0;
    port.immdt = instr[3 : 0];
    port.shift = instr[5 : 4];
    port.mem_access = 1'b0;
    port.jump = 1'b0;
    port.branch = 1'b0;
    port.interrupt = 1'b0;
    port.halt = 1'b0;
    priority casez(instr)
        8'b00000000 : begin //CL
            port.buffer_sel = EX;
            port.use_ra = 1'b0;
            port.use_rt = 1'b0;
            port.use_rw = 1'b1;
            port.use_immdt = 1'b0;
            port.alu_op = ALU_CL;
        end
        8'b0000???? : begin //CP
            port.buffer_sel = EX;
            port.use_ra = 1'b1;
            port.use_rt = 1'b0;
            port.use_rw = 1'b1;
            port.rw_addr = instr[3 : 0];
            port.use_immdt = 1'b0;
            port.alu_op = ALU_CP;
        end
        8'b0001???? : begin //NND
            port.buffer_sel = EX;
            port.use_ra = 1'b1;
            port.use_rt = 1'b1;
            port.use_rw = 1'b1;
            port.use_immdt = 1'b0;
            port.alu_op = ALU_NAND;
        end
        8'b0010???? : begin //LS
            port.buffer_sel = EX;
            port.use_ra = 1'b1;
            port.use_rt = 1'b1;
            port.use_rw = 1'b1;
            port.use_immdt = 1'b0;
            port.alu_op = ALU_LS;
        end
        8'b0011???? : begin //RS
            port.buffer_sel = EX;
            port.use_ra = 1'b1;
            port.use_rt = 1'b1;
            port.use_rw = 1'b1;
            port.use_immdt = 1'b0;
            port.alu_op = ALU_RS;
        end
        8'b0100???? : begin //EQ
            port.buffer_sel = EX;
            port.use_ra = 1'b1;
            port.use_rt = 1'b1;
            port.use_rw = 1'b0;
            port.use_rs = 1'b1;
            port.use_immdt = 1'b0;
            port.alu_op = ALU_EQ;
        end
        8'b0101???? : begin //NE
            port.buffer_sel = EX;
            port.use_ra = 1'b1;
            port.use_rt = 1'b1;
            port.use_rw = 1'b0;
            port.use_rs = 1'b1;
            port.use_immdt = 1'b0;
            port.alu_op = ALU_NE;
        end
        8'b0110???? : begin //BR
            port.buffer_sel = BR;
            port.use_ra = 1'b0;
            port.use_rt = 1'b1;
            port.use_rw = 1'b0;
            port.use_immdt = 1'b0;
            port.branch = 1'b1;
        end
        8'b0111???? : begin //JRL
            port.buffer_sel = BR;
            port.use_ra = 1'b0;
            port.use_rt = 1'b1;
            port.use_rw = 1'b1;
            port.rw_addr = instr[3 : 0];
            port.use_immdt = 1'b0;
            port.jump = 1'b1;
        end
        8'b10?????? : begin //LI
            port.buffer_sel = EX;
            port.use_ra = 1'b1;
            port.use_rt = 1'b0;
            port.use_rw = 1'b1;
            port.use_immdt = 1'b1;
            port.alu_op = ALU_LI;
        end
        8'b1100???? : begin //LD
            port.buffer_sel = LD;
            port.use_ra = 1'b0;
            port.use_rt = 1'b1;
            port.use_rw = 1'b1;
            port.use_immdt = 1'b0;
            port.mem_access = 1'b1;
            port.mem_op = MEM_READ;
        end
        8'b1101???? : begin //ST
            port.buffer_sel = ST;
            port.use_ra = 1'b1;
            port.use_rt = 1'b1;
            port.use_rw = 1'b0;
            port.use_immdt = 1'b0;
            port.mem_access = 1'b1;
            port.mem_op = MEM_WRITE;
        end
        8'b1110???? : begin //INT
            port.buffer_sel = BR;
            port.use_ra = 1'b0;
            port.use_rt = 1'b0;
            port.use_rw = 1'b0;
            port.use_immdt = 1'b1;
            port.interrupt = 1'b1;
        end
        8'b1111???? : begin //HLT
            port.use_ra = 1'b0;
            port.use_rt = 1'b0;
            port.use_rw = 1'b0;
            port.use_immdt = 1'b1;
            port.halt = 1'b1;
        end
    endcase
end
endmodule