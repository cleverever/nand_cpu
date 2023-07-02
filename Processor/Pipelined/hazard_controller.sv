`include "nand_cpu.svh"

module hazard_controller
(
    branch_predictor_output_ifc.in i_branch_predictor,
    branch_feedback_ifc.in i_feedback,

    hazard_controller_ifc.out out
);

logic mispredict;
logic [`PC_SIZE - 1 : 0] recovery_pc;

always_comb begin
    mispredict = i_feedback.valid & ((i_feedback.predict_taken != i_feedback.feedback_taken) |
        (i_feedback.feedback_taken & (i_feedback.predict_target != i_feedback.feedback_target)));
    out.pc_override = mispredict | i_branch_predictor.pc_override;
    recovery_pc = i_feedback.feedback_taken? i_feedback.target : (i_feedback.pc + 1);
    out.target = mispredict? recovery_pc : i_branch_predictor.target;
end
endmodule