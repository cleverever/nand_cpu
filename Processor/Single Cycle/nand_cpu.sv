module nand_cpu
(
    input logic clk,
    input logic n_rst
);

logic [7 : 0] instr;
decoder_output_ifc decoder_output();

regfile_output_ifc reg_data();

alu_input_ifc alu_input();

writeback_ifc writeback();


//FETCH

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

//MEM

writeback_glue_circuit WRITEBACK_GLUE
(
    //TEMP

    .out(writeback)
);

endmodule