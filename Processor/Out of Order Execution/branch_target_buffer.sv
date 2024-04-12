`include "nand_cpu.svh"

module branch_target_buffer
(
    input logic clk,
    input logic n_rst,

    input logic [`PC_SIZE-1:0] pc,

    branch_valid_ifc.in branch_valid_in,
    branch_outcome_ifc.in branch_outcome_in,

    output logic hit,
    output logic [`PC_SIZE-1:0] target
);

typedef struct packed
{
    logic valid;
    logic [(`PC_SIZE-`BTB_PC_BITS)-1:0] tag;
    logic [`PC_SIZE-1:0] target;
}
BTB_Entry;

BTB_Entry cache [2**`BTB_PC_BITS];

logic [`BTB_PC_BITS-1:0] sel;
logic [(`PC_SIZE-`BTB_PC_BITS)-1:0] sel_tag;

logic [`BTB_PC_BITS-1:0] v_sel;
logic [(`PC_SIZE-`BTB_PC_BITS)-1:0] v_sel_tag;

logic [`BTB_PC_BITS-1:0] o_sel;
logic [(`PC_SIZE-`BTB_PC_BITS)-1:0] o_sel_tag;

always_comb begin
    sel = pc[`BTB_PC_BITS-1:0];
    sel_tag = pc[`PC_SIZE-1:`BTB_PC_BITS];

    v_sel = branch_valid_in.pc[`BTB_PC_BITS-1:0];
    v_sel_tag = branch_valid_in.pc[`PC_SIZE-1:`BTB_PC_BITS];

    o_sel = branch_outcome_in.pc[`BTB_PC_BITS-1:0];
    o_sel_tag = branch_outcome_in.pc[`PC_SIZE-1:`BTB_PC_BITS];
    
    hit = cache[sel].valid & (cache[sel].tag == sel_tag);
    target = cache[sel].target;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        cache <= {default:'0};
    end
    else begin
        if(branch_valid_in.valid) begin
            if(~cache[v_sel].valid || (cache[v_sel].tag == v_sel_tag)) begin
                cache[v_sel].valid <= branch_valid_in.branch;
            end
            if(branch_valid_in.branch) begin
                cache[v_sel].tag <= v_sel_tag;
            end
        end
        if(branch_outcome_in.valid) begin
            cache[o_sel].target <= branch_outcome_in.target;
        end
    end
end
endmodule