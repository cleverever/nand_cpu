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
logic mem_access;
logic reg_write;
logic [3 : 0] reg_addr;
logic ps_write;

modport in
(
    input valid, mem_access, reg_write, reg_addr, ps_write
);
modport out
(
    output valid, mem_access, reg_write, reg_addr, ps_write
);
endinterface

interface branch_feedback_ifc;
logic valid;
logic [`PC_SIZE - 1 : 0] pc;
logic [`PC_SIZE - 1 : 0] predict_target;
logic [`PC_SIZE - 1 : 0] feedback_target;
logic predict_taken;
logic feedback_taken;

modport in
(
    input valid, pc, predict_taken, feedback_target, predict_taken, feedback_taken
);
modport out
(
    output valid, pc, predict_taken, feedback_target, predict_taken, feedback_taken
);
endinterface

interface branch_prediction_ifc;
logic valid;
logic [`PC_SIZE - 1 : 0] pc;
logic [`PC_SIZE - 1 : 0] target;

modport in
(
    input valid, pc, target
);
modport out
(
    output valid, pc, target
);
endinterface