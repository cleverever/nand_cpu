`include "nand_cpu.svh"

module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

logic reg_write;
logic [$clog2(`NUM_REG)-1 : 0] w_addr;

logic p_reg;

logic reg_commit;
logic [$clog2(`NUM_REG)-1 : 0] commit_addr;

translation_table_ifc translation_table();


//EXECUTION
alu_input_ifc alu_input();

//MEMORY

//BRANCH

fetch_unit FETCH_UNIT
(
    .clk,
    .n_rst,

    .interrupt_handler(),

    .i_fetch_ctrl(fetch_ctrl),

    .pc(pc),
    .halted(halt)
);

i_cache I_CACHE
(
    .clk,
    .n_rst,

    .pc(pc),

    .out(f_i_cache_output),

    .cache_request(f_i_cache_request)
);

branch_predictor BRANCH_PREDICTOR
(
    .clk,
    .n_rst,
    
    .pc(pc),

    .use_ps(predictor_use_ps),
    .ps(d_regfile_output.ps),
    
    .out(f_branch_prediction),

    .feedback_valid(a_pr_pass.valid & (a_branch_feedback.branch | a_branch_feedback.jump)),
    .i_feedback(a_branch_feedback)
);

decoder DECODER
(
    .instr(d_instr),
    
    .out(d_decoder_output)
);

free_reg_list FRL
(
    .clk,
    .n_rst,

    .checkin(reg_commit),
    .in(commit_addr),

    .checkout(reg_write),
    .out(p_reg)
);

logic [$clog2(`NUM_REG)-1 : 0] translation [16];

translation_table TT
(
    .clk,
    .n_rst,

    .d_set(reg_write),
    .d_v_reg(w_addr),
    .d_p_reg(p_reg),
    .d_translation(translation)

    .s_set(),
    .s_v_reg(),
    .s_p_reg(),
    .s_translation()
);

execution_buffer EB
(
    .out(execution_buffer_port)
);

always_comb begin
    alu_input.op0 =
    alu_input.op1 =
    alu_input.alu_op =
end

alu ALU
(
    .in()
);

commit_unit CU
(
    .reg_write(reg_commit),
    .reg_addr(commit_addr)
);

endmodule