`include "nand_cpu.svh"

//DECODE
module decode_glue
(
    input logic valid,

    decoder_ifc.in decoder_in,
    input logic pc,
    branch_predictor_output_ifc.in branch_prediction,
    translation_table_ifc.other tt,
    free_reg_list_ifc.other frl,
    input logic [$clog2(`ROB_LENGTH)-1:0] rob_addr,

    decode_hazard.out hazard,

    branch_valid_ifc.out bv,

    execution_buffer_ifc.out eb_out,
    branch_buffer_ifc.out bb_out,
    memory_buffer_ifc.out mb_out
);

always_comb begin
    tt.v_ra_addr = decoder_in.ra_addr;
    tt.v_rt_addr = decoder_in.rt_addr;
    tt.v_rw_addr = decoder_in.rw_addr;

    hazard.mispredict = branch_taken & (decoder_in.pipeline != BR);
    hazard.recovery_pc = pc + 1;

    bv.valid = valid;
    bv.pc = pc;
    bv.branch = decoder_in.branch | decoder_in.jump;

    eb_out.valid = decoder_in.pipeline == EX;
    eb_out.rob_addr = rob_addr;
    eb_out.alu_op = decoder_in.alu_op;
    eb_out.immdt = decoder_in.immdt;
    eb_out.ra_addr = tt.p_ra_addr;
    eb_out.use_rt = decoder_in.use_rt;
    eb_out.rt_addr = tt.p_rt_addr;
    eb_out.write_dst = decoder_in.use_rs;
    eb_out.rw_addr = frl.rw_addr;
    eb_out.prev_rw_addr = tt.p_rw_addr;
    eb_out.rs_addr = frl.rs_addr;
    eb_out.prev_rs_addr = tt.p_rs_addr;

    bb_out.valid = decoder_in.pipeline == BR;

    mb_out.valid = decoder_in.pipeline == MEM;
end
endmodule

//BRANCH
module b_read_glue
(
    branch_buffer_ifc.in bb_in,

    metadata_ifc.out metadata,
    rf_dst_ifc.out rf_dst,

    regfile_d_read_ifc.read rt,
    regfile_d_read_ifc.read rs,

    branch_outcome_ifc.out branch_outcome

    branch_hazard.out hazard,
    branch_recovery.out recovery
);

always_comb begin
    rf_port.rt_addr = bb_in.rt_addr;
    rf_port.rs_addr = bb_in.rs_addr;

    branch_outcome.valid = bb_in.valid;
    branch_outcome.pc = bb_in.pc;
    branch_outcome.taken = rf_port.rs_data;
    if(`PC_SIZE > 16) begin
        branch_outcome.target = bb_in.jump? {bb_in.pc[`PC_SIZE-1:16], rf_port.rt_data} : (bb_in.pc + rf_port.rt_data);
    end
    else begin
        branch_outcome.target = bb_in.jump? rf_port.rt_data[`PC_SIZE-1:0] : (bb_in.pc + rf_port.rt_data);
    end

    hazard.mispredict = (bb_in.predict_taken != rf_port.rs_data) | (bb_in.predict_target != branch_outcome.target);
    hazard.recovery_pc = rf_port.rs_data? branch_outcome.target : (bb_in.pc + 1);

    recovery.frl_r_free_list_cp = bb_in.r_free_list_cp;
    recovery.frl_s_free_list_cp = bb_in.s_free_list_cp;
    recovery.tt_d_translation_cp = bb_in.d_translation_cp;
    recovery.tt_s_translation_cp = bb_in.s_translation_cp;
    recovery.rob_tail_cp = (metadata.rob_addr + (`ROB_LENGTH - 1)) % `ROB_LENGTH;
end
endmodule

//EXECUTE
interface ex_rf_dst_ifc;
logic write_dst;
logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
logic [$clog2(`NUM_S_REG)-1:0] rs_addr;

modport in
(
    input write_dst, rw_addr, rs_addr
);
modport out
(
    output write_dst, rw_addr, rs_addr
);
endinterface

module e_read_glue
(
    execution_buffer_port.in eb,
    regfile_d_read_ifc.read ra,
    regfile_d_read_ifc.read rt,

    metadata_ifc.out metadata,
    ex_rf_dst_ifc.out rf_dst,
    alu_input_ifc.out alu_input
);

always_comb begin
    ra.addr = eb.ra_addr;
    rt.addr = eb.rt_addr;

    metadata.valid = eb.valid;
    metadata.rob_addr = eb.rob_addr;

    rf_dst.write_dst = (eb.alu_op == ALU_EQ) | (eb.alu_op == ALU_NE);
    rf_dst.rw_addr = eb.rw_addr;
    rf_dst.rs_addr = eb.rs_addr;

    alu_input.op0 = ra.data;
    alu_input.op1 = eb.use_rt? rt.data : eb.immdt;
    alu_input.alu_op = eb.alu_op;
end
endmodule

module e_commit_glue
(
    input logic [15:0] alu_result,
    ex_rf_dst_ifc.in rf_dst,

    regfile_d_write_ifc.write ex_d_write,
    regfile_s_write_ifc.write ex_s_write
);

always_comb begin
    ex_d_write.valid = ~rf_dst.write_dst;
    ex_d_write.data = alu_result;
    ex_d_write.addr = rw_addr;

    ex_s_write.valid = rf_dst.write_dst;
    ex_s_write.data = alu_result[0];
    ex_s_write.addr = rs_addr;
end

endmodule

//MEMORY
module m_read_glue
(
    memory_buffer_port.in mb,
    regfile_d_read_ifc.read ra,
    regfile_d_read_ifc.read rt,

    metadata_ifc.out metadata,
    d_cache_input_ifc.out cache_input,
    output logic [$clog2(`NUM_D_REG)-1:0] rw_addr
);

always_comb begin
    ra.addr = mb.raw_addr;
    rt.addr = mb.rt_addr;

    metadata.valid = mb.valid;
    metadata.rob_addr = mb.rob_addr;

    cache_input.mem_op = mb.mem_op;
    cache_input.address = rt.data;
    cache_input.data = ra.data;

    rw_addr = raw_addr;
end
endmodule

module m_commit_glue
(
    metadata_ifc.out metadata,
    nand_cpu_pkg::MemOp mem_op,
    d_cache_output_ifc.in cache_output,
    input logic [15:0] rw_addr,

    regfile_d_write_ifc.out m_a_d_write
);

always_comb begin
    m_a_d_write.valid = metadata.valid & (mem_op == MEM_READ);
    m_a_d_write.data = cache_output.data;
    m_a_d_write.addr = rw_addr;
end
endmodule