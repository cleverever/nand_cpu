interface regfile_output_ifc;
logic [15 : 0] ra;
logic [15 : 0] rt;
logic ps;

modport in
(
    input ra, rt, ps
);
modport out
(
    output ra, rt, ps
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

    regfile_output_ifc.out out
);

logic [15 : 0] regs [16];
logic ps_reg;

always_comb begin
    if(reg_read_valid) begin
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
        if(writeback_valid) begin
            if(i_writeback.reg_write) begin
                regs[i_writeback.reg_addr] <= i_writeback.reg_data;
            end
            if(i_writeback.ps_write) begin
                ps_reg <= i_writeback.ps_data;
            end
        end
    end
end
endmodule