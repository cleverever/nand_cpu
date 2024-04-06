interface regfile_output_ifc;
logic [15 : 0] ra;
logic [15 : 0] rt;
logic rs;

modport in
(
    input ra, rt, rs
);
modport out
(
    output ra, rt, rs
);
endinterface

module regfile
(
    input logic clk,
    input logic n_rst,

    input logic writeback_valid,
    writeback_ifc.in i_writeback,

    input logic reg_read_valid,
    decoder_output_ifc.out i_reg_read,

    input logic i_bp_rs,

    regfile_output_ifc.out out
);

logic [15 : 0] data_regs [`NUM_D_REG];
logic status_regs [`NUM_S_REG];

always_comb begin
    if(reg_read_valid) begin
        if(i_reg_read.use_ra) begin
            out.ra = data_regs[i_reg_read.ra_addr];
        end
        if(i_reg_read.use_rt) begin
            out.rt = data_regs[i_reg_read.rt_addr];
        end
        if(i_reg_read.read_ps | i_bp_rs) begin
            out.rs = status_regs[i_reg_read.rs_addr];
        end
    end
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        data_regs <= '{default:'0};
        status_regs <= '{default:'0};
    end
    else begin
        if(writeback_valid) begin
            if(i_writeback.reg_write) begin
                data_regs[i_writeback.d_reg_addr] <= i_writeback.d_reg_data;
            end
            if(i_writeback.ps_write) begin
                status_regs[i_writeback.s_reg_addr] <= i_writeback.s_reg_data;
            end
        end
    end
end
endmodule