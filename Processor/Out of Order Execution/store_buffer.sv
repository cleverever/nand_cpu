`include "nand_cpu.svh"

interface store_buffer_ifc;
logic valid;
logic rob_addr;
logic ra_addr;
logic rt_addr;

modport in
(
    input valid, rob_addr, ra_addr, rt_addr
);
modport out
(
    output valid, rob_addr, ra_addr, rt_addr
);
endinterface

//Must be handled in-order because store dependencies cannot be determined
//without first calculating their address.
module store_buffer#(parameter L)
(
    input logic clk,
    input logic n_rst,

    buffer_ctrl_ifc.in ctrl,

    sb_checkpoint.in checkpoint,

    input logic r_calculated_list [`NUM_D_REG],
    
    input logic pop,
    output logic full,
    output logic empty,

    store_buffer_ifc.in in,
    store_buffer_ifc.out out
);

typedef struct packed
{
    logic [$clog2(`ROB_LENGTH)-1:0] rob_addr;
    logic [$clog2(`NUM_D_REG)-1:0] ra_addr;
    logic ra_ready;
    logic [$clog2(`NUM_D_REG)-1:0] rt_addr;
    logic rt_ready;
    logic ready;
}
store_entry;

store_entry buffer [L];

logic unsigned [$clog2(L)-1:0] tail;
logic unsigned [$clog2(L)-1:0] head;
logic unsigned [$clog2(L)-1:0] count;

always_comb begin
    count = tail - head;

    full = (count == `ROB_LENGTH - 1);

    for(int i = L-1; i >= 0; i--) begin
        //Set the entry to ready if it is valid and all required operands have been calculated.
        buffer[i].ra_ready = r_calculated_list[buffer[i].ra_addr];
        buffer[i].rt_ready = r_calculated_list[buffer[i].rt_addr];
        buffer[i].ready = buffer[i].ra_ready & buffer[i].rt_ready;
    end

    out.valid = buffer[head].ready & (count > 0);
    out.rob_addr = buffer[head].rob_addr;
    out.ra_addr = buffer[head].ra_addr;
    out.rt_addr = buffer[head].rt_addr;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        tail <= 0;
        head <= 0;
    end
    else begin
        if(~ctrl.retain & pop & buffer[head].ready & (count > 0)) begin
            head <= (head + 1) % L;
        end

        if(checkpoint.restore) begin
            tail <= checkpoint.tail;
        end
        else if(~ctrl.reject & in.valid) begin
            tail <= (tail + 1) % `ROB_LENGTH;
            buffer[tail].rob_addr <= in.rob_addr;
            buffer[tail].ra_addr <= in.ra_addr;
            buffer[tail].rt_addr <= in.rt_addr;
        end
    end
end
endmodule