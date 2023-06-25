interface regfile_output_ifc;
logic [`DATA_WIDTH - 1 : 0] ra;
logic [`DATA_WIDTH - 1 : 0] rt;
logic ps;

modport regfile
(
    output ra, rt, ps
);
modport alu
(
    input ra, rt
);
modport branch_controller
(
    input ps, rt
);
endinterface

module regfile
(
    input logic clk,
    input logic n_rst,

    writeback_ifc.in i_writeback,
    decoder_output_ifc.regfile i_reg_read,

    regfile_output_ifc.regfile out
);

logic [`DATA_WIDTH - 1 : 0] regs [16];
logic ps_reg;

always_comb begin
    if(i_reg_read.valid) begin
        if(i_reg_read.use_ra) begin
            out.ra = regs[0];
        end
        if(i_reg_read.use_rt) begin
            out.rt = regs[i_reg_read.rt_addr];
        end
        if(i_reg_read.read_ps) begin
            out.ps = ps_reg;
        end
    end
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        regs <= '{default:'0};
        ps_reg <= 1'b0;
    end
    else begin
        if(i_writeback.valid) begin
            if(i_writeback.use_rw) begin
                regs[i_writeback.rw_addr] <= i_writeback.data;
            end
            if(i_writeback.write_ps) begin
                ps_reg <= i_writeback.ps;
            end
        end
    end
end
endmodule