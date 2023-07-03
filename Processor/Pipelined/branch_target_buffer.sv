`include "nand_cpu.svh"

module branch_target_buffer
(
    input logic clk,
    input logic n_rst,

    input logic [`PC_SIZE - 1 : 0] pc,

    output logic hit,
    output logic branch,
    output logic [`PC_SIZE - 1 : 0] target,

    input logic feedback_valid,
    branch_feedback_ifc.in i_feedback
);

typedef struct packed
{
    logic valid;
    logic [(`PC_SIZE - `BTB_PC_BITS) - 1 : 0] tag;
    logic branch;
    logic [`PC_SIZE - 1 : 0] target;
}
BTB_Entry;

BTB_Entry cache [2 ^ `BTB_PC_BITS];

logic [`BTB_PC_BITS - 1 : 0] sel;
logic [(`PC_SIZE - `BTB_PC_BITS) - 1 : 0] sel_tag;

logic [`BTB_PC_BITS - 1 : 0] fb_sel;
logic [(`PC_SIZE - `BTB_PC_BITS) - 1 : 0] fb_sel_tag;

always_comb begin
    sel = pc[`BTB_PC_BITS - 1 : 0];
    sel_tag = pc[`PC_SIZE - 1 : `BTB_PC_BITS];

    fb_sel = i_feedback.pc[`BTB_PC_BITS - 1 : 0];
    fb_sel_tag = i_feedback.pc[`PC_SIZE - 1 : `BTB_PC_BITS];
    
    hit = cache[sel].valid & (cache[sel].tag == sel_tag);
    branch = cache[sel].branch;
    target = cache[sel].target;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        cache <= {default:'0};
    end
    else begin
        if(feedback_valid) begin
            cache[fb_sel].valid <= 1'b1;
            cache[fb_sel].tag <= fb_sel_tag;
            cache[fb_sel].target <= i_feedback.feedback_target;
        end
    end
end
endmodule