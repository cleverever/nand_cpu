`include "nand_cpu.svh"

interface valid_rob_range_ifc;
logic unsigned [$clog2(L)-1:0] high;
logic unsigned [$clog2(L)-1:0] low;
logic unsigned rob_empty;

function automatic logic check_valid(logic unsigned [$clog2(L)-1:0] rob_addr);
    if(high > low) begin
        return (rob_addr < high) & (rob_addr >= low);
    end
    else if(high == low) begin
        return ~rob_empty;
    end
    else begin
        return (rob_addr >= low) | (rob_addr < high);
    end
endfunction

modport in
(
    input high, low
);
endinterface

interface reorder_buffer_ifc;
logic return_r;
logic [$clog2(`NUM_D_REG)-1:0] r_addr;
logic return_s;
logic [$clog2(`NUM_S_REG)-1:0] s_addr;

modport in
(
    input return_r, r_addr, return_s, s_addr
);
modport out
(
    output return_r, r_addr, return_s, s_addr
);
endinterface

module reorder_buffer #(parameter L = 16)
(
    input logic clk,
    input logic n_rst,

    input logic push,
    decoder_ifc.in decoder_in,
    translation_table_ifc.in tt_in,
    free_reg_list_ifc.in frl_in,

    reorder_buffer_ifc.out checkin,

    metadata_ifc.in ex_md,

    rob_checkpoint.in checkpoint,

    valid_rob_range_ifc.out active_range,

    output logic rob_full,
    output logic [$clog2(`ROB_SIZE)-1:0] rob_open_slot
);

typedef struct packed
{
    logic done;
    logic write_r;
    logic [$clog2(`NUM_D_REG)-1:0] prev_r_addr;
    logic write_s;
    logic [$clog2(`NUM_S_REG)-1:0] prev_s_addr;
} rob_entry;

rob_entry buffer [L];
logic unsigned [$clog2(L)-1:0] tail;
logic unsigned [$clog2(L)-1:0] head;
logic unsigned [$clog2(L):0] count;

always_comb begin
    active_range.high = tail;
    active_range.low = head;

    count = tail - head;

    rob_full = (count == L - 1);
    rob_open_slot = tail;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        tail <= 0;
        head <= 0;
    end
    else begin
        if(buffer[head].done & (count > 0)) begin
            head <= (head + 1) % L;
            commit.return_r <= buffer[head].write_r;
            commit.r_addr <= buffer[head].prev_r_addr;
            commit.return_s <= buffer[head].write_s;
            commit.s_addr <= buffer[head].prev_s_addr;
        end
        else begin
            commit.return_r <= 1'b0;
            commit.return_s <= 1'b0;
        end
        if(checkpoint.restore) begin
            tail <= checkpoint.tail;
        end
        else if(push) begin
            tail <= (tail + 1) % L;
            buffer[tail].done <= 1'b0;
            buffer[tail].write_r <= decoder_in.use_rw;
            buffer[tail].new_rw_addr <= frl_in.rw_addr;
            buffer[tail].prev_r_addr <= tt_in.p_rw_addr;
            buffer[tail].write_s <= decoder_in.use_rs;
            buffer[tail].new_rs_addr <= frl_in.rs_addr;
            buffer[tail].prev_s_addr <= tt_in.p_rs_addr;
        end
    end

    if(ex_md.valid) begin
        buffer[ex_md.rob_addr].done <= 1'b1;
    end
end
endmodule