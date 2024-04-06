`include "nand_cpu.svh"

interface metadata_ifc;
logic valid;
logic commit_addr;

modport in
(
    input valid, commit_addr
);
modport out
(
    output valid, commit_addr
);
endinterface

module e_r2a
(
    metadata_ifc.in md_in,
    alu_input_ifc.in in,

    metadata_ifc.out md_out,
    alu_input_ifc.out out
);

always_ff @(posedge clk) begin
    md_out.valid <= md_in.valid;
    md_out.commit_addr <= md_in.commit_addr;

    out.op0 <= in.op0;
    out.op1 <= in.op1;
    out.alu_op <= in.alu_op;
end


endmodule

module e_a2c
(
    input logic [15:0] alu_result
);

endmodule