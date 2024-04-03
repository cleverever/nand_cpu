`include "nand_cpu.svh"

module nand_cpu
(

);

logic reg_write;
logic [$clog2(`NUM_REG)-1 : 0] w_addr;

logic p_reg;

logic reg_commit;
logic [$clog2(`NUM_REG)-1 : 0] commit_addr;

free_reg_list FRL
(
    .clk,
    .n_rst,

    .checkin(reg_commit),
    .in(commit_addr),

    .checkout(reg_write),
    .out(p_reg)
);

translation_table TT
(
    .clk,
    .n_rst,

    .set(reg_write),
    .v_reg(w_addr),
    .p_reg(p_reg)
);

commit_unit CU
(
    .reg_write(reg_commit),
    .reg_addr(commit_addr)
);

endmodule