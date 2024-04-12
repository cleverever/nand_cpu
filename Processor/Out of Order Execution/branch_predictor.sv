`include "nand_cpu.svh"

typedef enum
{
    GSHARE
}
PredictorType;

interface branch_valid_ifc;
logic valid;
logic [`PC_SIZE-1:0] pc;
logic branch;

modport in
{
    input valid, pc, branch
};
modport out
{
    output valid, pc, branch
};
endinterface

interface branch_outcome_ifc;
logic valid;
logic [`PC_SIZE-1:0] pc;
logic taken;
logic [`PC_SIZE-1:0] target;
endinterface

interface branch_predictor_output_ifc;
logic pc_override;
logic [`PC_SIZE-1:0] target;

modport in
(
    input pc_override, target
);
modport out
(
    output pc_override, target
);
endinterface

module branch_predictor #(parameter TYPE = GSHARE)
(
    input logic clk,
    input logic n_rst,
    
    input logic [`PC_SIZE-1:0] pc,

    branch_predictor_output_ifc.out out,

    branch_valid_ifc.in branch_valid_in,
    branch_outcome_ifc.in branch_outcome_in
);

logic [`PC_SIZE-1:0] target;
logic hit;
logic taken;

branch_target_buffer BRANCH_TARGET_BUFFER
(
    .clk,
    .n_rst,

    .pc(pc),

    .branch_valid_in(branch_valid_in),
    .branch_outcome_in(branch_outcome_in),

    .hit(hit),
    .target(target)
);

always_comb begin
    out.pc_override = hit & taken;
    out.target = target;
end

generate
    case(TYPE)
        GSHARE : branch_predictor_gshare #(.INDEX_SIZE(6)) predictor
        (
            .clk,
            .n_rst,

            .pc(pc),
            .target(target),

            .branch_outcome_in(branch_outcome_in),
            
            .taken(taken)
        );
    endcase
endgenerate
endmodule

module branch_predictor_gshare #(parameter INDEX_SIZE = 6)
(
    input logic clk,
    input logic n_rst,

    input logic [`PC_SIZE-1:0] pc,
    input logic [`PC_SIZE-1:0] target,

    branch_outcome_ifc.in branch_outcome_in,

    output logic taken
);

logic [INDEX_SIZE-1:0] history;

logic [INDEX_SIZE-1:0] index;
logic [INDEX_SIZE-1:0] fb_index;

logic [1:0] pht [2**INDEX_SIZE];

always_comb begin
    index = history ^ pc[INDEX_SIZE-1:0];
    taken = pht[index][1];

    fb_index = history ^ branch_outcome_in.pc[INDEX_SIZE-1:0];
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        history <= '0;
        pht <= {default:2'b01};
    end
    else begin
        if(branch_outcome_in.valid) begin
            history <= {history[INDEX_SIZE-2:0], branch_outcome_in.taken};
            if(branch_outcome_in.taken) begin
                if(pht[fb_index] < 3) begin
                    pht[fb_index] <= pht[fb_index] + 1;
                end
            end
            else begin
                if(pht[fb_index] > 0) begin
                    pht[fb_index] <= pht[fb_index] - 1;
                end
            end
        end
    end
end
endmodule