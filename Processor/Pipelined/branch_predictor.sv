`include "nand_cpu.svh"

interface branch_predictor_output_ifc;
logic pc_override;
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

module branch_predictor #(parameter TYPE = GSHARE)
(
    input logic clk,
    input logic n_rst,
    
    input logic [`PC_SIZE - 1 : 0] pc,
    input logic ps,

    branch_predictor_output_ifc.out out,

    branch_feedback_ifc.in i_feedback
);

branch_request_ifc request();
logic hit;
logic branch;
logic taken;

branch_target_buffer BRANCH_TARGET_BUFFER
(
    .clk,
    .n_rst,
    
    .i_feedback(i_feedback),

    .pc(pc),

    .hit(hit),
    .branch(branch),
    .target(target)
);

always_comb begin
    request.pc = pc;
    request.target = target;
    request.ps = ps;

    out.pc_override = hit & (~branch | taken);
    out.target = target;
end

generate
    case(TYPE)
        GSHARE : branch_predictor_gshare #(INDEX_SIZE = 6) predictor
        (
            .clk,
            .n_rst,

            .request(request),

            .taken(taken),

            .feedback(feedback)
        );
    endcase
endgenerate
endmodule

module branch_predictor_gshare #(parameter INDEX_SIZE = 6)
(
    input logic clk,
    input logic n_rst,

    branch_request_ifc.in request,

    output logic taken,

    branch_feedback_ifc.in feedback
);

logic [INDEX_SIZE - 1 : 0] history;

logic [INDEX_SIZE - 1 : 0] index;
logic [INDEX_SIZE - 1 : 0] fb_index;

logic [1 : 0] pht [2 ^ INDEX_SIZE];

always_comb begin
    index = history ^ request.pc[INDEX_SIZE - 1 : 0];
    taken = pht[index][1];

    fb_index = history ^ feedback.pc[INDEX_SIZE - 1 : 0];
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        history <= '0;
        pht <= {default:2'b01};
    end
    else begin
        history <= {history[INDEX_SIZE - 2 : 0], taken};
        if(feedback.valid) begin
            if(feedback.feedback_taken) begin
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