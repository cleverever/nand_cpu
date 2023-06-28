module program2_tb();

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
    logic signed [15 : 0] op0,
    logic signed [15 : 0] op1
);
    pwr = 1'b0;
    #40ns;
    pwr = 1'b1;
    DUT.D_MEM.core[0] = op0[7 : 0];
    DUT.D_MEM.core[1] = op0[15 : 8];
    DUT.D_MEM.core[2] = op1[7 : 0];
    DUT.D_MEM.core[3] = op1[15 : 8];
    wait(done);
    assert (DUT.D_MEM.core[4][0] == (op0 < op1)) begin
        $display("TEST PASSED - %d < %d", op0, op1);
    end
    else begin
        $display("TEST FAILED - %d < %d", op0, op1);
        $display("Expected: %s", (op0 < op1)? "true" : "false");
        $display("Actual:   %s", (DUT.D_MEM.core[4][0])? "true" : "false");
    end
endtask

logic signed [15 : 0] op0;
logic signed [15 : 0] op1;
logic equal;

initial begin
    clk = 1'b0;
    $readmemb("less_than_short.bin", DUT.I_MEM.core);

    for(int i = 0; i < 64; i++)
    begin
        equal = ($urandom_range(0, 3) == 0);
        op0 = $urandom_range(0, 65535);
        if(equal) begin
            op1 = op0;
        end
        else begin
            op1 = $urandom_range(0, 65535);
        end
        test(op0, op1);
    end
    $finish;
end

always begin
    clk <= ~clk;
    #10ns;
end
endmodule