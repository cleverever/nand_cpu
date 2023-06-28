`include "nand_cpu.svh"

interface d_cache_ifc;
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

    decoder_output_ifc.d_mem i_decoder,
    regfile_output_ifc.d_mem i_regfile,

    d_mem_ifc.out out
);

logic [7 : 0] core [(2 ** 16) - 1];

always_ff @(posedge clk) begin
    if(~n_rst) begin
        core <= {default:'0};
    end
    else begin
        if(i_decoder.valid & i_decoder.mem_access & i_decoder.mem_op == WRITE) begin
            core[i_regfile.rt + 1] = i_regfile.ra[15 : 8];
            core[i_regfile.rt] = i_regfile.ra[7 : 0];
        end
    end
end

always_comb begin
    if(i_decoder.valid & i_decoder.mem_access & i_decoder.mem_op == READ) begin
        data[15 : 8] = core[i_regfile.rt + 1];
        data[7 : 0] = core[i_regfile.rt];
    end
end
endmodule