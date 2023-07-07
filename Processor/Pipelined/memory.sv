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
    input logic n_rst,

    i_cache_request_ifc.memory r_i_cache,
    d_cache_request_ifc.memory r_d_cache
);
localparam MEM_WIDTH = (`PC_SIZE > 16)? `PC_SIZE + 1 : 17;
localparam COUNTER_SIZE = $clog2(`CACHE_BLOCK_SIZE / `MEM_TRANS_SIZE);

logic [`CACHE_BLOCK_SIZE - 1 : 0] core [ADDR_BITS - 1 : 0];

logic [COUNTER_SIZE - 1 : 0] counter;

MemState state;
MemState next_state;

always_ff @(posedge clk) begin
    if(~n_rst) begin
        core <= {default:'0};
    end
    else begin
        state <= next_state;
        case(state)
            READY: begin
                counter <= 0;
            end
            I_READING: begin
                counter <= counter + 1;
            end
            D_WRITING: begin
                core[{1'b1, r_d_cache.address}][counter * MEM_TRANS_SIZE +: MEM_TRANS_SIZE] <= r_d_cache.data;
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
end

always_comb begin
    r_i_cache.ack = 1'b0;
    r_d_cache.ack = 1'b0;
    case(state)
        READY: begin
            if(r_i_cache.req) begin
                next_state = I_READING;
                r_i_cache.ack = 1'b1;
            end
            else if(r_d_cache.req == WRITE) begin
                next_state = D_WRITING;
                r_d_cache.ack = 1'b1;
            end
            else if(r_d_cache.req == READ) begin
                next_state = D_READING;
                r_d_cache.ack = 1'b1;
            end
        end
        I_READING: begin
            r_i_cache.data = core[{1'b0, r_i_cache.address}][counter * MEM_TRANS_SIZE +: MEM_TRANS_SIZE];
            if(&counter) begin
                next_state = READY;
            end
        end
        D_WRITING: begin
            if(&counter) begin
                next_state = D_READY;
            end
        end
        D_READY: begin
            if(r_d_cache.req == READ) begin
                next_state = D_READING;
                r_d_cache.ack = 1'b1;
            end
        end
        D_READING: begin
            r_d_cache.data = core[{1'b1, r_d_cache.address}][counter * MEM_TRANS_SIZE +: MEM_TRANS_SIZE];
            if(&counter) begin
                next_state = READY;
            end
        end
    endcase
end
endmodule