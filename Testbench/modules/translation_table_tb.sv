module translation_table_tb();

logic clk;
logic n_rst;

task check
(
    logic [7 : 0] a,
    logic [7 : 0] b
);

assert(a == b) begin
    $display("TEST PASSED");
end
else begin
    $display("TEST FAILED");
end
endtask

always begin
    clk <= ~clk;
    #5ns;
end
endmodule