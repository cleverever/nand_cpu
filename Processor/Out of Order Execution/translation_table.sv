`include "nand_cpu.svh"

interface translation_table_ifc;
logic [$clog2(`NUM_D_REG)-1:0] p_ra_addr;
logic [3:0] v_ra_addr;
logic [$clog2(`NUM_D_REG)-1:0] p_rt_addr;
logic [3:0] v_rt_addr;
logic [$clog2(`NUM_D_REG)-1:0] p_rw_addr;
logic [3:0] v_rw_addr;
logic [$clog2(`NUM_S_REG)-1:0] p_rs_addr;

modport tt
(
    input v_ra_addr, v_rt_addr, v_rw_addr,
    output p_ra_addr, p_rt_addr, p_rw_addr, p_rs_addr
);
modport other
(
    input p_ra_addr, p_rt_addr, p_rw_addr, p_rs_addr,
    output v_ra_addr, v_rt_addr, v_rw_addr
);
endinterface

//Keeps track of the canonical state of the machine. Determines which physical register a logical
//register maps to, clarifying false dependencies. 
module translation_table
(
    input logic clk,
    input logic n_rst,

    input logic valid,
    decoder_ifc.in decoder_in,
    free_reg_list_ifc.in frl_in,

    tt_checkpoint.in checkpoint,

    translation_table_ifc.tt port
);

logic [$clog2(`NUM_D_REG)-1:0] d_translation [16];
logic [$clog2(`NUM_S_REG)-1:0] s_translation;

always_comb begin
    port.p_ra_addr = d_translation[port.v_ra_addr];
    port.p_rt_addr = d_translation[port.v_rt_addr];
    port.p_rw_addr = d_translation[port.v_rw_addr];
    port.p_rs_addr = s_translation;
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        d_translation <= '{default:'0};
        s_translation <= '{default:'0};
    end
    else begin

        //On incorrect execution, the translation table will need to be restored to the checkpoint state
        //to restore proper register mappings before the incident.
        if(checkpoint.restore) begin
            d_translation <= checkpoint.d_translation;
            s_translation <= checkpoint.s_translation;
        end

        //Upon a write to a register, the mapping needs to be updated as any new instructions
        //must reference the value in the new register.
        else begin
            if(valid & decoder_in.use_rw) begin
                d_translation[port.d_v_reg] <= frl_in.rw_addr;
            end
            if(valid & decoder_in.use_rs) begin
                s_translation[port.s_v_reg] <= frl_in.rs_addr;
            end
        end
    end
end
endmodule