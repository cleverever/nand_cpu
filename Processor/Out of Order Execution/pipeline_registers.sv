`include "nand_cpu.svh"

interface metadata_ifc;
logic valid;
logic rob_addr;

modport in
(
    input valid, rob_addr
);
modport out
(
    output valid, rob_addr
);
endinterface

module i2d
(
    input logic clk,
    input logic n_rst,

    output logic valid
);

always_ff @(posedge clk) begin

end
endmodule

module e_r2a
(
    input logic clk,
    input logic n_rst,

    metadata_ifc.in md_in,
    rf_dst_ifc.in rf_dst_in,
    alu_input_ifc.in alu_input_in,

    metadata_ifc.out md_out,
    rf_dst_ifc.out rf_dst_out,
    alu_input_ifc.out alu_input_out
);

always_ff @(posedge clk) begin
    md_out.valid <= md_in.valid;
    md_out.rob_addr <= md_in.rob_addr;

    rf_dst_out.write_dst <= rf_dst_in.write_dst;
    rf_dst_out.rw_addr <= rf_dst_in.rw_addr;
    rf_dst_out.rs_addr <= rf_dst_in.rs_addr;

    out.op0 <= in.op0;
    out.op1 <= in.op1;
    out.alu_op <= in.alu_op;
end
endmodule

module e_a2c
(
    input logic clk,
    input logic n_rst,
    
    metadata_ifc.in md_in,
    regfile_d_write_ifc.rf e_a_d_write,
    regfile_s_write_ifc.rf e_a_s_write,

    metadata_ifc.out md_out,
    regfile_d_write_ifc.write e_c_d_write,
    regfile_s_write_ifc.write e_c_s_write
);

always_ff @(posedge clk) begin
    md_out.valid <= md_in.valid;
    md_out.rob_addr <= md_in.rob_addr;

    e_c_d_write.valid <= e_a_d_write.valid;
    e_c_d_write.data <= e_a_d_write.data;
    e_c_d_write.addr <= e_a_d_write.addr;

    e_c_s_write.valid <= e_a_s_write.valid;
    e_c_s_write.data <= e_a_s_write.data;
    e_c_s_write.addr <= e_a_s_write.addr;
end
endmodule