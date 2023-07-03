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

module hazard_controller
(
    branch_predictor_output_ifc.in i_branch_predictor,
    branch_feedback_ifc.in i_feedback,

    pipeline_ctrl_ifc.out o_i2d,
    pipeline_ctrl_ifc.out o_d2a,
    pipeline_ctrl_ifc.out o_a2w,

    fetch_ctrl_ifc.out o_fetch_ctrl
);

logic mispredict;
logic [`PC_SIZE - 1 : 0] recovery_pc;

always_comb begin
    mispredict = i_feedback.valid & ((i_feedback.predict_taken != i_feedback.feedback_taken) |
        (i_feedback.feedback_taken & (i_feedback.predict_target != i_feedback.feedback_target)));
    o_fetch_ctrl.pc_override = mispredict | i_branch_predictor.pc_override;
    recovery_pc = i_feedback.feedback_taken? i_feedback.target : (i_feedback.pc + 1);
    o_fetch_ctrl.target = mispredict? recovery_pc : i_branch_predictor.target;
end
endmodule