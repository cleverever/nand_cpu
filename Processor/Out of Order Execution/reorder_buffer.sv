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
logic [`NUM_D_REG] return_r_list;
logic [`NUM_S_REG] return_s_list;

modport in
(
    input return_r_list, return_s_list
);
modport out
(
    output return_r_list, return_s_list
);
endinterface

module reorder_buffer #(parameter L = 16)
(
    input logic clk,
    input logic n_rst,

    input logic push,
    decoder_ifc.in decoder_in,
    translation_table_ifc.in tt_in,

    input logic rollback,
    input logic unsigned [$clog2(L)-1:0] incident_addr,

    reorder_buffer_ifc.out checkin,

    metadata_ifc.in ex_md,

    valid_rob_range_ifc.out active_range,

    output logic rob_full,
    output logic [$clog2(`ROB_SIZE)-1:0] rob_open_slot
);

typedef struct packed
{
    logic done;
    logic write_rw;
    logic [$clog2(`NUM_D_REG)-1:0] new_rw_addr; 
    logic [$clog2(`NUM_D_REG)-1:0] prev_rw_addr;
    logic write_rs;
    logic [$clog2(`NUM_S_REG)-1:0] new_rs_addr;
    logic [$clog2(`NUM_S_REG)-1:0] prev_rs_addr;
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
        checkin.return_r_list <= {default:1'b0};
        checkin.return_s_list <= {default:1'b0};
        if(buffer[head].done & (count > 0)) begin
            head <= (head + 1) % L;
            if(buffer[head].write_rw) begin
                checkin.return_r_list[buffer[head].prev_rw_addr] <= 1'b1;
            end
            if(buffer[head].write_rs) begin
                checkin.return_s_list[buffer[head].prev_rs_addr] <= 1'b1;
            end
        end
        if(rollback) begin
            tail <= (incident_addr + 1) % L;
            for(int i = (incident_addr + 1) % L; i != tail; i = (i + 1) % L) begin
                if(buffer[i].write_rw) begin
                    checkin.return_r_list[buffer[i].new_rw_addr] <= 1'b1;
                end
                if(buffer[i].write_rs) begin
                    checkin.return_s_list[buffer[i].new_rs_addr] <= 1'b1;
                end
            end
        end
        else if(push) begin
            tail <= (tail + 1) % L;
            buffer[tail].done <= 1'b0;
            buffer[tail].write_rw <= decoder_in.use_rw;
            buffer[tail].prev_rw_addr <= tt_in.p_rw_addr;
            buffer[tail].write_rs <= decoder_in.use_rs;
            buffer[tail].prev_rs_addr <= tt_in.p_rs_addr;
        end
    end

    if(ex_md.valid) begin
        buffer[ex_md.rob_addr].done <= 1'b1;
    end
end
endmodule