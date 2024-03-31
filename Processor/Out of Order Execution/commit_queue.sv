`include "nand_cpu.svh"

module commit_list
(
    input logic clk,
    input logic n_rst,

    input logic push,
    input logic use_rw,
    input logic [$clog2(`NUM_REG) - 1 : 0] rw_addr,
    input logic ps_write,
    input logic [$clog2(`NUM_PS) - 1 : 0] ps_addr,

    output logic reg_return,
    output logic [$clog2(`NUM_REG) - 1 : 0] r_reg,

    output logic ps_return,
    output logic [$clog2(`NUM_PS) - 1 : 0] r_ps
);

typedef struct packed
{
    logic complete;
    logic use_rw;
    logic [$clog2(`NUM_REG) - 1 : 0] rw_addr;
    logic ps_write;
    logic [$clog2(`NUM_PS) - 1 : 0] ps_addr;
} ALEntry;

ALEntry qin;
assign qin = '{
    complete : 1'b0,
    use_rw : use_rw,
    rw_addr : rw_addr,
    ps_write : ps_write,
    ps_addr : ps_addr
};

ALEntry qout;

circular_queue #(.T(ALEntry), .L(`AL_SIZE)) cq
{
    .clk(clk),
    .n_rst(n_rst),

    .push(push),
    .in(qin),

    .pop(qout.complete),
    .out(qout)
};


always_ff @(posedge clk) begin

end

always_comb begin
    reg_return = qout.complete & qout.use_rw;
    r_reg = qout.rw_addr;

    ps_return = qout.complete & qout.ps_write;
    r_ps = qout.ps_addr;
end
endmodule