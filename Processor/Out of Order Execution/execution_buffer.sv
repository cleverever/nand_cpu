`include "nand_cpu.svh"

interface execution_buffer_ifc;
logic valid;
logic rob_addr;
nand_cpu_pkg::AluOp alu_op;
logic [5:0] immdt;
logic [$clog2(`NUM_D_REG)-1:0] ra_addr;
logic use_rt;
logic [$clog2(`NUM_D_REG)-1:0] rt_addr;
logic write_dst;
logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
logic [$clog2(`NUM_D_REG)-1:0] prev_rw_addr;
logic [$clog2(`NUM_S_REG)-1:0] rs_addr;
logic [$clog2(`NUM_S_REG)-1:0] prev_rs_addr;

modport in
(
    input valid, rob_addr, alu_op, immdt, ra_addr, use_rt, rt_addr, write_dst, rw_addr, prev_rw_addr, rs_addr, prev_rs_addr
);
modport out
(
    output valid, rob_addr, alu_op, immdt, ra_addr, use_rt, rt_addr, write_dst, rw_addr, prev_rw_addr, rs_addr, prev_rs_addr
);
endinterface

module execution_buffer #(parameter L = 8)
(
    execution_buffer_ifc.in in,
    execution_buffer_ifc.out out
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
    logic write_dst;
    logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
    logic [$clog2(`NUM_D_REG)-1:0] prev_rw_addr;
    logic [$clog2(`NUM_S_REG)-1:0] rs_addr;
    logic [$clog2(`NUM_S_REG)-1:0] prev_rs_addr;
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
        buffer[i].ready = buffer[i].valid & (~buffer[i].use_ra | buffer[i].ra_ready) & (~buffer[i].use_rt | buffer[i].rt_ready);
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
    out.alu_op = buffer[ready_addr].alu_op;
    out.immdt = buffer[ready_addr].immdt;
    out.ra_addr = buffer[ready_addr].ra_addr;
    out.use_rt = buffer[ready_addr].use_rt;
    out.rt_addr = buffer[ready_addr].rt_addr;
    out.rw_addr = buffer[ready_addr].rw_addr;
    out.prev_rw_addr = buffer[ready_addr].prev_rw_addr;
    out.rs_addr = buffer[ready_addr].rs_addr;
    out.prev_rs_addr = buffer[ready_addr].prev_rs_addr;
end

always_ff @(posedge clk) begin

end
endmodule