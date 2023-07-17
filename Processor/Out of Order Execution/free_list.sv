`include "nand_cpu.svh"

module free_list
(
    input logic clk,
    input logic n_rst,

    input logic stall,

    input logic reg_return,
    input logic [$clog2(`NUM_REG) - 1 : 0] r_reg,

    input logic ps_return,
    input logic [$clog2(`NUM_PS) - 1 : 0] r_ps,

    input logic reg_checkout,
    output logic [$clog2(`NUM_REG) - 1 : 0] c_reg,

    input logic ps_checkout,
    output logic [$clog2(`NUM_PS) - 1 : 0] c_ps
);

logic reg_free [`NUM_REG];

logic ps_free [`NUM_PS];

always_ff @(posedge clk) begin
    if(~n_rst) begin
        for(int i = 0; i < `NUM_REG; i++) begin
            reg_free[i] <= 1'b0;
        end
        for(int i = 0; i < `NUM_PS; i++) begin
            ps_free[i] <= 1'b0;
        end
    end
    else begin
        if(~stall) begin
            if(reg_return) begin
                reg_free[r_reg] <= 1'b1;
            end
            if(ps_return) begin
                ps_free[r_ps] <= 1'b1;
            end
            if(reg_checkout) begin
                reg_free[c_reg] <= 1'b0;
            end
            if(ps_checkout) begin
                ps_free[c_ps] <= 1'b0;
            end
        end
    end
end

always_comb begin
    for(int i = `NUM_REG - 1; i >= 0; i--) begin
        if(reg_free[i]) begin
            c_reg = i;
        end
    end
    for(int i = `NUM_PS - 1; i >= 0; i--) begin
        if(ps_free[i]) begin
            c_ps = i;
        end
    end
end
endmodule