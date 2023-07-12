`include "nand_cpu.svh"

interface pr_pass_ifc;
logic valid;
logic halt;
logic interrupt;
logic [3 : 0] int_code;
logic unsigned [`PC_SIZE - 1 : 0] pc;
logic pc_override;
logic [`PC_SIZE - 1 : 0] target;

modport in
(
    input valid, halt, interrupt, int_code, pc, pc_override, target
);
modport out
(
    output valid, halt, interrupt, int_code, pc, pc_override, target
);
endinterface

module i2d_pr
(
    input logic clk,
    input logic n_rst,

    pipeline_ctrl_ifc.in ctrl,

    pr_pass_ifc.in i_pr_pass,
    pr_pass_ifc.out o_pr_pass,

    input logic [7 : 0] i_instr,
    output logic [7 : 0] o_instr
);

always_ff @(posedge clk) begin
    if(~n_rst) begin
        o_pr_pass.valid <= 1'b0;
    end
    else begin
        if(~ctrl.retain) begin
            o_pr_pass.valid <= i_pr_pass.valid & ~ctrl.clear;
            o_pr_pass.halt <= i_pr_pass.halt;
            o_pr_pass.interrupt <= i_pr_pass.interrupt;
            o_pr_pass.int_code <= i_pr_pass.int_code;
            o_pr_pass.pc <= i_pr_pass.pc;
            o_pr_pass.pc_override <= i_pr_pass.pc_override;
            o_pr_pass.target <= i_pr_pass.target;

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
    d_cache_input_ifc.out o_d_cache_input,

    branch_feedback_ifc.in i_branch_feedback,
    branch_feedback_ifc.out o_branch_feedback
);

always_ff @(posedge clk) begin
    if(~n_rst) begin
        o_pr_pass.valid <= 1'b0;
    end
    else begin
        if(~ctrl.retain) begin
            o_pr_pass.valid <= i_pr_pass.valid & ~ctrl.clear;
            o_pr_pass.halt <= i_pr_pass.halt;
            o_pr_pass.interrupt <= i_pr_pass.interrupt;
            o_pr_pass.int_code <= i_pr_pass.int_code;
            o_pr_pass.pc <= i_pr_pass.pc;
            o_pr_pass.pc_override <= i_pr_pass.pc_override;
            o_pr_pass.target <= i_pr_pass.target;

            o_act_pass.mem_access <= i_act_pass.mem_access;
            o_act_pass.reg_write <= i_act_pass.reg_write;
            o_act_pass.reg_addr <= i_act_pass.reg_addr;
            o_act_pass.ps_write <= i_act_pass.ps_write;

            o_alu_input.op0 <= i_alu_input.op0;
            o_alu_input.op1 <= i_alu_input.op1;
            o_alu_input.alu_op <= i_alu_input.alu_op;

            o_d_cache_input.mem_access <= i_d_cache_input.mem_access;
            o_d_cache_input.address <= i_d_cache_input.address;
            o_d_cache_input.mem_op <= i_d_cache_input.mem_op;
            o_d_cache_input.data <= i_d_cache_input.data;

            o_branch_feedback.branch <= i_branch_feedback.branch;
            o_branch_feedback.pc <= i_branch_feedback.pc;
            o_branch_feedback.predict_target <= i_branch_feedback.predict_target;
            o_branch_feedback.feedback_target <= i_branch_feedback.feedback_target;
            o_branch_feedback.predict_taken <= i_branch_feedback.predict_taken;
            o_branch_feedback.feedback_taken <= i_branch_feedback.feedback_taken;
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
            o_pr_pass.halt <= i_pr_pass.halt;
            o_pr_pass.interrupt <= i_pr_pass.interrupt;
            o_pr_pass.int_code <= i_pr_pass.int_code;
            o_pr_pass.pc <= i_pr_pass.pc;
            o_pr_pass.pc_override <= i_pr_pass.pc_override;
            o_pr_pass.target <= i_pr_pass.target;
            
            o_writeback.reg_write <= i_writeback.reg_write;
            o_writeback.reg_addr <= i_writeback.reg_addr;
            o_writeback.reg_data <= i_writeback.reg_data;
            o_writeback.ps_write <= i_writeback.ps_write;
            o_writeback.ps_data <= i_writeback.ps_data;
        end
    end
end
endmodule