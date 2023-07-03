`include "nand_cpu.svh"

interface pr_pass_ifc;
logic valid;
logic unsigned [`PC_SIZE - 1 : 0] pc;

modport in
(
    input valid, pc
);
modport out
(
    output valid, pc
);
endinterface

module i2d_pr
(
    input logic clk,
    input logic n_rst,

    pipeline_ctrl_ifc.in ctrl,

    pr_pass_ifc.in i_pr_pass,
    pr_pass_ifc.out o_pr_pass,

    input logic i_instr,
    output logic o_instr
);

always_ff @(posedge clk) begin
    if(~n_rst) begin
        o_pr_pass.valid <= 1'b0;
    end
    else begin
        if(~ctrl.retain) begin
            o_pr_pass.valid <= i_pr_pass.valid & ~ctrl.clear;
            o_pr_pass.pc <= i_pr_pass.pc;

            o_instr <= i_instr;
        end
    end
end
endmodule

module d2a_pr
(
    input logic clk,
    input logic n_rst,

    pipeline_ctrl_ifc.in ctrl,

    pr_pass_ifc.in i_pr_pass,
    pr_pass_ifc.out o_pr_pass,

    act_pass_ifc.in i_act_pass,
    act_pass_ifc.out o_act_pass,

    alu_input_ifc.in i_alu_input,
    alu_input_ifc.out o_alu_input,

    d_cache_input_ifc.in i_d_cache_input,
    d_cache_input_ifc.out o_d_cache_input

    o_branch_feedback_ifc.in i_branch_feedback,
    o_branch_feedback_ifc.out o_branch_feedback,
);

always_ff @(posedge clk) begin
    if(~n_rst) begin
        o_pr_pass.valid <= 1'b0;
    end
    else begin
        if(~ctrl.retain) begin
            o_pr_pass.valid <= i_pr_pass.valid & ~ctrl.clear;
            o_pr_pass.pc <= i_pr_pass.pc;

            o_act_pass.mem_access <= i_act_pass.mem_access;
            o_act_pass.reg_write <= i_act_pass.reg_write;
            o_act_pass.reg_addr <= i_act_pass.reg_addr;
            o_act_pass.ps_write <= i_act_pass.ps_write;

            o_alu_input.op0 <= i_alu_input.op0;
            o_alu_input.op1 <= i_alu_input.op1;
            o_alu_input.alu_op <= i_alu_input.alu_op;

            o_d_cache_input.mem_access <= o_d_cache_input.mem_access;
            o_d_cache_input.address <= i_d_cache_input.address;
            o_d_cache_input.mem_op <= i_d_cache_input.mem_op;
            o_d_cache_input.data <= i_d_cache_input.data;
        end
    end
end
endmodule

module a2w_pr
(
    input logic clk,
    input logic n_rst,

    pipeline_ctrl_ifc.in ctrl,

    pr_pass_ifc.in i_pr_pass,
    pr_pass_ifc.out o_pr_pass,

    writeback_ifc.in i_writeback,
    writeback_ifc.in o_writeback
);

always_ff @(posedge clk) begin
    if(~n_rst) begin
        o_pr_pass.valid <= 1'b0;
    end
    else begin
        if(~ctrl.retain) begin
            o_pr_pass.valid <= i_pr_pass.valid & ~ctrl.clear;
            o_pr_pass.pc <= i_pr_pass.pc;
            
            o_writeback.reg_write <= i_writeback.reg_write;
            o_writeback.reg_addr <= i_writeback.reg_addr;
            o_writeback.reg_data <= i_writeback.reg_data;
            o_writeback.ps_write <= i_writeback.ps_write;
            o_writeback.ps_data <= i_writeback.ps_data;
        end
    end
end
endmodule