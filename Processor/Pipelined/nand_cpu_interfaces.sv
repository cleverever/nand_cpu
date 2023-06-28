`include "nand_cpu.svh"

interface writeback_ifc;
logic valid;
logic reg_write;
logic [3 : 0] reg_addr;
logic [15 : 0] reg_data;
logic ps_write;
logic ps_data;

modport in
(
    input valid, reg_write, reg_addr, reg_data, ps_write, ps_data
);
modport out
(
    output valid, reg_write, reg_addr, reg_data, ps_write, ps_data
);
endinterface

interface act_pass_ifc;
logic valid;
logic mem_access;
logic reg_write;
logic [3 : 0] reg_addr;
logic ps_write;
logic ps_data;

modport in
(
    input valid, reg_write, reg_addr, ps_write, ps_data
);
modport out
(
    output.p['] valid, reg_write, reg_addr, ps_write, ps_data
);
endinterface