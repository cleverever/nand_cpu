`include "nand_cpu.svh"

module decode_glue
(
    input logic valid,
    decoder_ifc.in decoder_in,
    translation_table_ifc.other tt,
    free_reg_list_ifc.other frl,
    input logic [$clog2(`ROB_SIZE)-1:0] rob_addr,

    execution_buffer_ifc.out eb_out
);

always_comb begin
    tt.v_ra_addr = decoder_in.ra_addr;
    tt.v_rt_addr = decoder_in.rt_addr;
    tt.v_rw_addr = decoder_in.rw_addr;

    eb_out.valid = valid;
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
end
endmodule

interface rf_dst_ifc;
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
    execution_buffer_port.in eb_in,

    metadata_ifc.out metadata,
    rf_dst_ifc.out rf_dst,

    regfile_ex_ifc.ex rf_port,
    alu_input_ifc.out alu_input
);

always_comb begin
    metadata.valid = eb_in.valid;
    metadata.rob_addr = eb.rob_addr;

    rf_dst.write_dst = (eb_in.alu_op == ALU_EQ) | (eb_in.alu_op == ALU_NE);
    rf_dst.rw_addr = eb_in.rw_addr;
    rf_dst.rs_addr = eb_in.rs_addr;

    rf_port.ra_addr = eb_in.ra_addr;
    rf_port.rt_addr = eb_in.rt_addr;

    alu_input.op0 = rf_port.ra_data;
    alu_input.op1 = eb_in.use_rt? rf_port.rt_data : eb_in.immdt;
    alu_input.alu_op = eb_in.alu_op;
end
endmodule

module e_alu_glue
(
    input logic [15:0] alu_result,


    regfile_d_write_ifc.write ex_d_write,
    regfile_s_write_ifc.write ex_s_write
);


endmodule