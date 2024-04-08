`include "nand_cpu.svh"

interface regfile_ex_ifc;
logic [$clog2(`NUM_D_REG)-1:0] ra_addr;
logic [15:0] ra_data;
logic [$clog2(`NUM_D_REG)-1:0] rt_addr;
logic [15:0] rt_data;

modport rf
(
    input ra_addr, rt_addr,
    output ra_data, rt_data
);
modport ex
(
    input ra_data, rt_data,
    output ra_addr, rt_addr
);
endinterface

interface regfile_d_write_ifc;
logic valid;
logic [15:0] data;
logic [$clog2(`NUM_D_REG)-1:0] addr;

modport rf
(
    input valid, data, addr
);
modport write
(
    output valid, data, addr
);
endinterface

interface regfile_s_write_ifc;
logic valid;
logic data;
logic [$clog2(`NUM_S_REG)-1:0] addr;

modport rf
(
    input valid, data, addr
);
modport write
(
    output valid, data, addr
);
endinterface

module regfile
(
    input logic clk,
    input logic n_rst,

    regfile_ex_ifc.rf ex_read_request,

    regfile_d_write_ifc.rf ex_d_write_request,
    regfile_s_write_ifc.rf ex_s_write_request
);

logic [15:0] data_regs [`NUM_D_REG];
logic status_regs [`NUM_S_REG];

always_comb begin
    ex_read_request.ra_data = data_regs[ex_read_request.ra_addr];
    ex_read_request.rt_data = data_regs[ex_read_request.rt_addr];
end


always_ff @(posedge clk) begin
    if(~n_rst) begin
        data_regs <= '{default:'0};
        status_regs <= '{default:'0};
    end
    else begin
        if(ex_r_write_request.valid) begin
            data_regs[ex_r_write_request.addr] <= ex_r_write_request.data;
        end
        if(ex_s_write_request.valid) begin
            status_regs[ex_s_write_request.addr] <= ex_s_write_request.data;
        end
    end
end
endmodule