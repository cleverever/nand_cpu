`include "nand_cpu.svh"

interface sb_checkpoint;
logic restore;
logic [$clog2(`ST_B_LENGTH)-1:0] tail;

modport in
(
    input restore, tail
);
modport out
(
    output restore, tail
);
endinterface

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

interface pipeline_ctrl_ifc;
logic reject;
logic retain;

modport in
(
    input reject, retain
);
modport out
(
    output reject, retain
);
endinterface

interface buffer_ctrl_ifc;
logic reject;
logic retain;

modport in
(
    input reject, retain
);
modport out
(
    output reject, retain
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

    input logic frl_empty,
    input logic rob_full,

    branch_hazard.in dec_branch_hazard,
    branch_hazard.in br_branch_hazard,

    frl_checkpoint.out frl_cp,
    tt_checkpoint.out tt_cp,
    rob_checkpoint.out rob_cp,

    branch_feedback_ifc.out branch_feedback_out,

    input logic speculative_halt,

    decoder_ifc.in decoder_in,

    pipeline_ctrl_ifc.out i2d_ctrl,
    pipeline_ctrl_ifc.out m_r2a_ctrl,

    output logic d_mem_stall,

    input logic ex_b_full,
    buffer_ctrl_ifc.out ex_bc,

    input logic br_b_full,
    buffer_ctrl_ifc.out br_bc,

    input logic cache_miss,

    input logic st_b_full,
    buffer_ctrl_ifc.out st_bc,

    input logic ld_b_full,
    buffer_ctrl_ifc.out ld_bc
);

logic buffer_full;

always_comb begin
    if(br_branch_hazard.mispredict) begin
        fetch_ctrl_ifc.pc_override = 1'b1;
        fetch_ctrl_ifc.target = br_branch_hazard.recovery_pc;

        frl_cp.TODO;

        tt_cp.TODO;

        rob_cp.restore = 1'b1;
        rob_cp.tail = branch_recovery.rob_tail_cp;
    end
    else if(dec_branch_hazard.mispredict) begin
        fetch_ctrl_ifc.pc_override = 1'b1;
        fetch_ctrl_ifc.target = dec_branch_hazard.recovery_pc;
    end
    else begin
        fetch_ctrl_ifc.pc_override = 1'b0;
    end

    i2d_ctrl.reject = br_branch_hazard.mispredict | dec_branch_hazard.mispredict;
    i2d_ctrl.retain = br_branch_hazard.mispredict | 
        ((decoder_in.buffer_sel == EX) & ex_bc.reject) |
        ((decoder_in.buffer_sel == BR) & br_bc.reject) |
        ((decoder_in.buffer_sel == ST) & st_bc.reject) |
        ((decoder_in.buffer_sel == LD) & ld_bc.reject);

    m_r2a_ctrl.reject = TODO;
    m_r2a_ctrl.retain = cache_miss;

    ex_bc.reject = ex_b_full | rob_full | frl_empty | br_branch_hazard.mispredict;
    ex_bc.retain = 1'b0;

    br_bc.reject = br_b_full | rob_full | frl_empty | br_branch_hazard.mispredict;
    br_bc.retain = 1'b0;

    st_bc.reject = st_b_full | rob_full | frl_empty | br_branch_hazard.mispredict;
    st_bc.retain = cache_miss;

    ld_bc.reject = ld_b_full | rob_full | frl_empty | br_branch_hazard.mispredict;
    ld_bc.retain = cache_miss;
end
endmodule