`include "nand_cpu.svh"

interface decode_glue_ifc;
logic use_ra;
logic [$clog2(`NUM_D_REG)-1 : 0] ra_addr

logic use_rt;
logic [$clog2(`NUM_D_REG)-1 : 0] rt_addr;

logic use_rw;
logic [$clog2(`NUM_D_REG)-1 : 0] rw_addr;

logic uses_rs;
logic [$clog2(`NUM_S_REG)-1 : 0] rs_addr;

logic use_immdt;
logic [3 : 0] immdt;
logic [5 : 4] shift;

logic mem_access;
nand_cpu_pkg::MemOp mem_op;

logic jump;
logic branch;

logic interrupt;
logic halt;

nand_cpu_pkg::AluOp alu_op;

modport in
(
    input use_ra, ra_addr, use_rt, rt_addr, use_rw, rw_addr, use_rs, rs_addr,
    use_immdt, immdt, shift, mem_access, mem_op, jump, branch, interrupt, halt, alu_op
);
modport out
(
    output use_ra, ra_addr, use_rt, rt_addr, use_rw, rw_addr, use_rs, rs_addr,
    use_immdt, immdt, shift, mem_access, mem_op, jump, branch, interrupt, halt, alu_op
);
endinterface

module decode_glue
(
    decoder_ifc.other dec,
    translation_table_ifc.other tt,
    free_reg_list_ifc.other rfl,

    decode_glue_ifc.out out
);

always_comb begin
    out.use_ra = dec.use_ra;
    out.ra_addr = tt.d_translation[0];

    out.use_rt = dec.use_rt;
    out.rt_addr = tt.d_translation[d.rt_addr];

    out.use_rw = dec.use_rw;
    out.rw_addr = frl.r_out;

    out.uses_rs = dec.use_rs;
    out.rs_addr = frl.s_out;

    out.use_immdt = dec.use_immdt;
    out.immdt = dec.immdt;
    out.shift = dec.shift;

    out.mem_access = dec.mem_access;
    out.mem_op = dec.mem_op;

    out.jump = dec.jump;
    out.branch = dec.branch;

    out.interrupt = dec.interrupt;
    out.halt = dec.halt;


    tt.d_set = d.use_rw;
    tt.d_v_reg = d.rw_addr;
    tt.d_p_reg = frl.out;

    frl.checkout = d.use_rw;
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