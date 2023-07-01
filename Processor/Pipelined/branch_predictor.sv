`include "nand_cpu.svh"

module branch_predictor_gshare #(parameter INDEX_SIZE = 6)
(
    input logic clk,
    input logic n_rst,

    branch_feedback_ifc.in feedback,
    branch_prediction_ifc.in data,

    output logic taken
);

logic [INDEX_SIZE - 1 : 0] history;

logic [INDEX_SIZE - 1 : 0] index;
logic [INDEX_SIZE - 1 : 0] fb_index;

logic [1 : 0] pht [2 ^ INDEX_SIZE];

always_comb begin
    index = history ^ data.pc[INDEX_SIZE - 1 : 0];
    taken = pht[index][1]

    fb_index = history ^ feedback.pc[INDEX_SIZE - 1 : 0];
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        history <= '0;
        pht <= {default:2'b01};
    end
    else begin
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