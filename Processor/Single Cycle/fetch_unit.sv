module fetch_unit
(
    input logic clk,
    input logic n_rst,

    branch_controller_ifc.fetch_unit i_branch_controller,
    decoder_output_ifc.fetch_unit i_decoder,

    output logic unsigned [`PC_SIZE - 1 : 0] pc
);

always_ff @(posedge clk) begin
    if(~n_rst) begin
        pc <= 0;
    end
    else begin
        if(i_branch_controller.pc_override) begin
            pc <= pc - (i_branch_controller.pc_offset[15] << 15) + i_branch_controller.pc_offset[14 : 0];
        end
        else begin
            pc <= pc + 1;
        end
    end
end
endmodule