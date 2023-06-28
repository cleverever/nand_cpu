`include "nand_cpu.svh"

module i_cache
(
    input logic unsigned [`PC_SIZE - 1 : 0] pc,

    output logic [7 : 0] instr
);

logic [7 : 0] core [(2 ** `PC_SIZE) - 1 : 0];

always_comb begin
    instr = core[pc];
end
endmodule