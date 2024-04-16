`include "nand_cpu.svh"

interface frl_checkpoint;
logic restore;
logic r_free_list_cp [`NUM_D_REG];
logic s_free_list_cp [`NUM_S_REG];

modport in
(
    input restore, r_free_list_cp, s_free_list_cp
);
modport out
(
    output restore, r_free_list_cp, s_free_list_cp
);
endinterface

interface tt_checkpoint;
logic restore;
logic [$clog2(`NUM_D_REG)-1:0] d_translation_cp [16];
logic [$clog2(`NUM_S_REG)-1:0] s_translation_cp;

modport in
(
    input restore, d_translation_cp, s_translation_cp
);
modport out
(
    output restore, d_translation_cp, s_translation_cp
);
endinterface

interface rob_checkpoint;
logic restore;
logic [$clog2(L)-1:0] tail;

modport in
(
    input restore, tail
);
modport out
(
    output restore, tail
);
endinterface

interface branch_hazard;
logic mispredict;
logic rob_addr;
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

    branch_hazard.in dec_branch_hazard,
    branch_hazard.in br_branch_hazard,

    branch_feedback_ifc.out branch_feedback_out,

    output logic i_stall,
    output logic i_flush,

    output logic d_flush,

    input logic rob_full
);

always_comb begin
    if(dec_branch_hazard.mispredict) begin
        fetch_ctrl_ifc.pc_override = 1'b1;
        fetch_ctrl_ifc.target = dec_branch_hazard.recovery_pc;
        i2d_flush = 1'b1;
    end
    else if(br_branch_hazard.mispredict) begin
        fetch_ctrl_ifc.pc_override = 1'b1;
        fetch_ctrl_ifc.target = br_branch_hazard.recovery_pc;
        i2d_flush = 1'b1;
    end
    else begin
        fetch_ctrl_ifc.pc_override = 1'b0;
    end
end
endmodule