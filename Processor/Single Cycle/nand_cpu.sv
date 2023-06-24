module nand_cpu
(
    input logic clk,
    input logic n_rst
);

logic [7 : 0] instr;
decoded_instr decoder_output();

regfile_output_ifc reg_data();
regfile_read_ifc read_request();
regfile_write_ifc write_request();


//FETCH

decoder DECODER
(
    .instr(instr),
    .out(decoder_output)
);

alu_glue_circuit REGFILE_GLUE
(

);

regfile REGFILE
(
    .clk(clk),
    .n_rst(n_rst),

    .i_reg_write(write_request),

    .i_reg_read(read_request),
    .out(reg_data)
);

alu_glue_circuit ALU_GLUE
(

);


endmodule