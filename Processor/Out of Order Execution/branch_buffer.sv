`include "nand_cpu.svh"

interface branch_buffer_ifc;
logic valid;
logic rob_addr;
logic jump;
logic predict_taken;
logic [`PC_SIZE-1:0] pc;
logic [`PC_SIZE-1:0] predict_target;
logic [$clog2(`NUM_D_REG)-1:0] rt_addr;
logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
logic [$clog2(`NUM_S_REG)-1:0] rs_addr;

logic r_free_list_cp [`NUM_D_REG];
logic s_free_list_cp [`NUM_S_REG];
logic [$clog2(`NUM_D_REG)-1:0] d_translation_cp [16];
logic [$clog2(`NUM_S_REG)-1:0] s_translation_cp;

modport in
(
    input valid, rob_addr, jump, predict_taken, pc, predict_target, rt_addr, rw_addr, rs_addr
);
modport out
(
    output valid, rob_addr, jump, predict_taken, pc, predict_target, rt_addr, rw_addr, rs_addr
);
endinterface

module branch_buffer #(parameter L = 8)
(
    input logic clk,
    input logic n_rst,

    input logic r_calculated_list [`NUM_D_REG],
    input logic s_calculated_list [`NUM_S_REG],

    branch_buffer_ifc.in in,
    branch_buffer_ifc.out out
);

typedef struct packed
{
    logic valid;
    logic rob_addr;
    logic jump;
    logic predict_taken;
    logic [`PC_SIZE-1:0] pc;
    logic [`PC_SIZE-1:0] predict_target;
    logic [$clog2(`NUM_D_REG)-1:0] rt_addr;
    logic rt_ready;
    logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
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
        buffer[i].rt_ready = r_calculated_list[buffer[i].rt_addr];
        buffer[i].rs_ready = s_calculated_list[buffer[i].rs_addr];
        buffer[i].ready = buffer[i].valid & buffer[i].rt_ready & (buffer[i].jump | buffer[i].rs_ready);
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
    out.rob_addr = buffer[ready_addr].rob_addr;
    out.jump = buffer[ready_addr].jump;
    out.predict_taken = buffer[ready_addr].predict_taken;
    out.pc = buffer[ready_addr].pc;
    out.predict_target = buffer[ready_addr].predict_target;
    out.rt_addr = buffer[ready_addr].rt_addr;
    out.rw_addr = buffer[ready_addr].rw_addr;
    out.rs_addr = buffer[ready_addr].rs_addr;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        buffer <= '{default:'0};
    end
    else begin
    end
end
endmodule