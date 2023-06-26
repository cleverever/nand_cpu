`include "nand_cpu.svh"

module d_mem
(
    input logic clk,
    input logic n_rst,

    decoder_output_ifc.alu i_decoder,
    regfile_output_ifc.alu i_regfile,

    output logic [15 : 0] data
);

logic [7 : 0] core [(2 ** 16) - 1];

always_ff @(posedge clk) begin
    if(~n_rst) begin
        core[i_regfile.rt + 1] = i_regfile.ra[15 : 8];
        core[i_regfile.rt] = i_regfile.ra[7 : 0];
    end
    else begin
        if(i_decoder.valid & i_decoder.mem_access & i_decoder.mem_op == WRITE) begin
            data[]
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