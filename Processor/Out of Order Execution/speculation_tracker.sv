`include "nand_cpu.svh"

//Helps to determine the current level of speculation. Important for determining if no-speculation
//instructions such as memory stores are okay for execution.
module speculation_tracker #(parameter L = 8)
(
    input logic clk,
    input logic n_rst,

    speculation_tracker_cp_ifc.in checkpoint,

    buffer_ctrl_ifc.in ctrl,
    branch_buffer_ifc.in in,

    metadata_ifc.in commit_md,

    output logic full,

    output logic valid,
    output logic [$clog2(`ROB_LENGTH)-1:0] oldest_rob
);

typedef struct packed
{
    logic done;
    logic [$clog2(`ROB_LENGTH)-1:0] rob_addr;
}
spec_track_entry;

spec_track_entry buffer [L];

logic unsigned [$clog2(L)-1:0] head;
logic unsigned [$clog2(L)-1:0] tail;
logic unsigned [$clog2(L+1)-1:0] count;

always_comb begin
    count = tail - head;
    valid = count > 0;
    oldest_rob = buffer[head].rob_addr;
end

always_ff @(posedge clk) begin
    if(buffer[head].done & (count > 0)) begin
        head <= (head + 1) % L;
    end
    if(commit_md.valid) begin
        for(int i = 0; i < L; i++) begin
            if(buffer[i].rob_addr == commit_md.rob_addr) begin
                buffer[i].done = 1'b1;
            end
        end
    end
end
endmodule