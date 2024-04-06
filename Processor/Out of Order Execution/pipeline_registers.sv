`include "nand_cpu.svh"

module E_R2A
(
    alu_input_ifc.in in,
    alu_input_ifc.out out,
);

always_ff @(posedge clk) begin
    out.op0 <= in.op0;
    out.op1 <= in.op1;
    out.alu_op <= in.alu_op;
end

endmodule