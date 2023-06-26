`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

branch_controller_ifc branch_controller();

logic unsigned [`PC_SIZE - 1 : 0] pc;

logic [7 : 0] instr;
decoder_output_ifc decoder_output();

regfile_output_ifc reg_data();

alu_input_ifc alu_input();

logic [15 : 0] alu_data;
logic [15 : 0] mem_data;

writeback_ifc writeback();

branch_controller BRANCH_CONTROLLER
(
    .i_decoder(decoder_output),
    .i_regfile(reg_data),

    .out(branch_controller)
);

fetch_unit FETCH_UNIT
(
    .clk(clk),
    .n_rst(n_rst),

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

decoder DECODER
(
    .instr(instr),
    .out(decoder_output)
);

regfile REGFILE
(
    .clk(clk),
    .n_rst(n_rst),

    .i_writeback(writeback),
    .i_reg_read(decoder_output),

    .out(reg_data)
);

alu_glue_circuit ALU_GLUE
(
    .i_decoder(decoder_output),
    .i_regfile(reg_data),

    .out(alu_input)
);

alu ALU
(
    .in(alu_input),

    .result(alu_data)
);

d_mem D_MEM
(
    .clk(clk),
    .n_rst(n_rst),

    .i_decoder(decoder_output),
    .i_regfile(reg_data),

    .data(mem_data)
);

writeback_glue_circuit WRITEBACK_GLUE
(
    .alu_data(alu_data),
    .mem_data(mem_data),

    .decoder_output_ifc(decoder_output),

    .out(writeback)
);
endmodule