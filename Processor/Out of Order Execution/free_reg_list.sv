`include "nand_cpu.svh"

interface free_reg_list_ifc;
logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
logic [$clog2(`NUM_S_REG)-1:0] rs_addr;

modport in
(
    input rw_addr, rs_addr
);
modport out
(
    output rw_addr, rs_addr
);
endinterface

module free_reg_list
(
    input logic clk,
    input logic n_rst,

    input logic valid,
    decoder_ifc.in decoder_in,

    reorder_buffer_ifc.in commit,
    free_reg_list_ifc.out frl_out,

    output logic stall
);

logic rw_available;
logic rs_available;

logic checkin_rw;
logic checkin_rs;

logic checkout_rw;
logic checkout_rs;

typedef enum {REG_IDLE, REG_BUSY} REG_STATE;
REG_STATE r_list [`NUM_D_REG];
REG_STATE s_list [`NUM_S_REG];

logic r_free_valid;
logic [$clog2(`NUM_D_REG)-1:0] r_free;

logic s_free_valid;
logic [$clog2(`NUM_D_REG)-1:0] s_free;

always_comb begin
    checkin_rw = commit.valid & commit.use_rw;
    checkin_rs = commit.valid & commit.use_rs;
    checkout_rw = valid & decoder_in.use_rw;
    checkout_rs = valid & decoder_in.use_rs;
    stall = (checkout_rw & ~rw_available) | (checkout_rs & ~rs_available);

    r_free_valid = 1'b0;
    for(int i = `NUM_D_REG - 1; i >= 0; i--) begin
        if(r_list[i] == REG_IDLE) begin
            r_free_valid = 1'b1;
            r_free = i;
        end
    end

    s_free_valid = 1'b0;
    for(int i = `NUM_S_REG - 1; i >= 0; i--) begin
        if(s_list[i] == REG_IDLE) begin
            s_free_valid = 1'b1;
            s_free = i;
        end
    end

    if(checkin_rw) begin
        rw_available = 1'b1;
        frl_out.rw_addr = commit.prev_rw_addr;
    end
    else begin
        rw_available = r_free_valid;
        frl_out.rw_addr = r_free;
    end

    if(checkin_rs) begin
        rs_available = 1'b1;
        frl_out.rs_addr = commit.prev_rs_addr;
    end
    else begin
        rs_available = s_free_valid;
        frl_out.rs_addr = s_free;
    end
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        for(int i = 0; i < `NUM_D_REG; i++) begin
            r_list[i] <= REG_IDLE;
        end

        for(int i = 0; i < `NUM_S_REG; i++) begin
            s_list[i] <= REG_IDLE;
        end
    end
    else begin
        case({checkin_rw, checkout_rw})
            2'b10 : begin
                r_list[commit.prev_rw_addr] <= REG_IDLE;
            end
            2'b01 : begin
                r_list[frl_out.rw_addr] <= REG_BUSY;
            end
        endcase

        case({checkin_rs, checkout_rs})
            2'b10 : begin
                s_list[commit.prev_rs_addr] <= REG_IDLE;
            end
            2'b01 : begin
                s_list[frl_out.rs_addr] <= REG_BUSY;
            end
        endcase
    end
end
endmodule