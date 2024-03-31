module circular_queue_tb();

logic clk;
logic n_rst;

logic push;
logic unsigned [7 : 0] in;

logic pop;
logic unsigned [7 : 0] out;

circular_queue #(.T(logic [7 : 0]), .L(8)) cq
(
    .clk(clk),
    .n_rst(n_rst),

    .push(push),
    .in(in),

    .pop(pop),
    .out(out)
);

logic unsigned [7 : 0] tests [4];
logic unsigned [7 : 0] temp;

initial begin
    for(int i = 0; i < 4; i++) begin
        tests[i] <= $urandom_range(0, 255);
    end
    clk = 1'b0;
    n_rst <= 1'b0;
    push <= 1'b0;
    in <= 0;
    pop <= 1'b0;
    #5ns;

    n_rst <= 1'b1;
    #10ns;

    enqueue(tests[0]);
    #10ns;

    push <= 1'b0;

    dequeue();
    #10ns;
    check(temp, tests[0]);

    pop <= 1'b0;

    enqueue(tests[1]);
    #10ns;

    enqueue(tests[2]);
    #10ns;

    push <= 1'b0;

    dequeue();
    #10ns;
    check(temp, tests[1]);

    pop <= 1'b0;

    enqueue(tests[3]);
    #10ns;

    push <= 1'b0;

    dequeue();
    #10ns;
    check(temp, tests[2]);

    dequeue();
    #10ns;
    check(temp, tests[3]);
    $finish;
end

task enqueue
(
    input logic [7 : 0] value
);
    push <= 1'b1;
    in <= value;
endtask

task dequeue();
    pop <= 1'b1;
    temp <= out;
endtask

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