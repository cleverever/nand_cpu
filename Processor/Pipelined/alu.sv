`include "nand_cpu.svh"

interface alu_input_ifc;
logic op0;
logic op1;
nand_cpu_pkg::ALU_OP alu_op;

modport in
(
    input op0, op1, alu_op
);
modport out
(
    output op0, op1, alu_op
);
endinterface

module alu
(
    alu_input_ifc.in in,

    output logic [15 : 0] out
);

always_comb begin
    case(in.alu_op)
        ALU_CL : begin
            result = '0;
        end
        ALU_CP : begin
            result = in.op0;
        end
        ALU_NAND : begin
            result = ~(in.op0 & in.op1);
        end
        ALU_LS : begin
            result = in.op0 << in.op1;
        end
        ALU_RS : begin
            result = in.op0 >> in.op1;
        end
        ALU_EQ : begin
            result[15 : 1] = '0;
            result[0] = in.op0 == in.op1;
        end
        ALU_NE : begin
            result[15 : 1] = '0;
            result[0] = in.op0 != in.op1;
        end
        ALU_LI : begin
            case(in.op1[5 : 4])
                2'b00 : begin
                    result = {in.op0[15 : 4], in.op1[3 : 0]};
                end
                2'b01 : begin
                    result = {in.op0[15 : 8], in.op1[3 : 0], in.op0[3 : 0]};
                end
                2'b10 : begin
                    result = {in.op0[15 : 12], in.op1[3 : 0], in.op0[7 : 0]};
                end
                2'b11 : begin
                    result = {in.op1[3 : 0], in.op0[11 : 0]};
                end
            endcase
        end
    endcase
end
endmodule