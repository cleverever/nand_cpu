`include "nand_cpu.svh"

interface translation_table_ifc;

logic d_set;
logic [3 : 0] d_v_reg;
logic [$clog2(`NUM_D_REG)-1 : 0] d_p_reg;
logic [$clog2(`NUM_D_REG)-1 : 0] d_translation [16];

logic s_set;
logic [3 : 0] s_v_reg;
logic [$clog2(`NUM_S_REG)-1 : 0] s_p_reg;
logic [$clog2(`NUM_S_REG)-1 : 0] s_translation;

modport self
(
    input d_set, d_v_reg, d_p_reg, s_set, s_v_reg, s_p_reg,
    output d_translation, s_translation
);

modport other
(
    input d_translation, s_translation,
    output d_set, d_v_reg, d_p_reg, s_set, s_v_reg, s_p_reg
);
endinterface

module translation_table
(
    input logic clk,
    input logic n_rst,

    translation_table_ifc.self port
);

always_ff @(posedge clk) begin
    if(~n_rst) begin
        port.d_translation <= '{default:'0};
        port.s_translation <= '{default:'0};
    end
    else begin
        if(port.d_set) begin
            port.d_translation[port.d_v_reg] <= port.d_p_reg;
        end
        if(port.s_set) begin
            port.s_translation[port.s_v_reg] <= port.s_p_reg;
        end
    end
end
endmodule