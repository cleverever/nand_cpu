`include "nand_cpu.svh"

interface memory_buffer_ifc;
logic valid;
logic rob_addr;
nand_cpu_pkg::MemOp mem_op;
logic raw_addr;
logic rt_addr;

modport in
(
    input valid, rob_addr, mem_op, raw_addr, rt_addr
);
modport out
(
    output valid, rob_addr, mem_op, raw_addr, rt_addr
);
endinterface

//Loads may occur out of order relative to other loads, but must wait for older stores.
//Stores are handled in order and must wait for older loads.
module memory_buffer
(
    input logic clk,
    input logic n_rst,

    buffer_ctrl_ifc.in sb_ctrl,
    buffer_ctrl_ifc.in lb_ctrl,
    output logic sb_full,
    output logic lb_full,

    sb_checkpoint.in sb_cp,
    rob_checkpoint.in rob_cp,
    input logic [$clog2(`ROB_LENGTH)-1:0] rob_head,

    input logic r_calculated_list [`NUM_D_REG],

    memory_buffer_ifc.in in,
    memory_buffer_ifc.out out
);

logic pop_sb;
logic pop_lb;

logic empty_sb;
logic empty_lb;

logic buffer_sel;

store_buffer_ifc sb_in();
load_buffer_ifc lb_in();

store_buffer_ifc sb_out();
load_buffer_ifc lb_out();

//Buffer input
always_comb begin
    sb_in.valid = in.valid & (in.mem_op == MEM_WRITE);
    sb_in.rob_addr = in.rob_addr;
    sb_in.ra_addr = in.raw_addr;
    sb_in.rt_addr = in.rt_addr;

    lb_in.valid = in.valid & (in.mem_op == MEM_READ);
    lb_in.rob_addr = in.rob_addr;
    lb_in.rt_addr = in.rt_addr;
    lb_in.rw_addr = in.raw_addr;
end

store_buffer#(.L(`ST_B_LENGTH)) sb
(
    .clk,
    .n_rst,

    .ctrl(sb_ctrl),

    .checkpoint(sb_cp),

    .r_calculated_list(r_calculated_list),
    
    .pop(pop_sb),
    .full(sb_full),
    .empty(empty_sb),

    .in(sb_in),
    .out(sb_out)
);

load_buffer#(.L(`LD_B_LENGTH)) lb
(
    .clk,
    .n_rst,

    .ctrl(lb_ctrl),

    .rob_cp(rob_cp),
    .rob_head(rob_head),
    
    .sb_rob_address(sb_out.rob_addr),

    .r_calculated_list(r_calculated_list),

    .pop(pop_lb),
    .full(lb_full),
    .empty(empty_lb),

    .in(lb_in),
    .out(lb_out)
);

circular_comparator#(.N($clog2(`ROB_LENGTH))) cc
(
    .offset(rob_head),
    .in0(sb_out.rob_addr),
    .in1(lb_out.rob_addr),

    .result(buffer_sel)
);

task select_sb();
pop_sb = sb_out.valid;
pop_lb = 1'b0;

out.valid = sb_out.valid;
out.rob_addr = sb_out.rob_addr;
out.mem_op = MEM_WRITE;
out.raw_addr = sb_out.ra_addr;
out.rt_addr = sb_out.rt_addr;
endtask

task select_lb();
pop_sb = 1'b0;
pop_lb = lb_out.valid;

out.valid = lb_out.valid;
out.rob_addr = lb_out.rob_addr;
out.mem_op = MEM_READ;
out.raw_addr = lb_out.rw_addr;
out.rt_addr = lb_out.rt_addr;
endtask

always_comb begin
    //If both store and load buffer have entries, must compare rob addresses to determine which is older.
    //Due to circular queue in rob, address comparison involves checking for wrapping.
    case({empty_sb, empty_lb})
        2'b00: begin
            if(buffer_sel) begin
                select_lb();
            end
            else begin
                select_sb();
            end
        end

        //If one buffer is empty, no checking is required.
        2'b01: begin
            select_sb();
        end
        2'b10: begin
            select_lb();
        end

        //If both buffers are empty, output is invalid.
        2'b11: begin
            out.valid = 1'b0;
        end
    endcase
end
endmodule