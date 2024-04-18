`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

//FETCH
logic [`PC_SIZE-1:0] pc;

//DECODE/RENAME
free_reg_list_ifc frl_out();
translation_table_ifc tt_port();
execution_buffer_ifc d_eb();
logic d_valid;

//BRANCH

//EXECUTE
//read
execution_buffer_ifc r_eb();
regfile_ex_ifc ex_rf_read();
metadata_ifc e_r_metadata();
rf_dst_ifc e_r_rf_dst();
alu_input_ifc r_alu_input();
metadata_ifc e_a_metadata();
rf_dst_ifc e_a_rf_dst();
//alu
logic [15:0] alu_output;
alu_input_ifc a_alu_input();
regfile_d_write_ifc e_a_d_write();
regfile_s_write_ifc e_a_s_write();
//write
metadata_ifc e_c_metadata();
regfile_d_write_ifc ex_d_write();
regfile_s_write_ifc ex_s_write();

//MEMORY

//COMMIT
reorder_buffer_ifc commit();
logic [$clog2(`ROB_SIZE)-1:0] rob_addr;

//HAZARD

//==================================================
//BRANCH
//==================================================



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

    .out(),

    .branch_valid_in(),
    .branch_outcome_in()
);

i2d I2D
(
    .pc(),
    .branch(d_branch_taken),
    .valid(d_valid)
);

logic d_branch_taken;

//====================================================================================================
// DECODE/RENAME
//====================================================================================================
// Decodes instructions and maps logical registers to physical registers. Will stall if reorder buffer
// or functional unit buffers are full.
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

translation_table TT
(
    .clk,
    .n_rst,

    .valid(d_valid),
    .decoder_in(d_decoder_output),
    .frl_in(frl_out),

    .port(tt_port)
);

decode_glue DECODE_GLUE
(
    .valid(d_valid),
    .pc(),
    .branch_taken(),
    .decoder_in(d_decoder_output),
    .tt(tt_port),
    .frl(frl_out),
    .rob_addr(rob_addr),

    .flush(),

    .hazard(),

    .bv(),

    .eb_out(d_eb),
    .bb_out()
);

//====================================================================================================
// REGFILE
//====================================================================================================
regfile RF
(
    .ex_read_request(ex_f_rf_read),

    .ex_d_write_request(ex_d_write),
    .ex_s_write_request(ex_s_write)
);

forward_unit FU
(
    .clk,
    .n_rst,

    .reg_req_in(ex_rf_read),
    .reg_req_out(ex_f_rf_read),

    .e_a_dfw(),
    .e_a_sfw(),

    .e_c_dfw(),
    .e_c_sfw(),

    .rob_in(),

    .r_calculated_list(),
    .s_calculated_list()
);

//====================================================================================================
// BRANCH
//====================================================================================================
// Verifies branch predictions and sends hazard signals on incorrect predictions. Will never stall.
branch_buffer BB
(

);

branch_glue B_READ_GLUE
(

);

//====================================================================================================
// EXECUTION
//====================================================================================================
// Handles register manipulation operations. Will never stall.
execution_buffer EB
(
    .clk,
    .n_rst,

    .r_calculated_list(),

    .in(d_eb),
    .out(r_eb)
);

e_read_glue E_READ_GLUE
(
    .eb_in(r_eb),

    .rf_port(ex_rf_read),

    .metadata(e_r_metadata),
    .rf_dst(e_r_rf_dst),
    .alu_input(r_alu_input)
);

e_r2a E_R2A
(
    .md_in(e_r_metadata),
    .rf_dst_in(e_r_rf_dst),
    .alu_input_in(r_alu_input),

    .md_out(e_a_metadata),
    .rf_dst_out(e_a_rf_dst),
    .alu_input_out(a_alu_input)
);

alu ALU
(
    .in(a_alu_input),
    .out(alu_output)
);

e_alu_glue E_ALU_GLUE
(
    .alu_result(alu_output),

    .ex_d_write(e_a_d_write),
    .ex_s_write(e_a_s_write)
);

e_a2c E_A2C
(
    .md_in(e_a_metadata),
    .e_a_d_write(e_a_d_write),
    .e_a_s_write(e_a_s_write),

    .md_out(e_c_metadata),
    .e_c_d_write(ex_d_write),
    .e_c_s_write(ex_s_write)
);

//====================================================================================================
// MEMORY
//====================================================================================================

//====================================================================================================
// COMMIT
//====================================================================================================
// Finalizes changes to the system by releasing inaccessible registers
reorder_buffer ROB
(
    .clk,
    .n_rst,

    .push(d_valid),
    .decoder_in(d_decoder_output),
    .tt_in(tt_port),

    .commit(commit),

    .ex_md(e_c_metadata),

    .stall(),
    .rob_open_slot(rob_addr)
);

//====================================================================================================
// HAZARD
//====================================================================================================
hazard_controller HC
(
    
);
endmodule