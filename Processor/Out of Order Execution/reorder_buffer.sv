`include "nand_cpu.svh"

interface reorder_buffer_ifc;
logic valid;
logic write_rw;
logic [$clog2(`NUM_D_REG)-1:0] prev_rw_addr;
logic write_rs;
logic [$clog2(`NUM_S_REG)-1:0] prev_rs_addr;

modport in
(
    input valid, write_rw, prev_rw_addr, write_rs, prev_rs_addr
);
modport out
(
    output valid, write_rw, prev_rw_addr, write_rs, prev_rs_addr
);
endinterface

module reorder_buffer #(parameter L = 16)
(
    input logic clk,
    input logic n_rst,

    input logic push,
    decoder_ifc.in decoder_in,
    translation_table_ifc.in tt_in,

    reorder_buffer_ifc.out commit,

    output logic stall,
    output logic [$clog2(`ROB_SIZE)-1:0] rob_open_slot
);

typedef struct packed
{
    logic done;
    logic write_rw;
    logic [$clog2(`NUM_D_REG)-1:0] prev_rw_addr;
    logic write_rs;
    logic [$clog2(`NUM_S_REG)-1:0] prev_rs_addr;
} rob_entry;

rob_entry buffer [L];
logic unsigned [$clog2(L)-1:0] tail;
logic unsigned [$clog2(L)-1:0] head;
logic unsigned [$clog2(L):0] count;

always_comb begin
    commit.valid = buffer[head].done & (count > 0);
    commit.write_rw = buffer[head].write_rw;
    commit.prev_rw_addr = buffer[head].prev_rw_addr;
    commit.write_rs = buffer[head].write_rs;
    commit.prev_rs_addr = buffer[head].prev_rs_addr;
    stall = (count == L);
    rob_open_slot = tail;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        tail <= 0;
        head <= 0;
        count <= 0;
    end
    else begin
        count <= count + push - commit.valid;
        if(commit.valid) begin
            head <= (head + 1) % L;
        end
        if(push) begin
            tail <= (tail + 1) % L;
            buffer[tail].done <= 1'b0;
            buffer[tail].write_rw <= decoder_in.use_rw;
            buffer[tail].prev_rw_addr <= tt_in.p_rw_addr;
            buffer[tail].write_rs <= decoder_in.use_rs;
            buffer[tail].prev_rs_addr <= tt_in.p_rs_addr;
        end
    end
end
endmodule