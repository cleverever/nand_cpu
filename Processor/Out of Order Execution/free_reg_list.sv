`include "nand_cpu.svh"

interface free_reg_list_ifc;
logic clk;
logic n_rst;

logic r_checkin;
logic [$clog2(`NUM_D_REG)-1 : 0] r_in;

logic r_checkout;
logic [$clog2(`NUM_D_REG)-1 : 0] r_out;

logic s_checkin;
logic [$clog2(`NUM_S_REG)-1 : 0] s_in;

logic s_checkout;
logic [$clog2(`NUM_S_REG)-1 : 0] s_out;

modport self
(
    input r_checkin, r_in, r_checkout, s_checkin, s_in, s_checkout,
    output r_out, s_out
);
modport other
(
    input r_out, s_out,
    output r_checkin, r_in, r_checkout, s_checkin, s_in, s_checkout
);
endinterface

module free_reg_list
(
    input logic clk,
    input logic n_rst,

    free_reg_list_ifc.self port
);

typedef enum {REG_IDLE, REG_BUSY} REG_STATE;
REG_STATE r_list [`NUM_D_REG];
REG_STATE s_list [`NUM_S_REG];

logic [$clog2(`NUM_D_REG)-1 : 0] r_free;
logic [$clog2(`NUM_S_REG)-1 : 0] s_free;

always_comb begin
    for(int i = `NUM_D_REG - 1; i >= 0; i--) begin
        if(r_list[i] == REG_IDLE) begin
            r_free = i;
        end
    end

    for(int i = `NUM_S_REG - 1; i >= 0; i--) begin
        if(s_list[i] == REG_IDLE) begin
            s_free = i;
        end
    end

    if(port.r_checkout) begin
        if(port.r_checkin) begin
            port.r_out = port.r_in;
        end
        else begin
            port.r_out = port.r_free;
        end
    end

    if(port.s_checkout) begin
        if(port.s_checkin) begin
            port.s_out = port.s_in;
        end
        else begin
            port.s_out = port.s_free;
        end
    end
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        for(int i = 0; i < `NUM_D_REG; i++) begin
            r_list <= REG_IDLE;
        end

        for(int i = 0; i < `NUM_S_REG; i++) begin
            s_list <= REG_IDLE;
        end
    end
    else begin
        case({port.r_checkin, port.r_checkout})
            2'b10 : begin
                r_list[r_in] <= REG_IDLE;
            end
            2'b01 : begin
                r_list[r_out] <= REG_BUSY;
            end
        endcase

        case({port.s_checkin, port.s_checkout})
            2'b10 : begin
                s_list[s_in] <= REG_IDLE;
            end
            2'b01 : begin
                s_list[s_out] <= REG_BUSY;
            end
        endcase
    end
end
endmodule