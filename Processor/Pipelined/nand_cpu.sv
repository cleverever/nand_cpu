`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

logic [7 : 0] f_instr;
logic f_instr_valid;
branch_predictor_output_ifc f_branch_prediction();
pr_pass_ifc f_pr_pass();

pipeline_ctrl_ifc i2d_ctrl();

logic [7 : 0] d_instr;
alu_input_ifc d_alu_input();
d_alu_input_ifc d_d_cache_input();
branch_feedback_ifc d_branch_feedback();
act_pass_ifc d_act_pass();
pr_pass_ifc d_pr_pass();

pipeline_ctrl_ifc d2a_ctrl();

alu_input_ifc a_alu_input();
d_alu_input_ifc a_d_cache_input();
d_cache_ifc a_d_cache_output();
branch_feedback_ifc a_branch_feedback();
writeback_ifc a_writeback();
act_pass_ifc a_act_pass();
pr_pass_ifc a_pr_pass();

pipeline_ctrl_ifc a2w_ctrl();

writeback_ifc w_writeback();
pr_pass_ifc w_pr_pass();

fetch_ctrl_ifc fetch_ctrl();

//====================================================================================================
//FETCH
//====================================================================================================
fetch_unit FETCH_UNIT
(
    .clk,
    .n_rst,

    .interrupt_handler(),

    .i_fetch_ctrl(fetch_ctrl),

    .pc(pc),
    .halted(halt)
);

i_cache I_CACHE
(
    .pc(pc),

    .valid(f_instr_valid),
    .instr(f_instr)
);

branch_predictor branch_predictor
(
    .clk,
    .n_rst,
    
    .pc(pc),
    .ps(regfile_output.ps_data),
    
    .out(f_branch_prediction),

    .feedback_valid(a_pr_pass.valid),
    .i_feedback(a_branch_feedback)
);

fetch_glue FETCH_GLUE
(
    .i_pc(pc),
    .instr_valid(f_instr_valid),

    .o_pr_pass(f_pr_pass)
);

i2d_pr I2D_PR
(
    .clk,
    .n_rst,

    .ctrl(i2d_ctrl),

    .i_pr_pass(f_pr_pass),
    .o_pr_pass(d_pr_pass),

    .i_instr(f_instr),
    .o_instr(d_instr)
);

//====================================================================================================
//DECODE
//====================================================================================================
decoder DECODER
(
    .instr(d_instr),
    
    .out(decoder_output)
);

regfile REGFILE
(
    .clk,
    .n_rst,

    .writeback_valid(w_pr_pass.valid),
    .i_writeback(w_writeback),

    .i_reg_read(decoder_output),

    .out(regfile_output)
);

decode_glue DECODE_GLUE
(
    .i_decoder(decoder_output),
    .i_regfile(regfile_output),

    .o_act_pass(d_act_pass),
    .o_alu_input(d_alu_input),
    .o_d_cache_input(d_d_cache_input),
    .o_branch_feedback_ifc(d_branch_feedback)
);

d2a_pr D2A_PR
(
    .clk,
    .n_rst,

    .ctrl(d2a_ctrl),

    .i_pr_pass(d_pr_pass),
    .o_pr_pass(a_pr_pass),

    .i_act_pass(d_act_pass),
    .o_act_pass(a_act_pass),

    .i_alu_input(d_alu_input),
    .o_alu_input(a_alu_input),

    .i_d_cache_input(d_d_cache_input),
    .o_d_cache_input(a_d_cache_input),

    .i_branch_feedback(d_branch_feedback),
    .o_branch_feedback(a_branch_feedback)
);

//====================================================================================================
//ACTION
//====================================================================================================
alu ALU
(
    .in(a_alu_input),

    .out(alu_output)
);

d_cache D_CACHE
(
    .clk,
    .n_rst,

    .valid(a_pr_pass.valid),
    .in(a_d_cache_input),

    .out(a_d_cache_output)
);

action_glue ACTION_GLUE
(
    .i_act_pass(a_act_pass),
    .i_alu_output(alu_output),
    .i_d_cache_output(a_d_cache_output.data),

    .o_writeback(a_writeback)
);

a2w_pr A2W_PR
(
    .clk,
    .n_rst,

    .ctrl(a2w_ctrl),

    .i_pr_pass(a_pr_pass),
    .o_pr_pass(w_pr_pass),

    .i_writeback(a_writeback),
    .o_writeback(w_writeback)
);

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//Hazard
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
hazard_controller HAZARD_CONTROLLER
(
    .i_branch_predictor(f_branch_prediction),
    .i_feedback(a_branch_feedback),

    .o_i2d(i2d_ctrl),
    .o_d2a(d2a_ctrl),
    .o_a2w(a2w_ctrl),

    .o_fetch_ctrl(fetch_ctrl)
);
endmodule