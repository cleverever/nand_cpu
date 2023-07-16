`include "nand_cpu.svh"

module free_list
(
    input logic clk,
    input logic n_rst,

    input logic reg_return,
    input logic [$clog2(`NUM_REG) - 1 : 0] r_reg,

    input logic ps_return,
    input logic [$clog2(`NUM_PS) - 1 : 0] r_ps,

    input logic reg_checkout,
    output logic [$clog2(`NUM_REG) - 1 : 0] c_reg,

    input logic ps_checkout,
    output logic [$clog2(`NUM_PS) - 1 : 0] c_ps
);

logic [$clog2(`NUM_REG) - 1 : 0] reg_queue [`NUM_REG];
logic [$clog2(`NUM_REG) - 1 : 0] reg_head;
logic [$clog2(`NUM_REG) - 1 : 0] reg_tail;

logic [$clog2(`NUM_PS) - 1 : 0] ps_queue [`NUM_PS];
logic [$clog2(`NUM_PS) - 1 : 0] ps_head;
logic [$clog2(`NUM_PS) - 1 : 0] ps_tail;

always_ff @(posedge clk) begin
    if(~n_rst) begin
        for(int i = 0; i < `NUM_REG; i++) begin
            reg_queue[i] <= i;
        end
        for(int i = 0; i < `NUM_PS; i++) begin
            ps_queue[i] <= i;
        end
        reg_head <= 0;
        reg_tail <= 0;
        ps_head <= 0;
        ps_tail <= 0;
    end
    else begin
        if(reg_return) begin
            reg_queue[reg_tail] <= r_reg;
            reg_tail <= (reg_tail + 1) % `NUM_REG;
        end
        if(ps_return) begin
            ps_queue[ps_tail] <= r_ps;
            ps_tail <= (ps_tail + 1) % `NUM_PS;
        end
        if(reg_checkout) begin
            reg_head <= (reg_head + 1) % `NUM_REG;
        end
        if(ps_checkout) begin
            ps_head <= (ps_head + 1) % `NUM_PS;
        end
    end
end

always_comb begin
    c_reg = reg_queue[reg_head];
    c_ps = ps_queue[ps_head];
end
endmodule