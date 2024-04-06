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