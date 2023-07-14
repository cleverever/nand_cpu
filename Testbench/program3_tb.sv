`include "nand_cpu.svh"

module program3_tb();

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

logic correct;
logic [DUT.D_CACHE.OFFSET_BITS - 1 : 0] offset;
logic [DUT.D_CACHE.INDEX_BITS - 1 : 0] index;
logic [DUT.D_CACHE.TAG_BITS - 1 : 0] tag;

task test
(
    logic unsigned [15 : 0] op0
);
    pwr = 1'b0;
    #40ns;
    pwr = 1'b1;
    DUT.MEMORY.core[DATA_OFFSET][15 : 0] = op0;
    wait(done);
    correct = 1'b1;
    for(int i = 1; i < op0 + 1; i++) begin
        offset = i[DUT.D_CACHE.OFFSET_BITS - 1 : 0];
        index = i[DUT.D_CACHE.INDEX_BITS + DUT.D_CACHE.OFFSET_BITS - 1 : DUT.D_CACHE.OFFSET_BITS];
        tag = i[DUT.D_CACHE.TAG_BITS + DUT.D_CACHE.INDEX_BITS + DUT.D_CACHE.OFFSET_BITS - 1 : DUT.D_CACHE.INDEX_BITS + DUT.D_CACHE.OFFSET_BITS];
        correct = correct & ((DUT.MEMORY.core[i / (16 / `CACHE_BLOCK_SIZE)][(i % (16 / `CACHE_BLOCK_SIZE)) * 16 +: 16] == i[15 : 0]) |
        (DUT.D_CACHE.lines[index].valid &
        DUT.D_CACHE.lines[index].tag == tag &
        DUT.D_CACHE.lines[index].data[offset * 16 +: 16] == i[15 : 0]));
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
    machine_code = '{default:'0};
    $readmemb("../../Testbench/count_to.bin", machine_code);
    DUT.MEMORY.core = {>>`CACHE_BLOCK_SIZE{machine_code}};

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