`include "nand_cpu.svh"

module fetch_glue
(
    logic unsigned [`PC_SIZE - 1 : 0] i_pc,

    pr_pass_ifc.out o_pr_pass
);

always_comb begin
    o_pr_pass.valid = 1'b1;
    o_pr_pass.pc = i_pc;
end
endmodule

module decode_glue
(
    pr_pass_ifc.in i_pr_pass,
    decoder_output_ifc.in i_decoder,
    regfile_output_ifc.in i_regfile,

    act_pass_ifc.out o_act_pass,
    alu_input_ifc.out o_alu_input,
    d_cache_input_ifc.out o_d_cache_input,
    branch_feedback_ifc.out o_branch_feedback
);

always_comb begin
    o_act_pass.mem_access <= i_decoder.mem_access;
    o_act_pass.reg_write <= i_decoder.use_rw;
    o_act_pass.reg_addr <= i_decoder.rw_addr;
    o_act_pass.ps_write <= i_decoder.write_ps;

    o_alu_input.op0 = i_regfile.ra;
    o_alu_input.op1 = i_decoder.use_immdt? {10'b0000000000, i_decoder.shift, i_decoder.immdt} : i_regfile.rt;
    o_alu_input.alu_op = i_decoder.alu_op;

    o_d_cache_input.valid = i_decoder.mem_access;
    o_d_cache_input.address = i_regfile.rt;
    o_d_cache_input.mem_op = i_decoder.mem_op;
    o_d_cache_input.data = i_regfile.ra;

    o_branch_feedback.valid = i_pr_pass.valid & (i_decoder.branch | i_decoder.jump);
    o_branch_feedback.branch = i_decoder.branch;
    o_branch_feedback.pc = i_pr_pass.pc;
    o_branch_feedback.predict_target = TEMP;
    o_branch_feedback.feedback_target = i_regfile.rt;
    o_branch_feedback.predict_taken = TEMP;
    o_branch_feedback.feedback_taken = i_regfile.ps;
end
endmodule

module action_glue
(
    act_pass_ifc.in i_act_pass,
    logic [15 : 0] i_alu_output,
    logic [15 : 0] i_d_cache_output,

    writeback_ifc.out o_writeback
);

always_comb begin
    o_writeback.valid = i_act_pass.valid;
    o_writeback.reg_write = i_act_pass.reg_write;
    o_writeback.reg_addr = i_act_pass.reg_addr;
    o_writeback.reg_data = i_act_pass.mem_access? i_d_cache_output : i_alu_output;
    o_writeback.ps_write = i_act_pass.ps_write;
    o_writeback.ps_data = i_alu_output[0];
end
endmodule