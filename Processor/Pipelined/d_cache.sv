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

interface d_cache_request_ifc;
nand_cpu_pkg::CacheRequest req;
logic ack;
logic [15 - $clog2(`CACHE_BLOCK_SIZE) : 0] address;
logic [`MEM_TRANS_SIZE - 1 : 0] r_data;
logic [`MEM_TRANS_SIZE - 1 : 0] w_data;

modport cache
(
    input ack, r_data,
    output req, address, w_data
);
modport memory
(
    input req, address, w_data,
    output ack, r_data
);
endinterface

interface d_cache_input_ifc;
logic mem_access;
logic [15 : 0] address;
nand_cpu_pkg::MemOp mem_op;
logic [15 : 0] data;

modport in
(
    input mem_access, address, mem_op, data
);
modport out
(
    output mem_access, address, mem_op, data
);
endinterface

interface d_cache_output_ifc;
logic hit;
logic miss;
logic [15 : 0] data;

modport in
(
    input hit, miss, data
);
modport out
(
    output hit, miss, data
);
endinterface

module d_cache #(parameter INDEX_BITS = 8)
(
    input logic clk,
    input logic n_rst,

    input logic valid,
    d_cache_input_ifc.in in,

    d_cache_output_ifc.out out,

    d_cache_request_ifc.cache cache_request
);

localparam DATA_SIZE = 16;
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
    logic dirty;
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
    end
    else begin
        state <= next_state;
        case(state)
            READY: begin
            end
            REQUEST_WRITE: begin
                counter <= 0;
            end
            WRITING: begin
                counter <= counter + 1;
                if(&counter) begin
                    lines[index].dirty <= 1'b0;
                end
            end
            REQUEST_READ: begin
                counter <= 0;
            end
            READING: begin
                counter <= counter + 1;
                lines[index].data[counter * `MEM_TRANS_SIZE +: `MEM_TRANS_SIZE] <= cache_request.r_data;
                if(&counter) begin
                    lines[index].valid <= 1'b1;
                    lines[index].tag <= tag;
                end
            end
        endcase
    end
end

always_comb begin
    offset = in.address[OFFSET_BITS - 1 : 0];
    index = in.address[INDEX_BITS + OFFSET_BITS - 1 : OFFSET_BITS];
    tag = in.address[TAG_BITS + INDEX_BITS + OFFSET_BITS - 1 : INDEX_BITS + OFFSET_BITS];

    next_state = state;
    cache_request.req = REQ_NONE;
    case(state)
        READY: begin
            out.hit = valid & lines[index].valid & (lines[index].tag == tag);
            out.miss = valid & ~(lines[index].valid & (lines[index].tag == tag));
            cache_request.req = REQ_NONE;
            if(out.miss) begin
                if(lines[index].dirty) begin
                    next_state = REQUEST_WRITE;
                end
                else begin
                    next_state = REQUEST_READ;
                end
            end
        end
        REQUEST_WRITE: begin
            out.hit = 1'b0;
            out.miss = 1'b1;
            cache_request.req = REQ_WRITE;
            if(cache_request.ack) begin
                next_state = WRITING;
            end
        end
        WRITING: begin
            out.hit = 1'b0;
            out.miss = 1'b1;
            cache_request.req = REQ_NONE;
            cache_request.w_data = lines[index].data[counter * `MEM_TRANS_SIZE +: `MEM_TRANS_SIZE];
            if(&counter) begin
                next_state = REQUEST_READ;
            end
        end
        REQUEST_READ: begin
            out.hit = 1'b0;
            out.miss = 1'b1;
            cache_request.req = REQ_READ;
            if(cache_request.ack) begin
                next_state = READING;
            end
        end
        READING: begin
            out.hit = 1'b0;
            out.miss = 1'b1;
            cache_request.req = REQ_NONE;
            if(&counter) begin
                next_state = READY;
            end
        end
    endcase
end
endmodule