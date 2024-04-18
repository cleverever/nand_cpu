`include "nand_cpu.svh"

interface frl_checkpoint;
logic restore;
logic r_free_list [`NUM_D_REG];
logic s_free_list [`NUM_S_REG];

modport in
(
    input restore, r_free_list, s_free_list
);
modport out
(
    output restore, r_free_list, s_free_list
);
endinterface

interface tt_checkpoint;
logic restore;
logic [$clog2(`NUM_D_REG)-1:0] d_translation [16];
logic [$clog2(`NUM_S_REG)-1:0] s_translation;

modport in
(
    input restore, d_translation, s_translation
);
modport out
(
    output restore, d_translation, s_translation
);
endinterface

interface rob_checkpoint;
logic restore;
logic [$clog2(`ROB_LENGTH)-1:0] tail;

modport in
(
    input restore, tail
);
modport out
(
    output restore, tail
);
endinterface

interface branch_recovery;
logic frl_r_free_list_cp [`NUM_D_REG];
logic frl_s_free_list_cp [`NUM_S_REG];
logic [$clog2(`NUM_D_REG)-1:0] tt_d_translation_cp [16];
logic [$clog2(`NUM_S_REG)-1:0] tt_s_translation_cp;
logic [$clog2(`ROB_LENGTH)-1:0] rob_tail_cp;

modport in
(
    input frl_r_free_list_cp, frl_s_free_list_cp, tt_d_translation_cp, tt_s_translation_cp, rob_tail_cp
);
modport out
(
    output frl_r_free_list_cp, frl_s_free_list_cp, tt_d_translation_cp, tt_s_translation_cp, rob_tail_cp
);
endinterface

interface branch_hazard;
logic mispredict;
logic [`PC_SIZE-1:0] recovery_pc;

modport in
(
    input mispredict, recovery_pc
);
modport out
(
    output mispredict, recovery_pc
);
endinterface

interface fetch_ctrl_ifc;
logic halt;
logic stall;
logic pc_override;
logic [`PC_SIZE-1:0] target;
logic interrupt;
logic [3:0] int_code;

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
    input logic valid_feedback,
    branch_feedback_ifc.in branch_feedback_in,
    input logic rob_full,

    branch_hazard.in dec_branch_hazard,
    branch_hazard.in br_branch_hazard,

    branch_feedback_ifc.out branch_feedback_out,

    output logic i_stall,
    output logic i_flush,

    output logic d_flush,

    frl_checkpoint.out frl_cp,
    tt_checkpoint.out tt_cp,
    rob_checkpoint.out rob_cp
);

always_comb begin
    if(br_branch_hazard.mispredict) begin
        fetch_ctrl_ifc.pc_override = 1'b1;
        fetch_ctrl_ifc.target = br_branch_hazard.recovery_pc;
        i2d_flush = 1'b1;

        frl_cp.TODO;

        tt_cp.TODO;

        rob_cp.restore = 1'b1;
        rob_cp.tail = branch_recovery.rob_tail_cp;
    end
    else if(dec_branch_hazard.mispredict) begin
        fetch_ctrl_ifc.pc_override = 1'b1;
        fetch_ctrl_ifc.target = dec_branch_hazard.recovery_pc;
        i2d_flush = 1'b1;
    end
    else begin
        fetch_ctrl_ifc.pc_override = 1'b0;
    end
end
endmodule