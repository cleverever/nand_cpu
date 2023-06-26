`include "nand_cpu.svh"

module alu_glue_circuit
(
    decoder_output_ifc.alu i_decoder,
    regfile_output_ifc.alu i_regfile,

    alu_input_ifc.out out
);

always_comb begin
    out.op0 = i_regfile.ra;
    out.op1 = i_decoder.use_immdt? {10'b0000000000, i_decoder.shift, i_decoder.immdt} : i_regfile.rt;
    out.alu_op = i_decoder.alu_op;
end
endmodule

interface writeback_ifc;
logic valid;
logic use_rw;
logic rw_addr;
logic data;
logic write_ps;
logic ps;

modport in
(
    input valid, use_rw, rw_addr, data, write_ps, ps
);
modport out
(
    output valid, use_rw, rw_addr, data, write_ps, ps
);
endinterface

module writeback_glue_circuit
(
    logic [15 : 0] alu_data,
    logic [15 : 0] mem_data,

    decoder_output_ifc.writeback i_decoder,

    writeback_ifc.out out
);

always_comb begin
    out.valid = i_decoder.valid;
    out.use_rw = i_decoder.use_rw;
    out.rw_addr = i_decoder.rw_addr;
    out.data = i_decoder.mem_access? mem_data : alu_data;
    out.write_ps = i_decoder.write_ps;
    out.ps = alu_data[0];
end
endmodule