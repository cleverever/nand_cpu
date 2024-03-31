`include "nand_cpu.svh"

interface reg_alloc_ifc;
logic [$clog2(`NUM_REG) - 1 : 0] reg_map [16];
logic [$clog2(`NUM_PS) - 1 : 0] ps_map;

modport in
(
    input reg_map, ps_map
);
modport out
(
    output reg_map, ps_map
);
endinterface

module reg_alloc_table
(
    input logic clk,
    input logic n_rst,

    decoder_output_ifc.in i_decoded,
    free_list_ifc.in i_free_list,

    reg_alloc_ifc.out out
);

always_ff @(posedge clk) begin
    if(i_decoded.use_rw) begin
        out.reg_map[i_decoded.rw_addr] = i_free_list.free_reg;
    end
    if(i_decoded.ps_write) begin
        out.ps_map = i_free_list.free_ps;
    end
end
endmodule