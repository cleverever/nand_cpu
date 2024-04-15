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

logic checkout_rw;
logic checkout_rs;

logic [`NUM_D_REG] r_free_list;
logic [`NUM_S_REG] s_free_list;

logic r_available;
logic [$clog2(`NUM_D_REG)-1:0] r_addr;

logic s_available;
logic [$clog2(`NUM_D_REG)-1:0] s_addr;

always_comb begin
    r_available = 1'b0;
    for(int i = `NUM_D_REG - 1; i >= 0; i--) begin
        if(r_free_list[i]) begin
            r_available = 1'b1;
            r_addr = i;
        end
    end

    s_available = 1'b0;
    for(int i = `NUM_S_REG - 1; i >= 0; i--) begin
        if(s_free_list[i]) begin
            s_available = 1'b1;
            s_addr = i;
        end
    end

    checkout_rw = valid & decoder_in.use_rw;
    checkout_rs = valid & decoder_in.use_rs;
    stall = (checkout_rw & ~r_available) | (checkout_rs & ~s_available);
    
    frl_out.rw_addr = r_addr;
    frl_out.rs_addr = s_addr;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        for(int i = 0; i < `NUM_D_REG; i++) begin
            r_free_list[i] <= 1'b1;
        end

        for(int i = 0; i < `NUM_S_REG; i++) begin
            s_free_list[i] <= 1'b1;
        end
    end
    else begin
        r_free_list <= r_free_list & ~commit.return_r_list;
        if(checkout_rw) begin
            r_free_list[frl_out.rw_addr] <= 1'b0;
        end

        s_free_list <= s_free_list & ~commit.return_s_list;
        if(checkout_rs) begin
            s_free_list[frl_out.rs_addr] <= 1'b0;
        end
    end
end
endmodule