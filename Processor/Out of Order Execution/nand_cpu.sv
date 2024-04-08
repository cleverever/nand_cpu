`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

//==================================================
//FETCH
//==================================================
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

branch_predictor BRANCH_PREDICTOR
(
    .clk,
    .n_rst,
    
    .pc(pc),

    .use_ps(predictor_use_ps),
    .ps(d_regfile_output.ps),
    
    .out(f_branch_prediction),

    .feedback_valid(a_pr_pass.valid & (a_branch_feedback.branch | a_branch_feedback.jump)),
    .i_feedback(a_branch_feedback)
);

i2d I2D
(
    .valid(d_valid)
);

logic d_valid;

//==================================================
//DECODE/RENAME
//==================================================
decoder DECODER
(
    .instr(d_instr),
    
    .out(d_decoder_output)
);

free_reg_list FRL
(
    .clk,
    .n_rst,

    .valid(d_valid),
    .decoder_in(d_decoder_output),

    .commit(commit),
    .frl_out(frl_out),

    .stall()
);

free_reg_list_ifc frl_out();

translation_table TT
(
    .clk,
    .n_rst,

    .valid(d_valid),
    .decoder_in(d_decoder_output),
    .frl_in(frl_out),

    .port(tt_port)
);

translation_table_ifc tt_port();

decode_glue DECODE_GLUE
(
    .valid(d_valid),
    .decoder_in(d_decoder_output),
    .tt(tt_port),
    .frl(frl_out),
    .rob_addr(rob_addr),

    .eb_out(d_eb)
);

execution_buffer_ifc d_eb();

//==================================================
//REGFILE
//==================================================
regfile RF
(
    .ex_read_request(ex_rf_read),

    .ex_d_write_request(ex_d_write),
    .ex_s_write_request(ex_s_write)
);

//==================================================
//EXECUTION
//==================================================
execution_buffer EB
(
    .clk,
    .n_rst,
    
    .in(d_eb),
    .out(r_eb)
);

execution_buffer_ifc r_eb();
regfile_ex_ifc ex_rf_read();

e_read_glue E_READ_GLUE
(
    .eb_in(r_eb),

    .rf_port(ex_rf_read),

    .metadata(e_r_metadata),
    .rf_dst(e_r_rf_dst),
    .alu_input(r_alu_input)
);

metadata_ifc e_r_metadata();
rf_dst_ifc e_r_rf_dst();
alu_input_ifc r_alu_input();

e_r2a E_R2A
(
    .md_in(e_r_metadata),
    .rf_dst_in(e_r_rf_dst),
    .alu_input_in(r_alu_input),

    .md_out(e_a_metadata),
    .rf_dst_out(e_a_rf_dst),
    .alu_input_out(a_alu_input)
);

metadata_ifc e_a_metadata();
rf_dst_ifc e_a_rf_dst();
alu_input_ifc a_alu_input();

alu ALU
(
    .in(a_alu_input),
    .out(alu_output)
);

logic [15:0] alu_output;

e_alu_glue E_ALU_GLUE
(
    .alu_result(alu_output),

    .ex_d_write(e_a_d_write),
    .ex_s_write(e_a_s_write)
);

regfile_d_write_ifc e_a_d_write();
regfile_s_write_ifc e_a_s_write();

e_a2c E_A2C
(
    .md_in(e_a_metadata),
    .e_a_d_write(e_a_d_write),
    .e_a_s_write(e_a_s_write),

    .md_out(e_c_metadata),
    .e_c_d_write(ex_d_write),
    .e_c_s_write(ex_s_write)
);

metadata_ifc e_c_metadata();
regfile_d_write_ifc ex_d_write();
regfile_s_write_ifc ex_s_write();

//==================================================
//MEMORY
//==================================================

//==================================================
//COMMIT
//==================================================
reorder_buffer ROB
(
    .clk,
    .n_rst,

    .push(d_valid),
    .decoder_in(d_decoder_output),
    .tt_in(tt_port),

    .commit(commit),

    .stall(),
    .rob_open_slot(rob_addr)
);

reorder_buffer_ifc commit();
logic [$clog2(`ROB_SIZE)-1:0] rob_addr;

endmodule