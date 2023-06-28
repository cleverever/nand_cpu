`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

writeback_ifc m_writeback();

writeback_ifc w_writeback();

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

i_mem I_MEM
(
    .pc(pc),

    .instr(instr)
);

i2d_pr I2D_PR
(

);

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

d2e_pr D2E_PR
(

);

alu ALU
(
    .in(alu_input),

    .result(alu_data)
);

e2m_pr E2M_PR
(

);

d_mem D_MEM
(
    .clk,
    .n_rst,

    .i_decoder(decoder_output),
    .i_regfile(reg_data),

    .data(mem_data)
);

writeback_glue WRITEBACK_GLUE
(
    //TEMP
    .out(m_writeback)
);

m2w_pr M2W_PR
(
    .clk,
    .n_rst,

    .in(m_writeback),
    .out(w_writeback)
);
endmodule