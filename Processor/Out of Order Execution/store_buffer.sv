`include "nand_cpu.svh"

//Must be handled in-order because store dependencies cannot be determined
//without first calculating their address.
module store_buffer
(
    input logic clk,
    input logic n_rst,

    input logic pop,

    output logic ready,
    output logic rob_addr
);

store_entry buffer [`STORE_BUFFER_LENGTH];

logic unsigned [$clog2(`STORE_BUFFER_LENGTH)-1:0] tail;
logic unsigned [$clog2(`STORE_BUFFER_LENGTH)-1:0] head;
logic unsigned [$clog2(`STORE_BUFFER_LENGTH+1)-1:0] count;

always_comb begin
    ready = buffer[head].ready;
    rob_addr = buffer[head].rob_addr;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        tail <= 0;
        head <= 0;
    end
    else begin
        if((~buffer[head].valid | buffer[head].done) & (count > 0)) begin
            head <= (head + 1) % `STORE_BUFFER_LENGTH;
        end
        if(buffer[head].valid & buffer[head].done & (count > 0)) begin
            //RELEASE FOR EXECUTION
        end
        else begin
            //SET INVALID FLAG
        end
        else if(push) begin
            tail <= (tail + 1) % `ROB_LENGTH;
            buffer[tail].valid <= 1'b1;
            //SET BUFFER ENTRY
        end
    end
end
endmodule