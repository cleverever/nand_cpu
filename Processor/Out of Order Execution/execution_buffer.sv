`include "nand_cpu.svh"

interface execution_buffer_ifc;
logic valid;
logic [$clog2(`ROB_SIZE)-1:0] rob_addr;
nand_cpu_pkg::AluOp alu_op;
logic [5:0] immdt;
logic [$clog2(`NUM_D_REG)-1:0] ra_addr;
logic use_rt;
logic [$clog2(`NUM_D_REG)-1:0] rt_addr;
logic write_dst;
logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
logic [$clog2(`NUM_S_REG)-1:0] rs_addr;

modport in
(
    input valid, rob_addr, alu_op, immdt, ra_addr, use_rt, rt_addr, write_dst, rw_addr, rs_addr
);
modport out
(
    output valid, rob_addr, alu_op, immdt, ra_addr, use_rt, rt_addr, write_dst, rw_addr, rs_addr
);
endinterface

module execution_buffer #(parameter L = 8)
(
    input logic clk,
    input logic n_rst,

    buffer_ctrl_ifc.in ctrl,
    rob_checkpoint.in rob_cp,
    input logic [$clog2(`ROB_SIZE)-1:0] rob_head,
    output logic full,

    input logic r_calculated_list [`NUM_D_REG],
    
    execution_buffer_ifc.in in,
    execution_buffer_ifc.out out
);

typedef struct packed
{
    logic valid;
    logic [$clog2(`ROB_SIZE)-1:0] rob_addr;
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
    logic [$clog2(`NUM_S_REG)-1:0] rs_addr;
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
        //Set the entry to ready if it is valid and all required operands have been calculated.
        buffer[i].ra_ready = r_calculated_list[buffer[i].ra_addr];
        buffer[i].rt_ready = r_calculated_list[buffer[i].rt_addr];
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
    full = ~open;

    //The output is valid if it is ready. In the event of a branch mispredict,
    //the rob address must be validated as well.
    out.valid = ready & (~rob_cp.restore | ((rob_cp.tail > rob_head)?
        ((buffer[i].rob_addr < flush.tail) & (buffer[i].rob_addr >= rob_head)) :
        ((buffer[i].rob_addr < flush.tail) | (buffer[i].rob_addr >= rob_head))));
    
    out.rob_addr = buffer[ready_addr].rob_addr;
    out.alu_op = buffer[ready_addr].alu_op;
    out.immdt = buffer[ready_addr].immdt;
    out.ra_addr = buffer[ready_addr].ra_addr;
    out.use_rt = buffer[ready_addr].use_rt;
    out.rt_addr = buffer[ready_addr].rt_addr;
    out.rw_addr = buffer[ready_addr].rw_addr;
    out.rs_addr = buffer[ready_addr].rs_addr;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        buffer <= '{default:'0};
    end
    else begin
        if(~ctrl.reject & in.valid) begin
            buffer[open_addr].valid <= 1'b1;
            buffer[open_addr].rob_addr <= in.rob_addr;
            buffer[open_addr].alu_op <= in.alu_op;
            buffer[open_addr].immdt <= in.immdt;
            buffer[open_addr].ra_addr <= in.ra_addr;
            buffer[open_addr].use_rt <= in.use_rt;
            buffer[open_addr].rt_addr <= in.rt_addr;
            buffer[open_addr].rw_addr <= in.rw_addr;
            buffer[open_addr].rs_addr <= in.rs_addr;
        end
        if(~ctrl.retain & ready) begin
            buffer[ready_addr].valid <= 1'b0;
        end

        //If a branch is mispredicted, entries created after the branch must be flushed.
        if(rob_cp.restore) begin
            for(int i = 0; i < L; i++) begin
                buffer[i].valid <= buffer[i].valid & ((rob_cp.tail > rob_head)?
                    ((buffer[i].rob_addr < flush.tail) & (buffer[i].rob_addr >= rob_head)) :
                    ((buffer[i].rob_addr < flush.tail) | (buffer[i].rob_addr >= rob_head)));
            end
        end
    end
end
endmodule