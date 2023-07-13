`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

logic [`PC_SIZE - 1 : 0] pc;
i_cache_output_ifc f_i_cache_output();
i_cache_request_ifc f_i_cache_request();
branch_predictor_output_ifc f_branch_prediction();
logic predictor_use_ps;
pr_pass_ifc f_pr_pass();

pipeline_ctrl_ifc i2d_ctrl();

logic [7 : 0] d_instr;
decoder_output_ifc d_decoder_output();
regfile_output_ifc d_regfile_output();
alu_input_ifc d_alu_input();
d_cache_input_ifc d_d_cache_input();
branch_feedback_ifc d_branch_feedback();
act_pass_ifc d_act_pass();
pr_pass_ifc d_pr_pass();
pr_pass_ifc d2_pr_pass();

pipeline_ctrl_ifc d2a_ctrl();

alu_input_ifc a_alu_input();
logic [15 : 0] alu_output;
d_cache_input_ifc a_d_cache_input();
d_cache_output_ifc a_d_cache_output();
d_cache_request_ifc a_d_cache_request();
branch_feedback_ifc a_branch_feedback();
forward_data_ifc a_forward();
writeback_ifc a_writeback();
act_pass_ifc a_act_pass();
pr_pass_ifc a_pr_pass();

pipeline_ctrl_ifc a2w_ctrl();

forward_data_ifc w_forward();
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
    .clk,
    .n_rst,

    .pc(pc),

    .out(f_i_cache_output),

    .cache_request(f_i_cache_request)
);

branch_predictor branch_predictor
(
    .clk,
    .n_rst,
    
    .pc(pc),

    .use_ps(predictor_use_ps),
    .ps(d_regfile_output.ps),
    
    .out(f_branch_prediction),

    .feedback_valid(a_pr_pass.valid),
    .i_feedback(a_branch_feedback)
);

fetch_glue FETCH_GLUE
(
    .i_pc(pc),
    .instr_valid(~(fetch_ctrl.stall | halt)),

    .i_branch_predictor(f_branch_prediction),

    .o_pr_pass(f_pr_pass)
);

i2d_pr I2D_PR
(
    .clk,
    .n_rst,

    .ctrl(i2d_ctrl),

    .i_pr_pass(f_pr_pass),
    .o_pr_pass(d_pr_pass),

    .i_instr(f_i_cache_output.data),
    .o_instr(d_instr)
);

//====================================================================================================
//DECODE
//====================================================================================================
decoder DECODER
(
    .instr(d_instr),
    
    .out(d_decoder_output)
);

regfile REGFILE
(
    .clk,
    .n_rst,

    .writeback_valid(w_pr_pass.valid),
    .i_writeback(w_writeback),

    .reg_read_valid(d_pr_pass.valid),
    .i_reg_read(d_decoder_output),

    .i_bp_ps(predictor_use_ps),
    
    .out(d_regfile_output)
);

decode_glue DECODE_GLUE
(
    .i_pr_pass(d_pr_pass),
    .i_decoder(d_decoder_output),
    .i_regfile(d_regfile_output),

    .a_forward(a_forward),
    .w_forward(w_forward),
    .o_pr_pass(d2_pr_pass),
    .o_act_pass(d_act_pass),
    .o_alu_input(d_alu_input),
    .o_d_cache_input(d_d_cache_input),
    .o_branch_feedback(d_branch_feedback)
);

d2a_pr D2A_PR
(
    .clk,
    .n_rst,

    .ctrl(d2a_ctrl),

    .i_pr_pass(d2_pr_pass),
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

    .out(a_d_cache_output),

    .cache_request(a_d_cache_request)
);

action_glue ACTION_GLUE
(
    .i_act_pass(a_act_pass),
    .i_alu_output(alu_output),
    .i_d_cache_output(a_d_cache_output.data),

    .o_forward(a_forward),
    .o_writeback(a_writeback)
);

a2w_pr A2W_PR
(
    .clk,
    .n_rst,

    .ctrl(a2w_ctrl),

    .i_pr_pass(a_pr_pass),
    .o_pr_pass(w_pr_pass),

    .i_forward(a_forward),
    .o_forward(w_forward),

    .i_writeback(a_writeback),
    .o_writeback(w_writeback)
);

//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//Memory
//WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
memory MEMORY
(
    .clk,

    .r_i_cache(f_i_cache_request),
    .r_d_cache(a_d_cache_request)
);

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//Hazard
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
hazard_controller HAZARD_CONTROLLER
(
    .i_branch_predictor(f_branch_prediction),
    .i_feedback(a_branch_feedback),

    .i_cache_miss(~f_i_cache_output.hit),
    .d_cache_miss(a_d_cache_output.miss),

    .i_i2d(d_pr_pass),
    .i_d2a(a_pr_pass),
    .i_a2w(w_pr_pass),

    .o_i2d(i2d_ctrl),
    .o_d2a(d2a_ctrl),
    .o_a2w(a2w_ctrl),

    .o_fetch_ctrl(fetch_ctrl)
);
endmodule