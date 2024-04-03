`include "nand_cpu.svh"

module translation_table
(
    input logic clk,
    input logic n_rst,

    input logic set,
    input logic [3 : 0] v_reg,
    input logic [$clog2(`NUM_REG)-1 : 0] p_reg
);

logic [$clog2(`NUM_REG)-1 : 0] translation [16];

always_ff @(posedge clk) begin
    if(~n_rst) begin
        for(int i = 0; i < 16; i++) begin
            translation[i] <= 0;
        end
    end
    else begin
        if(set) begin
            translation[v_reg] <= p_reg;
        end
    end
end
endmodule