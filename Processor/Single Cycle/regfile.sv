interface regfile_output_ifc;
logic [`DATA_WIDTH - 1 : 0] ra;
logic [`DATA_WIDTH - 1 : 0] rt;
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

interface regfile_read_ifc;
logic ra_read;
logic rt_read;
logic [$clog2(`DATA_WIDTH) - 1 : 0] rt_addr;

logic ps_read;

modport in
(
    input ra_read, rt_read, rt_addr, ps_read
);
modport out
(
    output ra_read, rt_read, rt_addr, ps_read
);
endinterface

interface regfile_write_ifc;
logic write;
logic [`DATA_WIDTH - 1 : 0] rw;
logic [$clog2(`DATA_WIDTH) - 1 : 0] rw_addr;

logic ps_write;
logic ps;

modport in
(
    input write, rw, rw_addr, ps_write, ps
);
modport out
(
    output write, rw, rw_addr, ps_write, ps
);
endinterface

module regfile
(
    input logic clk,
    input logic n_rst,

    regfile_write_ifc.in i_reg_write,

    regfile_read_ifc.in i_reg_read,
    regfile_output_ifc.out out
);

logic [`DATA_WIDTH - 1 : 0] regs [`NUM_REG];
logic ps_reg;

always_comb begin
    if(i_reg_read.ra_read) begin
        out.ra = regs[0];
    end
    if(i_reg_read.rt_read) begin
        out.rt = regs[i_reg_read.rt_addr];
    end
    if(i_reg_read.ps_read) begin
        out.ps = ps_reg;
    end
end

always_ff @(posedge clk) begin
    if(i_reg_write.write) begin
        regs[i_reg_write.rw_addr] <= i_reg_write.rw;
    end
    if(i_reg_write.ps_write) begin
        ps_reg <= i_reg_write.ps;
    end
end
endmodule