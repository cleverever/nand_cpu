`include "nand_cpu.svh"

module fetch_glue
(
    input logic unsigned [`PC_SIZE - 1 : 0] i_pc,
    input logic instr_valid,

    branch_predictor_output_ifc.in i_branch_predictor,

    pr_pass_ifc.out o_pr_pass
);

always_comb begin
    o_pr_pass.valid = instr_valid;
    o_pr_pass.pc = i_pc;
    o_pr_pass.pc_override = i_branch_predictor.pc_override;
    o_pr_pass.target = i_branch_predictor.target;
end
endmodule

module decode_glue
(
    pr_pass_ifc.in i_pr_pass,
    decoder_output_ifc.in i_decoder,
    regfile_output_ifc.in i_regfile,

    forward_data_ifc.in a_forward,
    forward_data_ifc.in w_forward,
    pr_pass_ifc.out o_pr_pass,
    act_pass_ifc.out o_act_pass,
    alu_input_ifc.out o_alu_input,
    d_cache_input_ifc.out o_d_cache_input,
    branch_feedback_ifc.out o_branch_feedback
);

logic [15 : 0] ra_data;
logic [15 : 0] rt_data;
logic ps_data;

always_comb begin
    if(i_decoder.use_ra) begin
        if(a_forward.use_rw & (a_forward.rw_addr == 4'b0000)) begin
            ra_data = a_forward.rw_data;
        end
        else if(w_forward.use_rw & (w_forward.rw_addr == 4'b0000)) begin
            ra_data = w_forward.rw_data;
        end
        else begin
            ra_data = i_regfile.ra;
        end
    end

    if(i_decoder.use_rt) begin
        if(a_forward.use_rw & (a_forward.rw_addr == i_decoder.rt_addr)) begin
            rt_data = a_forward.rw_data;
        end
        else if(w_forward.use_rw & (w_forward.rw_addr == i_decoder.rt_addr)) begin
            rt_data = w_forward.rw_data;
        end
        else begin
            rt_data = i_regfile.rt;
        end
    end

    if(i_decoder.read_ps) begin
        if(a_forward.write_ps) begin
            ps_data = a_forward.ps_data;
        end
        else if(w_forward.write_ps) begin
            ps_data = w_forward.ps_data;
        end
        else begin
            ps_data = i_regfile.ps;
        end
    end

    o_pr_pass.valid = i_pr_pass.valid;
    o_pr_pass.halt = i_decoder.halt;
    o_pr_pass.interrupt = i_decoder.interrupt;
    o_pr_pass.int_code = i_decoder.immdt;
    o_pr_pass.pc = i_pr_pass.pc;
    o_pr_pass.pc_override = i_pr_pass.pc_override;
    o_pr_pass.target = i_pr_pass.target;

    o_act_pass.mem_access = i_decoder.mem_access;
    o_act_pass.reg_write = i_decoder.use_rw & i_pr_pass.valid;
    o_act_pass.reg_addr = i_decoder.rw_addr;
    o_act_pass.ps_write = i_decoder.write_ps;

    o_alu_input.op0 = ra_data;
    o_alu_input.op1 = i_decoder.use_immdt? {10'b0000000000, i_decoder.shift, i_decoder.immdt} : rt_data;
    o_alu_input.alu_op = i_decoder.alu_op;

    o_d_cache_input.mem_access = i_decoder.mem_access;
    o_d_cache_input.address = rt_data;
    o_d_cache_input.mem_op = i_decoder.mem_op;
    o_d_cache_input.data = ra_data;

    o_branch_feedback.branch = i_decoder.branch;
    o_branch_feedback.pc = i_pr_pass.pc;
    o_branch_feedback.predict_target = i_pr_pass.target;
    o_branch_feedback.feedback_target = rt_data;
    o_branch_feedback.predict_taken = i_pr_pass.pc_override;
    o_branch_feedback.feedback_taken = i_decoder.jump | (i_decoder.branch & ps_data);
end
endmodule

module action_glue
(
    act_pass_ifc.in i_act_pass,
    input logic [15 : 0] i_alu_output,
    input logic [15 : 0] i_d_cache_output,

    forward_data_ifc.out o_forward,
    writeback_ifc.out o_writeback
);

always_comb begin
    o_forward.use_rw = i_act_pass.reg_write;
    o_forward.rw_addr = i_act_pass.reg_addr;
    o_forward.rw_data = i_act_pass.mem_access? i_d_cache_output : i_alu_output;
    o_forward.write_ps = i_act_pass.ps_write;
    o_forward.ps_data = i_alu_output[0];

    o_writeback.reg_write = i_act_pass.reg_write;
    o_writeback.reg_addr = i_act_pass.reg_addr;
    o_writeback.reg_data = i_act_pass.mem_access? i_d_cache_output : i_alu_output;
    o_writeback.ps_write = i_act_pass.ps_write;
    o_writeback.ps_data = i_alu_output[0];
end
endmodule