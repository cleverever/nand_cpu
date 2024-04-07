`include "nand_cpu.svh"

interface reorder_buffer_ifc;
logic valid;
logic use_rw;
logic [$clog2(`NUM_D_REG)-1:0] prev_rw_addr;
logic use_rs;
logic [$clog2(`NUM_S_REG)-1:0] prev_rs_addr;

modport in
(
    input valid, use_rw, prev_rw_addr, use_ps, prev_rs_addr
);
modport out
(
    output valid, use_rw, prev_rw_addr, use_ps, prev_rs_addr
);
endinterface

module reorder_buffer #(parameter L = 16)
(
    input logic clk,
    input logic n_rst,

    input logic push,

    reorder_buffer_ifc.out commit,

    output logic stall,
    output logic rob_open_slot
);

typedef struct packed
{
    logic done;
    logic use_rw;
    logic [$clog2(`NUM_D_REG)-1:0] prev_rw_addr;
    logic use_rs;
    logic [$clog2(`NUM_S_REG)-1:0] prev_rs_addr;
} rob_entry;

rob_entry buffer [L];
logic unsigned [$clog2(L)-1:0] tail;
logic unsigned [$clog2(L)-1:0] head;
logic unsigned [$clog2(L):0] count;

always_comb begin
    commit.valid = buffer[head].done & (count > 0);
    stall = (count == L);
    rob_open_slot = tail;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        tail <= 0;
        head <= 0;
        count <= 0
    end
    else begin
        if(commit) begin
            head <= (head + 1) % L;
        end
        if(push) begin
            tail <= (tail + 1) % L;
        end
    end
end
endmodule