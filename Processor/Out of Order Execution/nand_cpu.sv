`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst
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

logic [$clog2(`NUM_REG)-1 : 0] translation [16];

translation_table TT
(
    .clk,
    .n_rst,

    .set(reg_write),
    .v_reg(w_addr),
    .p_reg(p_reg),

    .translation(translation)
);

decoder DECODER
(
    .instr(),
    .translation(),
    .p_reg(),
    
    .out()
);

commit_unit CU
(
    .reg_write(reg_commit),
    .reg_addr(commit_addr)
);

endmodule