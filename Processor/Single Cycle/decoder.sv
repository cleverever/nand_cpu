interface decoded_instr;
logic read_a;
logic write_a;

logic read_r;
logic write_r;
logic [$clog2(`NUM_REG) - 1 : 0] r;

logic use_immdt;
logic [3 : 0] immdt;
logic [5 : 4] shift;

logic interrupt;
logic halt;

nand_cpu_pkg::ALU_OP alu_op;

modport in
(
    input enable, addr, data
);
modport out
(
    output enable, addr, data
);
endinterface

module decoder
(
    input logic [7 : 0] instr;
    decoded.out out
);

always_comb begin
    out.r = instr[3 : 0];
    out.immdt = instr[3 : 0];
    out.shift = instr[5 : 4];
    out.interrupt = instr[7 : 4] == 4'b1110;
    out.halt = instr[7 : 4] == 4'b1111;
    priority casez(instr)
        8'b00000000 : begin //CL
            out.read_a = 1'b0;
            out.write_a = 1'b1;
            out.read_r = 1'b0;
            out.write_r = 1'b0;
            use_immdt = 1'b0;
            alu_op = ALU_CLR;
        end
        8'b0000???? : begin //CP
            out.read_a = 1'b1;
            out.write_a = 1'b0;
            out.read_r = 1'b0;
            out.write_r = 1'b1;
            use_immdt = 1'b0;
            alu_op = ALU_CP;
        end
        8'b0001???? : begin //NND
            out.read_a = 1'b1;
            out.write_a = 1'b1;
            out.read_r = 1'b1;
            out.write_r = 1'b0;
            use_immdt = 1'b0;
            alu_op = ALU_NAND;
        end
        8'b0010???? : begin //LS
            out.read_a = 1'b1;
            out.write_a = 1'b1;
            out.read_r = 1'b1;
            out.write_r = 1'b0;
            use_immdt = 1'b0;
            alu_op = ALU_LS;
        end
        8'b0011???? : begin //RS
            out.read_a = 1'b1;
            out.write_a = 1'b1;
            out.read_r = 1'b1;
            out.write_r = 1'b0;
            use_immdt = 1'b0;
            alu_op = ALU_RS;
        end
        8'b0100???? : begin //EQ
            out.read_a = 1'b1;
            out.write_a = 1'b0;
            out.read_r = 1'b1;
            out.write_r = 1'b0;
            use_immdt = 1'b0;
            alu_op = ALU_EQ;
        end
        8'b0101???? : begin //NE
            out.read_a = 1'b1;
            out.write_a = 1'b0;
            out.read_r = 1'b1;
            out.write_r = 1'b0;
            use_immdt = 1'b0;
            alu_op = ALU_NE;
        end
        8'b0110???? : begin //BR
            out.read_a = 1'b0;
            out.write_a = 1'b0;
            out.read_r = 1'b1;
            out.write_r = 1'b0;
            use_immdt = 1'b0;
        end
        8'b0111???? : begin //JRL
            out.read_a = 1'b0;
            out.write_a = 1'b0;
            out.read_r = 1'b1;
            out.write_r = 1'b1;
            use_immdt = 1'b0;
        end
        8'b10?????? : begin //LI
            out.read_a = 1'b1;
            out.write_a = 1'b1;
            out.read_r = 1'b0;
            out.write_r = 1'b0;
            use_immdt = 1'b1;
            alu_op = ALU_LI;
        end
        8'b1100???? : begin //LD
            out.read_a = 1'b1;
            out.write_a = 1'b1;
            out.read_r = 1'b1;
            out.write_r = 1'b0;
            use_immdt = 1'b0;
        end
        8'b1101???? : begin //ST
            out.read_a = 1'b1;
            out.write_a = 1'b0;
            out.read_r = 1'b1;
            out.write_r = 1'b0;
            use_immdt = 1'b0;
        end
        8'b1110???? : begin //INT
            out.read_a = 1'b0;
            out.write_a = 1'b0;
            out.read_r = 1'b0;
            out.write_r = 1'b0;
            use_immdt = 1'b1;
        end
        8'b1111???? : begin //HLT
            out.read_a = 1'b0;
            out.write_a = 1'b0;
            out.read_r = 1'b0;
            out.write_r = 1'b0;
            use_immdt = 1'b1;
        end
    endcase
end
endmodule