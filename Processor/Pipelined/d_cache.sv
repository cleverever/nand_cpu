`include "nand_cpu.svh"

interface d_cache_input_ifc;
logic valid;
logic [15 : 0] address;
nand_cpu_pkg::MEM_OP mem_op;
logic [15 : 0] data;

modport in
(
    input valid, address, mem_op, data
);
modport out
(
    output valid, address, mem_op, data
);
endinterface

interface d_cache_output_ifc;
logic valid;
logic [15 : 0] data;

modport in
(
    input valid, data
);
modport out
(
    output valid, data
);
endinterface

module d_cache
(
    input logic clk,
    input logic n_rst,

    d_cache_input_ifc.in in,

    d_cache_output_ifc.out out
);

logic [7 : 0] core [(2 ** 16) - 1];

always_ff @(posedge clk) begin
    if(~n_rst) begin
        core <= {default:'0};
    end
    else begin
    end
end

always_comb begin
end
endmodule