`include "nand_cpu.svh"

interface load_buffer_ifc;
logic valid;
logic rob_addr;
logic rt_addr;
logic rw_addr;

modport in
(
    input valid, rob_addr, rt_addr, rw_addr
);
modport out
(
    output valid, rob_addr, rt_addr, rw_addr
);
endinterface

//May be handled out-of-order because loads are independent of each other.
module load_buffer#(parameter L)
(
    input logic clk,
    input logic n_rst,

    buffer_ctrl_ifc.in ctrl,

    rob_checkpoint.in rob_cp,
    input logic [$clog2(`ROB_LENGTH)-1:0] rob_head,
    
    input logic sb_rob_address,

    input logic r_calculated_list [`NUM_D_REG],

    input logic pop,
    output logic full,
    output logic empty,

    load_buffer_ifc.in in,
    load_buffer_ifc.out out

);

typedef struct packed
{
    logic valid;
    logic [$clog2(`ROB_LENGTH)-1:0] rob_addr;
    logic rob_ready;
    logic [$clog2(`NUM_D_REG)-1:0] rt_addr;
    logic rt_ready;
    logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
    logic ready;
}
ld_entry;

ld_entry buffer [L];

logic open;
logic open_addr;
logic ready;
logic ready_addr;

//Must compare entry rob with newest store rob to determine eligible entries.
generate
    genvar g;
    for(g = 0; g < L; g++) begin: comparators
        circular_comparator#($clog2(`ROB_LENGTH)) cc
        (
            .offset(rob_head),
            .in0(sb_rob_address),
            .in1(buffer[g].rob_addr),

            .result(buffer[g].rob_ready)
        );
    end: comparators
endgenerate

always_comb begin
    ready = 1'b0;
    open = 1'b0;
    empty = 1'b1;
    for(int i = L-1; i >= 0; i--) begin
        //Set the entry to ready if it is valid and all required operands have been calculated.
        buffer[i].rt_ready = r_calculated_list[buffer[i].rt_addr];
        buffer[i].ready = buffer[i].valid & buffer[i].rob_ready & buffer[i].rt_ready;

        if(buffer[i].ready) begin
            ready = 1'b1;
            ready_addr = i;
        end
        if(buffer[i].valid) begin
            empty = 1'b0;
        end
        else begin
            open = 1'b1;
            open_addr = i;
        end
    end
    full = ~open;

    //The output is valid if it is ready. In the event of a branch mispredict,
    //the rob address must be validated as well.
    out.valid = ready & (~rob_cp.restore | ((rob_cp.tail > rob_head)?
        ((buffer[ready_addr].rob_addr < flush.tail) & (buffer[ready_addr].rob_addr >= rob_head)) :
        ((buffer[ready_addr].rob_addr < flush.tail) | (buffer[ready_addr].rob_addr >= rob_head))));
    out.rob_addr = buffer[ready_addr].rob_addr;
    out.rt_addr = buffer[ready_addr].rt_addr;
    out.rw_addr = buffer[ready_addr].rw_addr;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        buffer = '{default:'0};
    end
    else begin
        if(~ctrl.reject & in.valid) begin
            buffer[open_addr].valid <= 1'b1;
            buffer[open_addr].rob_addr <= in.rob_addr;
            buffer[open_addr].rt_addr <= in.rt_addr;
            buffer[open_addr].rw_addr <= in.rw_addr;
        end

        if(~ctrl.retain & pop) begin
            buffer[ready_addr].valid <= 1'b0;
        end
    end
end
endmodule