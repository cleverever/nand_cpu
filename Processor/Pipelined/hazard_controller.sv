`include "nand_cpu.svh"

interface pipeline_ctrl_ifc;
logic retain;
logic clear;

modport in
(
    input retain, clear
);
modport out
(
    output retain, clear
);
endinterface

interface fetch_ctrl_ifc;
logic halt;
logic stall;
logic pc_override;
logic [`PC_SIZE - 1 : 0] target;
logic interrupt;
logic [3 : 0] int_code;

modport in
(
    input halt, stall, pc_override, target, interrupt, int_code
);
modport out
(
    output halt, stall, pc_override, target, interrupt, int_code
);
endinterface

module hazard_controller
(
    branch_predictor_output_ifc.in i_branch_predictor,
    branch_feedback_ifc.in i_feedback,

    input logic i_cache_miss,
    input logic d_cache_miss,

    pr_pass_ifc.in i_i2d,
    pr_pass_ifc.in i_d2a,
    pr_pass_ifc.in i_a2w,

    pipeline_ctrl_ifc.out o_i2d,
    pipeline_ctrl_ifc.out o_d2a,
    pipeline_ctrl_ifc.out o_a2w,

    fetch_ctrl_ifc.out o_fetch_ctrl
);

logic mispredict;
logic [`PC_SIZE - 1 : 0] recovery_pc;

always_comb begin
    mispredict = i_a2w.valid & ((i_feedback.predict_taken != i_feedback.feedback_taken) |
        (i_feedback.feedback_taken & (i_feedback.predict_target != i_feedback.feedback_target)));
    o_fetch_ctrl.stall = i_cache_miss | (i_i2d.valid & (i_i2d.halt | i_d2a.interrupt)) | (i_d2a.valid & (i_d2a.halt | i_i2d.interrupt));
    o_fetch_ctrl.halt = i_a2w.halt;
    o_fetch_ctrl.interrupt = i_a2w.interrupt;
    o_fetch_ctrl.int_code = i_a2w.int_code;
    o_fetch_ctrl.pc_override = mispredict | i_branch_predictor.pc_override;
    recovery_pc = i_feedback.feedback_taken? i_feedback.feedback_target : (i_feedback.pc + 1);
    o_fetch_ctrl.target = mispredict? recovery_pc : i_branch_predictor.target;
end

always_comb begin
    o_i2d.retain = d_cache_miss;
    o_i2d.clear = mispredict | i_cache_miss;
end

always_comb begin
    o_d2a.retain = d_cache_miss;
    o_d2a.clear = mispredict;
end

always_comb begin
    o_a2w.retain = 1'b0;
    o_a2w.clear = d_cache_miss;
end
endmodule