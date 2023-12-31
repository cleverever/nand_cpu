`include "nand_cpu.svh"

interface writeback_ifc;
logic reg_write;
logic [3 : 0] reg_addr;
logic [15 : 0] reg_data;
logic ps_write;
logic ps_data;

modport in
(
    input reg_write, reg_addr, reg_data, ps_write, ps_data
);
modport out
(
    output reg_write, reg_addr, reg_data, ps_write, ps_data
);
endinterface

interface forward_data_ifc;
logic valid;
logic use_rw;
logic [3 : 0] rw_addr;
logic [15 : 0] rw_data;
logic write_ps;
logic ps_data;

modport in
(
    input valid, use_rw, rw_addr, rw_data, write_ps, ps_data
);
modport out
(
    output valid, use_rw, rw_addr, rw_data, write_ps, ps_data
);
endinterface

interface act_pass_ifc;
logic mem_access;
logic reg_write;
logic [3 : 0] reg_addr;
logic ps_write;
logic jump;

modport in
(
    input mem_access, reg_write, reg_addr, ps_write, jump
);
modport out
(
    output mem_access, reg_write, reg_addr, ps_write, jump
);
endinterface

interface branch_feedback_ifc;
logic branch;
logic jump;
logic [`PC_SIZE - 1 : 0] pc;
logic [`PC_SIZE - 1 : 0] predict_target;
logic [`PC_SIZE - 1 : 0] feedback_target;
logic predict_taken;
logic feedback_taken;

modport in
(
    input branch, jump, pc, predict_target, feedback_target, predict_taken, feedback_taken
);
modport out
(
    output branch, jump, pc, predict_target, feedback_target, predict_taken, feedback_taken
);
endinterface

interface branch_request_ifc;
logic [`PC_SIZE - 1 : 0] pc;
logic [`PC_SIZE - 1 : 0] target;
logic ps;

modport in
(
    input pc, target, ps
);
modport out
(
    output pc, target, ps
);
endinterface