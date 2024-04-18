`include "nand_cpu.svh"

//Loads may occur out of order relative to other loads, but must wait for older stores.
//Stores are handled in order and must wait for older loads.
module memory_buffer #(parameter L)
(
    input logic clk,
    input logic n_rst,

    input logic push,
    input T in,

    input logic rob_head,

    output logic valid,
    output T out
);

logic push_sb;
logic push_lb;

logic pop_sb;
logic pop_lb;

logic empty_sb;
logic empty_lb;

logic ready_sb;
logic ready_lb;

logic rob_addr_sb;
logic rob_addr_lb;

store_buffer sb
(
    .clk,
    .n_rst,

    .pop(pop_sb),

    .empty(empty_sb),
    .ready(ready_sb),
    .rob_addr(rob_addr_sb)
);

load_buffer lb
(
    .clk,
    .n_rst,

    .pop(pop_lb),

    .empty(empty_lb),
    .ready(ready_lb),
    .rob_addr(rob_addr_lb)
);

always_comb begin
    valid = ready_sb | ready_lb;

    //If both store and load buffer have entries, must compare rob addresses to determine which is older.
    //Due to circular queue in rob, address comparison involves checking for wrapping.
    if(~empty_sb & ~empty_lb) begin
        if((rob_addr_sb < rob_addr_lb) ^ (rob_addr_sb < rob_head) ^ (rob_addr_lb < rob_head)) begin
            pop_sb = ready_sb;
            pop_lb = 1'b0;
        end
        else begin
            pop_sb = 1'b0;
            pop_lb = ready_lb;
        end
    end

    //If one buffer is empty, no checking is required.
    else begin
        pop_sb = ready_sb;
        pop_lb = ready_lb;
    end
end
endmodule