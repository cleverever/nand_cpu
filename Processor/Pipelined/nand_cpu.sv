`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

logic [7 : 0] f_instr;
pr_pass_ifc f_pr_pass();

logic [7 : 0] d_instr;
alu_input_ifc d_alu_input();
d_alu_input_ifc d_d_cache_input();
act_pass_ifc d_act_pass();
pr_pass_ifc d_pr_pass();

alu_input_ifc a_alu_input();
d_alu_input_ifc a_d_cache_input();
d_cache_ifc d_cache_output();
writeback_ifc a_writeback();
act_pass_ifc a_act_pass();
pr_pass_ifc a_pr_pass();

writeback_ifc w_writeback();
pr_pass_ifc w_pr_pass();

//====================================================================================================
//FETCH
//====================================================================================================
fetch_unit FETCH_UNIT
(
    .clk,
    .n_rst,

    .interrupt_handler(),

    .i_branch_controller(branch_controller),
    .i_decoder(decoder_output),

    .pc(pc),
    .halted(halt)
);

i_cache I_CACHE
(
    .pc(pc),

    .instr(f_instr)
);

branch_target_buffer BRANCH_TARGET_BUFFER
(
    
);

fetch_glue FETCH_GLUE
(
    .i_pc(pc),

    .o_pr_pass(f_pr_pass)
);

i2d_pr I2D_PR
(
    .clk,
    .n_rst,

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
    .o_d_cache_input(d_d_cache_input)
);

d2a_pr D2A_PR
(
    .clk,
    .n_rst,

    .i_pr_pass(d_pr_pass),
    .o_pr_pass(a_pr_pass),

    .i_act_pass(d_act_pass),
    .o_act_pass(a_act_pass),

    .i_alu_input(d_alu_input),
    .o_alu_input(a_alu_input),

    .i_d_cache_input(d_d_cache_input),
    .o_d_cache_input(a_d_cache_input)
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

    .out(d_cache_output)
);

action_glue ACTION_GLUE
(
    .i_act_pass(a_act_pass),
    .i_alu_output(alu_output),
    .i_d_cache_output(d_cache_output.data),

    .o_writeback(a_writeback)
);

a2w_pr A2W_PR
(
    .clk,
    .n_rst,

    .i_pr_pass(a_pr_pass),
    .o_pr_pass(w_pr_pass)

    .i_writeback(a_writeback),
    .o_writeback(w_writeback)
);

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//Hazard
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
hazard_controller HAZARD_CONTROLLER
(

);

branch_controller BRANCH_CONTROLLER
(
    .clk,
    .n_rst,
);
endmodule