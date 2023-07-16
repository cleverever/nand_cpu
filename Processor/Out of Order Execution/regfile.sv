`include "nand_cpu.svh"

interface regfile_output_ifc;
logic [`DATA_WIDTH - 1 : 0] r0;
logic [`DATA_WIDTH - 1 : 0] r1;
logic ps;

modport in
(
    input r0, r1, ps
);
modport out
(
    output r0, r1, ps
);
endinterface

module regfile
(
    input logic clk,
    input logic n_rst,

    input logic read_valid,

    input logic use_r0,
    input logic [$clog2(`NUM_REG) - 1 : 0] r0_addr,

    input logic use_r1,
    input logic [$clog2(`NUM_REG) - 1 : 0] r1_addr,

    input logic ps_read,
    input logic [$clog2(`NUM_PS) - 1 : 0] ps_addr,

    input logic write_valid,

    input logic use_rw,
    input logic [$clog2(`NUM_REG) - 1 : 0] rw_addr,
    input logic [`DATA_WIDTH - 1 : 0] rw_data,

    input logic ps_write,
    input logic [$clog2(`NUM_PS) - 1 : 0] ps_addr,
    input logic ps_data,

    regfile_output_ifc.regfile out
);

logic [`DATA_WIDTH - 1 : 0] reg_list [`NUM_REG];
logic ps_list [`NUM_PS];

always_comb begin
    if(valid) begin
        if(use_r0) begin
            out.r0 = reg_list[r0_addr];
        end
        if(use_r1) begin
            out.r1 = reg_list[r1_addr];
        end
        if(ps_read) begin
            out.ps = ps_list[ps_addr];
        end
    end
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        reg_list <= '{default:'0};
        ps_list <= '{default:'0};
    end
    else begin
        if(write_valid) begin
            if(use_rw) begin
                reg_list[rw_addr] <= rw_data;
            end
            if(i_writeback.write_ps) begin
                ps_list[ps_addr] <= ps_data;
            end
        end
    end
end
endmodule