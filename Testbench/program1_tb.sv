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

task test
(
    logic [15 : 0] op0,
    logic [15 : 0] op1,
    logic [15 : 0] sum
);
    pwr = 1'b0;
    #40ns;
    pwr = 1'b1;
    DUT.D_MEM.core[0] = op0;
    DUT.D_MEM.core[1] = op1;
    wait(done);
    assert (DUT.D_MEM.core[2] == sum) begin
        $display("TEST PASSED - %d + %d", op0, op1);
    end
    else begin
        $display("TEST FAILED - %d + %d", op0, op1);
        $display("Expected sum: %0b", sum);
        $display("Actual sum:   %0b", {DUT.D_MEM.core[5], DUT.D_MEM.core[4]});
    end    
endtask

logic [15 : 0] sum;
logic [15 : 0] op0;
logic [15 : 0] op1;

initial begin
    clk = 1'b0;
    $readmemb("../../Testbench/add_short.bin", DUT.I_MEM.core);

    for(int i = 0; i < 64; i++)
    begin
        sum = $urandom_range(0, 65535);
        op0 = $urandom_range(0, 65535);
        op1 = sum - op0;
        test(op0, op1, sum);
    end
    $finish;
end

always begin
    clk <= ~clk;
    #10ns;
end
endmodule