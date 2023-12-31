`include "nand_cpu.svh"

module program2_tb();

logic clk;
logic pwr;
logic done;

localparam MEM_WIDTH = (`PC_SIZE - 1 > 16)? `PC_SIZE : 17;
localparam INSTR_OFFSET = 0;
localparam BYTES = (2 ** (MEM_WIDTH + 1));
localparam DATA_OFFSET = 2 ** (MEM_WIDTH - $clog2(`CACHE_BLOCK_SIZE / 16) - 1);
logic [7 : 0] machine_code [BYTES / 2];

nand_cpu DUT
(
    .clk(clk),
    .n_rst(pwr),

    .halt(done)
);

logic [7 : 0] core_b [BYTES];
assign core_b = {>>{DUT.MEMORY.core}};

task test
(
    logic signed [15 : 0] op0,
    logic signed [15 : 0] op1
);
    pwr = 1'b0;
    #40ns;
    pwr = 1'b1;
    DUT.MEMORY.core[DATA_OFFSET][31 : 0] = {op1, op0};
    wait(done);
    assert ((DUT.MEMORY.core[DATA_OFFSET][32] == (op0 < op1)) | (DUT.D_CACHE.lines[0].valid & DUT.D_CACHE.lines[0].tag == 4'b0000 & DUT.D_CACHE.lines[0].data[32] == (op0 < op1))) begin
        $display("TEST PASSED - %d < %d", op0, op1);
    end
    else begin
        $display("TEST FAILED - %d < %d", op0, op1);
        $display("Expected: %s", (op0 < op1)? "true" : "false");
        $display("Actual:   %s", ((DUT.D_CACHE.lines[0].valid & DUT.D_CACHE.lines[0].tag == 4'b0000)? DUT.D_CACHE.lines[0].data[32] : DUT.MEMORY.core[DATA_OFFSET][32])? "true" : "false");
    end
endtask

logic signed [15 : 0] op0;
logic signed [15 : 0] op1;
logic equal;

initial begin
    clk = 1'b0;
    machine_code = '{default:'0};
    $readmemb("../../Testbench/less_than_short.bin", machine_code);
    DUT.MEMORY.core = {>>`CACHE_BLOCK_SIZE{machine_code}};

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