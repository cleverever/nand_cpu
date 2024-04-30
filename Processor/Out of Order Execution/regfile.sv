`include "nand_cpu.svh"

interface regfile_d_read_ifc;
logic [$clog2(`NUM_D_REG)-1:0] addr;
logic [15:0] data;

modport read
(
    input data,
    output addr
);
modport rf
(
    input addr,
    output data
);
endinterface

interface regfile_s_read_ifc;
logic [$clog2(`NUM_S_REG)-1:0] addr;
logic data;

modport read
(
    input data,
    output addr
);
modport rf
(
    input addr,
    output data
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

    regfile_d_read_ifc.rf ex_ra_request,
    regfile_d_read_ifc.rf ex_rt_request,
    regfile_d_write_ifc.rf ex_rw_request,
    regfile_s_write_ifc.rf ex_rs_request,

    regfile_d_read_ifc.rf br_rt_request,
    regfile_s_read_ifc.rf br_rs_request,
    regfile_d_write_ifc.rf br_rw_request,

    regfile_d_read_ifc.rf mem_ra_request,
    regfile_d_read_ifc.rf mem_rt_request,
    regfile_d_write_ifc.rf mem_rw_request
);

logic [15:0] data_regs [`NUM_D_REG];
logic status_regs [`NUM_S_REG];

always_comb begin
    ex_read_request.ra_data = data_regs[ex_read_request.ra_addr];
    ex_read_request.rt_data = data_regs[ex_read_request.rt_addr];
    br_read_request.rt_data = data_regs[br_read_request.rt_addr];
    br_read_request.rs_data = status_regs[br_read_request.rs_addr];
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