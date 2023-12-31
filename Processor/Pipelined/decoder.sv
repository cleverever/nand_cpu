`include "nand_cpu.svh"

interface decoder_output_ifc;
logic use_ra;

logic use_rt;
logic [3 : 0] rt_addr;

logic use_rw;
logic [3 : 0] rw_addr;

logic read_ps;
logic write_ps;

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
    input use_ra, use_rt, rt_addr, use_rw, rw_addr, read_ps, write_ps, use_immdt,
    immdt, shift, mem_access, mem_op, jump, branch, interrupt, halt, alu_op
);
modport out
(
    output use_ra, use_rt, rt_addr, use_rw, rw_addr, read_ps, write_ps, use_immdt,
    immdt, shift, mem_access, mem_op, jump, branch, interrupt, halt, alu_op
);
endinterface

module decoder
(
    input logic [7 : 0] instr,

    decoder_output_ifc.out out
);

always_comb begin
    out.rt_addr = instr[3 : 0];
    out.rw_addr = 4'b0000;
    out.read_ps = 1'b0;
    out.write_ps = 1'b0;
    out.immdt = instr[3 : 0];
    out.shift = instr[5 : 4];
    out.mem_access = 1'b0;
    out.jump = 1'b0;
    out.branch = 1'b0;
    out.interrupt = 1'b0;
    out.halt = 1'b0;
    priority casez(instr)
        8'b00000000 : begin //CL
            out.use_ra = 1'b0;
            out.use_rt = 1'b0;
            out.use_rw = 1'b1;
            out.use_immdt = 1'b0;
            out.alu_op = ALU_CL;
        end
        8'b0000???? : begin //CP
            out.use_ra = 1'b1;
            out.use_rt = 1'b0;
            out.use_rw = 1'b1;
            out.rw_addr = instr[3 : 0];
            out.use_immdt = 1'b0;
            out.alu_op = ALU_CP;
        end
        8'b0001???? : begin //NND
            out.use_ra = 1'b1;
            out.use_rt = 1'b1;
            out.use_rw = 1'b1;
            out.use_immdt = 1'b0;
            out.alu_op = ALU_NAND;
        end
        8'b0010???? : begin //LS
            out.use_ra = 1'b1;
            out.use_rt = 1'b1;
            out.use_rw = 1'b1;
            out.use_immdt = 1'b0;
            out.alu_op = ALU_LS;
        end
        8'b0011???? : begin //RS
            out.use_ra = 1'b1;
            out.use_rt = 1'b1;
            out.use_rw = 1'b1;
            out.use_immdt = 1'b0;
            out.alu_op = ALU_RS;
        end
        8'b0100???? : begin //EQ
            out.use_ra = 1'b1;
            out.use_rt = 1'b1;
            out.use_rw = 1'b0;
            out.write_ps = 1'b1;
            out.use_immdt = 1'b0;
            out.alu_op = ALU_EQ;
        end
        8'b0101???? : begin //NE
            out.use_ra = 1'b1;
            out.use_rt = 1'b1;
            out.use_rw = 1'b0;
            out.write_ps = 1'b1;
            out.use_immdt = 1'b0;
            out.alu_op = ALU_NE;
        end
        8'b0110???? : begin //BR
            out.use_ra = 1'b0;
            out.use_rt = 1'b1;
            out.use_rw = 1'b0;
            out.read_ps = 1'b1;
            out.use_immdt = 1'b0;
            out.branch = 1'b1;
        end
        8'b0111???? : begin //JRL
            out.use_ra = 1'b0;
            out.use_rt = 1'b1;
            out.use_rw = 1'b1;
            out.rw_addr = instr[3 : 0];
            out.use_immdt = 1'b0;
            out.jump = 1'b1;
        end
        8'b10?????? : begin //LI
            out.use_ra = 1'b1;
            out.use_rt = 1'b0;
            out.use_rw = 1'b1;
            out.use_immdt = 1'b1;
            out.alu_op = ALU_LI;
        end
        8'b1100???? : begin //LD
            out.use_ra = 1'b0;
            out.use_rt = 1'b1;
            out.use_rw = 1'b1;
            out.use_immdt = 1'b0;
            out.mem_access = 1'b1;
            out.mem_op = MEM_READ;
        end
        8'b1101???? : begin //ST
            out.use_ra = 1'b1;
            out.use_rt = 1'b1;
            out.use_rw = 1'b0;
            out.use_immdt = 1'b0;
            out.mem_access = 1'b1;
            out.mem_op = MEM_WRITE;
        end
        8'b1110???? : begin //INT
            out.use_ra = 1'b0;
            out.use_rt = 1'b0;
            out.use_rw = 1'b0;
            out.use_immdt = 1'b1;
            out.interrupt = 1'b1;
        end
        8'b1111???? : begin //HLT
            out.use_ra = 1'b0;
            out.use_rt = 1'b0;
            out.use_rw = 1'b0;
            out.use_immdt = 1'b1;
            out.halt = 1'b1;
        end
    endcase
end
endmodule