`include "nand_cpu.svh"

interface btb_output_ifc;
logic hit;
logic [`PC_SIZE - 1 : 0] target;

modport in
(
    input pc_override, target
);
modport out
(
    output pc_override, target
);
endinterface

interface branch_ctrl_feedback_ifc;
logic hit;
logic [`PC_SIZE - 1 : 0] target;

modport in
(
    input hit, target
);
modport out
(
    output hit, target
);
endinterface

module branch_target_buffer
(
    input logic clk,
    input logic n_rst,

    branch_ctrl_feedback_ifc.in feedback,

    input logic [`PC_SIZE - 1 : 0] pc,
    btb_output_ifc.out out
);

typedef struct packed
{
    logic valid;
    logic [(`PC_SIZE - `BTB_PC_BITS) - 1 : 0] tag;
    logic [`PC_SIZE - 1 : 0] target;
} BTB_Entry;

BTB_Entry cache [2 ^ `BTB_PC_BITS];

logic [`BTB_PC_BITS - 1 : 0] sel;
logic [(`PC_SIZE - `BTB_PC_BITS) - 1 : 0] sel_tag;

logic [`BTB_PC_BITS - 1 : 0] fb_sel;
logic [(`PC_SIZE - `BTB_PC_BITS) - 1 : 0] fb_sel_tag;

always_comb begin
    sel = pc[`BTB_PC_BITS - 1 : 0];
    sel_tag = pc[`PC_SIZE - 1 : `BTB_PC_BITS];

    fb_sel = i_pr_pass.pc[`BTB_PC_BITS - 1 : 0];
    fb_sel_tag = i_pr_pass.pc[`PC_SIZE - 1 : `BTB_PC_BITS];
    
    out.hit = cache[sel].valid & (cache[sel].tag == sel_tag);
    out.target = cache[sel].target;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        cache <= {default:'0};
    end
    else begin
        if(feedback.valid & feedback.pc_override) begin
            cache[fb_sel].valid <= 1'b1;
            cache[fb_sel].tag <= fb_sel_tag;
            cache[fb_sel].target <= feedback.target;
        end
    end
end
endmodule