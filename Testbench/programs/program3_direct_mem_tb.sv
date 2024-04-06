module program3_tb();

logic clk;
logic pwr;
logic done;

nand_cpu DUT
(
    .clk(clk),
    .n_rst(pwr),

    .halt(done)
);

logic correct;

task test
(
    logic unsigned [15 : 0] op0
);
    pwr = 1'b0;
    #40ns;
    pwr = 1'b1;
    DUT.D_MEM.core[0] = op0;
    wait(done);
    correct = 1'b1;
    for(int i = 1; i < op0 + 1; i++) begin
        correct = correct & (DUT.D_MEM.core[i] == i[15 : 0]);
    end
    assert (correct) begin
        $display("TEST PASSED - Count to %d", op0);
    end
    else begin
        $display("TEST FAILED - Count to %d", op0);
    end
endtask

initial begin
    clk = 1'b0;
    $readmemb("../../Testbench/count_to.bin", DUT.I_MEM.core);
    for(int i = 0; i < 10; i++)
    begin
        test(i[15 : 0]);
    end
    $finish;
end

always begin
    clk <= ~clk;
    #10ns;
end
endmodule