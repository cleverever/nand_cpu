`include "nand_cpu.svh"

module free_reg_list
(
    input logic clk,
    input logic n_rst,

    input logic checkin,
    input logic [$clog2(`NUM_REG)-1 : 0] in,

    input logic checkout,
    output logic [$clog2(`NUM_REG)-1 : 0] out
);

typedef enum {REG_IDLE, REG_BUSY} REG_STATE;
REG_STATE reg_list [`NUM_REG];

logic [$clog2(`NUM_REG)-1 : 0] reg_free;

always_comb begin
    for(int i = `NUM_REG - 1; i >= 0; i--) begin
        if(reg_list[i] == REG_IDLE) begin
            reg_free = i;
        end
    end
    if(checkout) begin
        if(checkin) begin
            out = in;
        end
        else begin
            out = reg_free;
        end
    end
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        for(int i = 0; i < `NUM_REG; i++) begin
            reg_list <= REG_IDLE;
        end
    end
    else begin
        case({checkin, checkout})
            2'b10 : begin
                reg_list[in] <= REG_IDLE;
            end
            2'b01 : begin
                reg_list[out] <= REG_BUSY;
            end
        endcase
    end
end
endmodule