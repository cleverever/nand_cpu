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

int sum;
int op0;
int op1;

initial begin
    clk = 1'b0;
    $readmemb("add_short.bin", DUT.I_MEM.core);
    sum = $random_range(-32768, 32767);
    op0 = $random_range(-32768, 32767);
    op1 = sum - op0;
    DUT.D_MEM.core[0] = op0[7 : 0];
    DUT.D_MEM.core[1] = op0[15 : 8];
    DUT.D_MEM.core[2] = op1[7 : 0];
    DUT.D_MEM.core[3] = op1[15 : 8];
    pwr = 1'b0;
    #20ns;
    pwr = 1'b1;
end

always @(posedge done) begin
    assert (DUT.D_MEM.core[4] == sum[7 : 0] & DUT.D_MEM.core[5] == sum[15 : 8]) begin
        $display("TEST PASSED");
    end
    else begin
        $display("TEST FAILED");
        $display("Expected sum: " + sum);
        $display("Actual sum:   " + {DUT.D_MEM.core[5], DUT.D_MEM.core[4]});
    end
    $finish;
end

always begin
    clk <= ~clk;
    #10ns;
end
endmodule