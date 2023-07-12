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
    output req, address
);
modport memory
(
    input req, address,
    output ack, data
);
endinterface

interface i_cache_output_ifc;
logic hit;
logic [7 : 0] data;

modport in
(
    input hit, data
);
modport out
(
    output hit, data
);
endinterface

module i_cache #(parameter INDEX_BITS = 8)
(
    input logic clk,
    input logic n_rst,

    input logic [`PC_SIZE - 1 : 0] pc,

    i_cache_output_ifc.out out,

    i_cache_request_ifc.cache cache_request
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
    logic [`CACHE_BLOCK_SIZE - 1 : 0] data;
}
DCacheLine;

DCacheLine lines [INDEX_BITS - 1 : 0];

CacheState state;
CacheState next_state;

always_ff @(posedge clk) begin
    if(~n_rst) begin
        lines <= {default:'0};
        state <= READY;
    end
    else begin
        state <= next_state;
        case(state)
            READY: begin
            end
            REQUEST_READ: begin
                counter <= 0;
            end
            READING: begin
                counter <= counter + 1;
                lines[index].data[counter * `MEM_TRANS_SIZE +: `MEM_TRANS_SIZE] <= cache_request.data;
                if(&counter) begin
                    lines[index].valid <= 1'b1;
                    lines[index].tag <= tag;
                end
            end
        endcase
    end
end

always_comb begin
    offset = pc[OFFSET_BITS - 1 : 0];
    index = pc[INDEX_BITS + OFFSET_BITS - 1 : OFFSET_BITS];
    tag = pc[TAG_BITS + INDEX_BITS + OFFSET_BITS - 1 : INDEX_BITS + OFFSET_BITS];

    cache_request.address = {tag, index};

    next_state = state;
    case(state)
        READY: begin
            out.hit = lines[index].valid & (lines[index].tag == tag);
            out.data = lines[index].data[(`CACHE_BLOCK_SIZE - 1) - (offset * 8) -: 8];
            cache_request.req = 1'b0;
            if(~out.hit) begin
                next_state = REQUEST_READ;
            end
        end
        REQUEST_READ: begin
            out.hit = 1'b0;
            cache_request.req = 1'b1;
            if(cache_request.ack) begin
                next_state = READING;
            end
        end
        READING: begin
            out.hit = 1'b0;
            cache_request.req = 1'b0;
            if(&counter) begin
                next_state = READY;
            end
        end
    endcase
end
endmodule