module m2w_pr
(
    input logic clk,
    input logic n_rst,

    writeback_ifc.in in,
    writeback_ifc.in out
);

always_ff @(posedge clk) begin
    if(~n_rst) begin
        out.valid <= 1'b0;
    end
    else begin
        out.valid <= in.valid;
        out.reg_addr <= in.reg_addr;
        out.data <= in.data;
    end
end
endmodule