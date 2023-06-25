module i_mem
(
    input logic unsigned [`PC_SIZE - 1 : 0] pc,

    output logic [7 : 0] instr
);

logic [(2 ** `PC_SIZE) - 1 : 0] [7 : 0] core;

always_comb begin
    instr = core[pc];
end
endmodule