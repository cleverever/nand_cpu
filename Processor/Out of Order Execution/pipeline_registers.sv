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

interface pipeline_ctrl_ifc;
logic retain;
logic clear;

modport in
(
    input retain, clear
);
modport out
(
    output retain, clear
);
endinterface

module i2d
(
    input logic clk,
    input logic n_rst,

    pipeline_ctrl_ifc.in ctrl,

    input logic valid_in,
    input logic [7:0] instr_in,
    input logic [`PC_SIZE-1:0] pc_in,
    branch_predictor_output_ifc.in branch_prediction_in,

    output logic valid_out,
    output logic [7:0] instr_out,
    output logic [`PC_SIZE-1:0] pc_out,
    branch_predictor_output_ifc.out branch_prediction_out
);

always_ff @(posedge clk) begin
    if(~n_rst) begin
        //TODO RESET
    end
    else begin
        if(~ctrl.stall) begin
            //TODO in = out;
        end
    end
end
endmodule

//BRANCH

//EXECUTE
module e_r2a
(
    input logic clk,
    input logic n_rst,

    pipeline_ctrl_ifc.in ctrl,

    metadata_ifc.in md_in,
    rf_dst_ifc.in rf_dst_in,
    alu_input_ifc.in alu_input_in,

    metadata_ifc.out md_out,
    rf_dst_ifc.out rf_dst_out,
    alu_input_ifc.out alu_input_out
);

always_ff @(posedge clk) begin
    if(~ctrl.retain) begin
        md_out.valid <= md_in.valid & ~ctrl.clear;
        md_out.rob_addr <= md_in.rob_addr;

        rf_dst_out.write_dst <= rf_dst_in.write_dst;
        rf_dst_out.rw_addr <= rf_dst_in.rw_addr;
        rf_dst_out.rs_addr <= rf_dst_in.rs_addr;

        alu_input_out.op0 <= alu_input_in.op0;
        alu_input_out.op1 <= alu_input_in.op1;
        alu_input_out.alu_op <= alu_input_in.alu_op;
    end
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

//MEMORY
module m_r2a
(
    input logic clk,
    input logic n_rst,

    pipeline_ctrl_ifc.in ctrl,

    metadata_ifc.in md_in,
    d_cache_input_ifc.in cache_input_in,
    input logic [15:0] rw_addr_in,

    metadata_ifc.out md_out,
    d_cache_input_ifc.out cache_input_out,
    output logic rw_addr_out
);

always_ff @(posedge clk) begin
    if(~ctrl.retain) begin
        md_out.valid <= md_in.valid & ~ctrl.clear;
        md_out.rob_addr <= md_in.rob_addr;

        cache_input_out.address <= cache_input_in.address;
        cache_input_out.mem_op <= cache_input_in.mem_op;
        cache_input_out.data <= cache_input_in.data;

        rw_addr_out <= rw_addr_in;
    end
end
endmodule