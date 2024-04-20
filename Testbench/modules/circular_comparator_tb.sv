module circular_comparator_tb();
parameter N = 8;

logic [N-1:0] offset;
logic [N-1:0] a;
logic [N-1:0] b;
logic result;

circular_comparator#(.N(N)) cc
(
    .offset(offset),
    .in0(a),
    .in1(b),

    .result(result)
);

task test
(
    input logic expected,
    input logic actual
);
assert(actual == expected) begin
    $display("TEST PASSED");
end
else begin
    $display("TEST FAILED - Expected: %0b, Actual: %0b", expected, actual);
end
endtask

initial begin
    $display("\na before b, both after offset");
    for(int i = 0; i < 8; i++) begin
        offset = $urandom_range(0, (2**N)-2);
        a = $urandom_range(offset, (2**N)-2);
        b = $urandom_range(a+1, (2**N)-1);
        #10ns;
        $display("offset: %0d, a: %0d, b: %0d", offset, a, b);
        test(1'b0, result);
        #10ns;
    end

    $display("\nb before a, both after offset");
    for(int i = 0; i < 8; i++) begin
        offset = $urandom_range(0, (2**N)-2);
        b = $urandom_range(offset, (2**N)-2);
        a = $urandom_range(b+1, (2**N)-1);
        #10ns;
        $display("offset: %0d, a: %0d, b: %0d", offset, a, b);
        test(1'b1, result);
        #10ns;
    end

    $display("\na before b, both before offset");
    for(int i = 0; i < 8; i++) begin
        offset = $urandom_range(2, (2**N)-1);
        b = $urandom_range(1, offset);
        a = $urandom_range(0, b-1);
        #10ns;
        $display("offset: %0d, a: %0d, b: %0d", offset, a, b);
        test(1'b0, result);
        #10ns;
    end

    $display("\nb before a, both before offset");
    for(int i = 0; i < 8; i++) begin
        offset = $urandom_range(2, (2**N)-1);
        a = $urandom_range(1, offset);
        b = $urandom_range(0, a-1);
        #10ns;
        $display("offset: %0d, a: %0d, b: %0d", offset, a, b);
        test(1'b1, result);
        #10ns;
    end

    $display("\na before offset, b after offset");
    for(int i = 0; i < 8; i++) begin
        offset = $urandom_range(1, (2**N)-1);
        a = $urandom_range(0, offset-1);
        b = $urandom_range(offset, (2**N)-1);
        #10ns;
        $display("offset: %0d, a: %0d, b: %0d", offset, a, b);
        test(1'b1, result);
        #10ns;
    end

    $display("\nb before offset, a after offset");
    for(int i = 0; i < 8; i++) begin
        offset = $urandom_range(1, (2**N)-1);
        a = $urandom_range(offset, (2**N)-1);
        b = $urandom_range(0, offset-1);
        #10ns;
        $display("offset: %0d, a: %0d, b: %0d", offset, a, b);
        test(1'b0, result);
        #10ns;
    end
    $finish;
end
endmodule