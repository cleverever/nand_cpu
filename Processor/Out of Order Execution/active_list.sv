module active_list
(
    input logic clk,
    input logic n_rst,

    input logic enqueue,
    input logic use_rw;
    input logic rw_addr;
    input logic ps_write;
    input logic ps_addr;

    output logic reg_return,
    output logic r_reg,

    output logic ps_return,
    output logic r_ps
);

typedef struct packed
{
    logic complete;
    logic use_rw;
    logic rw_addr;
    logic ps_write;
    logic ps_addr;
}
ALEntry;

ALEntry queue [`AL_SIZE];
logic unsigned head;
logic unsigned tail;

always_ff @(posedge clk) begin
    if(~n_rst) begin
        queue <= {default:'0};
        head <= 0;
        tail <= 0;
    end
    if(queue[head].complete) begin
        head <= (head + 1) % `AL_SIZE;
    end
    if(enqueue) begin
        queue[tail] <= '{
            complete : 1'b0,
            use_rw : use_rw,
            rw_addr : rw_addr,
            ps_write : ps_write,
            ps_addr : ps_addr
        };
        tail <= (tail + 1) % `AL_SIZE;
    end
end

always_comb begin
    reg_return = queue[head].complete & queue[head].use_rw;
    r_reg = queue[head].rw_addr;

    ps_return = queue[head].complete & queue[head].ps_write;
    r_ps = queue[head].ps_addr;
end
endmodule