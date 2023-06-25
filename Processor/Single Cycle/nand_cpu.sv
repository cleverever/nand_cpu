module nand_cpu
(
    input logic clk,
    input logic n_rst
);
branch_controller_ifc branch_controller();

logic unsigned [`PC_SIZE - 1 : 0] pc;

logic [7 : 0] instr;
decoder_output_ifc decoder_output();

regfile_output_ifc reg_data();

alu_input_ifc alu_input();

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

    .i_branch_controller(branch_controller),
    .i_decoder(decoder_output),

    .pc(pc)
);

i_mem I_MEM
(
    .pc(pc),

    .instr(instr),
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

    .result()
);

d_mem D_MEM
(
    //TEMP
);

writeback_glue_circuit WRITEBACK_GLUE
(
    //TEMP

    .out(writeback)
);

endmodule