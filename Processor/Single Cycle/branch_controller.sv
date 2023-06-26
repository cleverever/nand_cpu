`include "nand_cpu.svh"

interface branch_controller_ifc;
logic pc_override;
logic [15 : 0] pc_offset;

modport in
(
    input pc_override, pc_offset
);
modport out
(
    output pc_override, pc_offset
);
endinterface

module branch_controller
(
    decoder_output_ifc.branch_controller i_decoder,
    regfile_output_ifc.branch_controller i_regfile,

    branch_controller_ifc.out out
);

always_comb begin
    out.pc_override = i_decoder.valid & (i_decoder.jump | (i_decoder.branch & i_regfile.ps));
    out.pc_offset = i_regfile.rt;
end
endmodule