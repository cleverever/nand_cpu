`include "nand_cpu.svh"

module program1_tb();

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
    logic [15 : 0] op0,
    logic [15 : 0] op1,
    logic [15 : 0] sum
);
    pwr = 1'b0;
    #40ns;
    pwr = 1'b1;
    DUT.MEMORY.core[DATA_OFFSET][31 : 0] = {op0, op1};
    wait(done);
    assert (DUT.MEMORY.core[DATA_OFFSET][47 : 32] == sum) begin
        $display("TEST PASSED - %d + %d", op0, op1);
    end
    else begin
        $display("TEST FAILED - %d + %d", op0, op1);
        $display("Expected sum: %0b", sum);
        $display("Actual sum:   %0b", DUT.MEMORY.core[DATA_OFFSET][47 : 32]);
    end
endtask

logic [15 : 0] sum;
logic [15 : 0] op0;
logic [15 : 0] op1;

initial begin
    clk = 1'b0;
    machine_code = '{default:'0};
    $readmemb("../../Testbench/add_short.bin", machine_code);
    DUT.MEMORY.core = {>>`CACHE_BLOCK_SIZE{machine_code}};

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