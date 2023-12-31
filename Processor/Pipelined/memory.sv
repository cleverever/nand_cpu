`include "nand_cpu.svh"

typedef enum
{
    READY,
    I_READING,
    D_WRITING,
    D_READY,
    D_READING
}
MemState;

module memory
(
    input logic clk,

    i_cache_request_ifc.memory r_i_cache,
    d_cache_request_ifc.memory r_d_cache
);
localparam WIDTH = ((`PC_SIZE - 1 > 16)? `PC_SIZE : 17) - $clog2(`CACHE_BLOCK_SIZE / 16);
localparam COUNTER_SIZE = $clog2(`CACHE_BLOCK_SIZE / `MEM_TRANS_SIZE);

logic [`CACHE_BLOCK_SIZE - 1 : 0] core [2 ** WIDTH];
logic [WIDTH - 1 : 0] i_address;
logic [WIDTH - 1 : 0] d_address;

logic [COUNTER_SIZE - 1 : 0] counter;

MemState state;
MemState next_state;

always_ff @(posedge clk) begin
    state <= next_state;
    case(state)
        READY: begin
            counter <= 0;
        end
        I_READING: begin
            counter <= counter + 1;
        end
        D_WRITING: begin
            core[d_address][counter * `MEM_TRANS_SIZE +: `MEM_TRANS_SIZE] <= r_d_cache.w_data;
            counter <= counter + 1;
        end
        D_READY: begin
            counter <= 0;
        end
        D_READING: begin
            counter <= counter + 1;
        end
    endcase
end

always_comb begin
    i_address = {'0, r_i_cache.address};
    d_address = {'0, r_d_cache.address} | {1'b1, {(WIDTH - 1){1'b0}}};
    case(state)
        READY: begin
            if(r_i_cache.req) begin
                next_state = I_READING;
                r_i_cache.ack = 1'b1;
                r_d_cache.ack = 1'b0;
            end
            else if(r_d_cache.req == REQ_WRITE) begin
                next_state = D_WRITING;
                r_i_cache.ack = 1'b0;
                r_d_cache.ack = 1'b1;
            end
            else if(r_d_cache.req == REQ_READ) begin
                next_state = D_READING;
                r_i_cache.ack = 1'b0;
                r_d_cache.ack = 1'b1;
            end
        end
        I_READING: begin
            r_i_cache.ack = 1'b0;
            r_d_cache.ack = 1'b0;
            r_i_cache.data = core[i_address][counter * `MEM_TRANS_SIZE +: `MEM_TRANS_SIZE];
            if(&counter) begin
                next_state = READY;
            end
        end
        D_WRITING: begin
            r_i_cache.ack = 1'b0;
            r_d_cache.ack = 1'b0;
            if(&counter) begin
                next_state = D_READY;
            end
        end
        D_READY: begin
            r_i_cache.ack = 1'b0;
            r_d_cache.ack = 1'b0;
            if(r_d_cache.req == REQ_READ) begin
                next_state = D_READING;
                r_d_cache.ack = 1'b1;
            end
        end
        D_READING: begin
            r_i_cache.ack = 1'b0;
            r_d_cache.ack = 1'b0;
            r_d_cache.r_data = core[d_address][counter * `MEM_TRANS_SIZE +: `MEM_TRANS_SIZE];
            if(&counter) begin
                next_state = READY;
            end
        end
    endcase
end
endmodule