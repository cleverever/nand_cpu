module circular_queue #(parameter type T, parameter L)
(
    input logic clk,
    input logic n_rst,

    input logic push,
    input T in,

    input logic pop,
    output T out
);

T values [L];
logic unsigned [$clog2(L)-1 : 0] head;
logic unsigned [$clog2(L)-1 : 0] tail;

always_ff @(posedge clk) begin
    if(~n_rst) begin
        values <= {default:'0};
        head <= 0;
        tail <= 0;
    end
    else begin
        if(push) begin
            values[tail] <= in;
            tail <= (tail + 1) % L;
        end
        if(pop) begin
            head <= (head + 1) % L;
        end
    end
end

always_comb begin
    out = values[head];
end
endmodule