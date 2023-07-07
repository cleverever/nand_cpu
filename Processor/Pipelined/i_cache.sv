`include "nand_cpu.svh"

typedef enum
{
    READY,
    REQUEST_WRITE,
    WRITING,
    REQUEST_READ,
    READING
}
CacheState;

interface i_cache_request_ifc;
logic req;
logic ack;
logic [15 - $clog2(`CACHE_BLOCK_SIZE) : 0] address;
logic [`MEM_TRANS_SIZE - 1 : 0] data;

modport cache
(
    input ack, data,
    output ack, address
);
modport memory
(
    input ack, address,
    output ack, data
);
endinterface

interface i_cache_output_ifc;
logic hit;
logic miss;
logic [7 : 0] data;

modport in
(
    input hit, miss, data
);
modport out
(
    output hit, miss, data
);
endinterface

module i_cache #(parameter INDEX_BITS = 8)
(
    input logic clk,
    input logic n_rst,

    input logic valid,
    input logic pc,

    i_cache_output_ifc.out out,

    cache_request_ifc.cache cache_request
);

localparam DATA_SIZE = 8;
localparam OFFSET_BITS = $clog2(`CACHE_BLOCK_SIZE / DATA_SIZE);
localparam TAG_BITS = 16 - INDEX_BITS - OFFSET_BITS;
localparam COUNTER_SIZE = $clog2(`CACHE_BLOCK_SIZE / `MEM_TRANS_SIZE);

logic [OFFSET_BITS - 1 : 0] offset;
logic [INDEX_BITS - 1 : 0] index;
logic [TAG_BITS - 1 : 0] tag;

logic [COUNTER_SIZE - 1 : 0] counter;

typedef struct packed
{
    logic valid;
    logic [TAG_BITS - 1 : 0] tag;
    logic [CACHE_BLOCK_SIZE - 1 : 0] data;
}
DCacheLine;

DCacheLine lines [INDEX_BITS - 1 : 0];

CacheState state;
CacheState next_state;

always_ff @(posedge clk) begin
    if(~n_rst) begin
        lines <= {default:'0};
    end
    else begin
        state <= next_state;
        case(state)
            READY: begin
            end
            READ_REQUEST: begin
                counter <= 0;
            end
            READING: begin
                counter <= counter + 1;
                lines[index].data[counter * MEM_TRANS_SIZE +: MEM_TRANS_SIZE] <= cache_request.data;
                if(&counter) begin
                    lines[index].valid <= 1'b1;
                    lines[index].tag <= tag;
                end
            end
        endcase
    end
end

always_comb begin
    offset = address[OFFSET_BITS - 1 : 0];
    index = address[INDEX_BITS + OFFSET_BITS - 1 : OFFSET_BITS];
    tag = address[TAG_BITS + INDEX_BITS + OFFSET_BITS - 1 : INDEX_BITS + OFFSET_BITS];

    next_state = state;
    case(state)
        READY: begin
            out.hit = valid & lines[index].valid & (lines[index].tag == tag);
            out.miss = valid & ~(lines[index].valid & (lines[index].tag == tag));
            if(miss) begin
                next_state = READ_REQUEST;
            end
        end
        READ_REQUEST: begin
            out.hit = 1'b0;
            out.miss = 1'b1;
            if(cache_request.ack) begin
                next_state = READING;
            end
        end
        READING: begin
            out.hit = 1'b0;
            out.miss = 1'b1;
            if(&counter) begin
                next_state = READY;
            end
        end
    endcase
end
endmodule