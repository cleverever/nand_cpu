`include "nand_cpu.svh"

module fetch_glue
(
    pr_pass_ifc.out o_pr_pass
);

always_comb begin
    
end
endmodule

module decode_glue
(
    decoder_output_ifc.in i_decoder,
    regfile_output_ifc.in i_regfile

    alu_input_ifc.out o_alu_input
);

always_comb begin
    o_alu_input.op0 = i_regfile.ra;
    o_alu_input.op1 = i_decoder.use_immdt? {10'b0000000000, i_decoder.shift, i_decoder.immdt} : i_regfile.rt;
    o_alu_input.alu_op = i_decoder.alu_op;
end
endmodule

module action_glue
(
    act_pass_ifc.in i_act_pass,

    writeback_ifc.out o_writeback
);

always_comb begin
    o_writeback.valid = i_act_pass.valid;
    o_writeback.reg_write = i_act_pass.reg_write;
    o_writeback.reg_addr = i_act_pass.reg_addr;
    o_writeback.reg_data = TEMP;
    o_writeback.ps_write = i_act_pass.ps_write;
    o_writeback.ps_data = i_act_pass.ps_data;
end
endmodule