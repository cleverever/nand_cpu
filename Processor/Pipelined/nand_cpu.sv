`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

d_cache_ifc d_cache_output();
writeback_ifc m_writeback();

writeback_ifc w_writeback();

//FETCH
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

    .instr(instr)
);

i2d_pr I2D_PR
(

);

//DECODE
decoder DECODER
(
    .valid(~halt),
    .instr(instr),
    
    .out(decoder_output)
);

regfile REGFILE
(
    .clk,
    .n_rst,

    .i_writeback(w_writeback),
    .i_reg_read(decoder_output),

    .out(reg_data)
);

d2a_pr D2A_PR
(

);

//ACTION
alu ALU
(
    .in(alu_input),

    .result(alu_data)
);

d_cache D_CACHE
(
    .clk,
    .n_rst,

    .i_decoder(decoder_output),
    .i_regfile(reg_data),

    .out(d_cache_output)
);

writeback_glue WRITEBACK_GLUE
(
    //TEMP

    .out(m_writeback)
);

a2w_pr A2W_PR
(
    .clk,
    .n_rst,

    .in(m_writeback),
    .out(w_writeback)
);
endmodule