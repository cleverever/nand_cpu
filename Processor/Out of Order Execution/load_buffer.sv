`include "nand_cpu.svh"

//May be handled out-of-order because loads are independent of each other.
module load_buffer
(
    input logic clk,
    input logic n_rst

    input logic pop,

    output logic empty,
    output logic ready,
    output logic rob_addr
);

ld_entry buffer [`LOAD_BUFFER_LENGTH];

always_comb begin
    ready = 1'b0;
    open = 1'b0;
    for(int i = L-1; i >= 0; i--) begin
        buffer[i].rt_ready = r_calculated_list[buffer[i].rt_addr];
        buffer[i].rw_ready = r_calculated_list[buffer[i].rw_addr];
        buffer[i].ready = buffer[i].valid & (~buffer[i].use_ra | buffer[i].ra_ready) & (~buffer[i].use_rt | buffer[i].rt_ready);
        if(buffer[i].ready) begin
            ready = 1'b1;
            ready_addr = i;
        end
        if(~buffer[i].valid) begin
            open = 1'b1;
            open_addr = i;
        end
    end
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        buffer = '{default:'0};
    end
    else begin
    end
end
endmodule