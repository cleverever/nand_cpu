`include "nand_cpu.svh"

interface execution_buffer_ifc;
logic valid;
nand_cpu_pkg::AluOp alu_op;
logic [5:0] immdt;
logic [$clog2(`NUM_D_REG)-1:0] ra_addr;
logic [$clog2(`NUM_D_REG)-1:0] rt_addr;
logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
logic [15:0] rv_addr;
logic [$clog2(`NUM_S_REG)-1:0] rs_addr;

modport self
(
    output valid, alu_op, immdt, ra_addr, rt_addr, rw_addr, rv_addr, rs_addr
);
modport other
(
    input valid, alu_op, immdt, ra_addr, rt_addr, rw_addr, rv_addr, rs_addr
);
endinterface

module execution_buffer #(parameter L = 8)
(
    execution_buffer_ifc.self out
);

typedef struct packed
{
    logic valid;
    nand_cpu_pkg::AluOp alu_op;
    logic [5:0] immdt;
    logic use_ra;
    logic [$clog2(`NUM_D_REG)-1:0] ra_addr;
    logic ra_ready;
    logic use_rt;
    logic [$clog2(`NUM_D_REG)-1:0] rt_addr;
    logic rt_ready;
    logic use_rw;
    logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
    logic [15:0] rv_addr;
    logic rw_ready;
    logic use_rs;
    logic [$clog2(`NUM_S_REG)-1:0] rs_addr;
    logic rs_ready;
    logic ready;
} eb_entry;

eb_entry buffer [L];
logic ready;
logic [$clog2(L)-1:0] ready_addr;
logic open;
logic [$clog2(L)-1:0] open_addr;

always_comb begin
    ready = 1'b0;
    open = 1'b0;
    for(int i = L-1; i >= 0; i--) begin
        buffer[i].ready = buffer[i].valid & (~buffer[i].use_ra | buffer[i].ra_ready) & (~buffer[i].use_rt | buffer[i].rt_ready) &
            (~buffer[i].use_rw | buffer[i].rw_ready) & (~buffer[i].use_rs | buffer[i].rs_ready);
        if(buffer[i].ready) begin
            ready = 1'b1;
            ready_addr = i;
        end
        if(~buffer[i].valid) begin
            open = 1'b1;
            open_addr = i;
        end
    end
    out.valid = ready;
    out.alu_op = TODO;//TODO
    out.immdt = TODO;//TODO
    out.ra_addr = buffer[ready_addr].ra_addr;
    out.rt_addr = buffer[ready_addr].rt_addr;
    out.rw_addr = buffer[ready_addr].rw_addr;
    out.rv_addr = buffer[ready_addr].rv_addr;
    out.rs_addr = buffer[ready_addr].rs_addr;
end

always_ff @(posedge clk) begin

end
endmodule