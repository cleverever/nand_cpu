module alu_glue_circuit
(
    decoder_output_ifc.alu i_decoder,
    regfile_output_ifc.alu i_regfile,

    alu_input_ifc.out out,
);

always_comb begin
    out.op0 = i_regfile.ra;
    out.op1 = i_decoder.use_immdt? {10'b0000000000, i_decoder.shift, i_decoder.immdt};
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
    //TEMP

    writeback_ifc.out out,
);

always_comb begin
end
endmodule