module program1_tb();

logic clk;
logic pwr;
logic done;

nand_cpu DUT
(
    .clk(clk),
    .n_rst(pwr),

    .halt(done)
);

logic [15 : 0] sum;
logic [15 : 0] op0;
logic [15 : 0] op1;

initial begin
    clk = 1'b0;
    $readmemb("add_short.bin", DUT.I_MEM.core);
    sum = $urandom_range(0, 65535);
    op0 = $urandom_range(0, 65535);
    op1 = sum - op0;
    pwr = 1'b0;
    #20ns;
    pwr = 1'b1;
    DUT.D_MEM.core[0] = op0[7 : 0];
    DUT.D_MEM.core[1] = op0[15 : 8];
    DUT.D_MEM.core[2] = op1[7 : 0];
    DUT.D_MEM.core[3] = op1[15 : 8];
end

always @(posedge done) begin
    assert (DUT.D_MEM.core[4] == sum[7 : 0] & DUT.D_MEM.core[5] == sum[15 : 8]) begin
        $display("TEST PASSED");
    end
    else begin
        $display("TEST FAILED");
        $display("Expected sum: %0b", sum);
        $display("Actual sum:   %0b", {DUT.D_MEM.core[5], DUT.D_MEM.core[4]});
    end
    $finish;
end

always begin
    clk <= ~clk;
    #10ns;
end
endmodule