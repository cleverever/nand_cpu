module writeback_glue
(
    act_pass_ifc.in i_act_pass,

    writeback_ifc.out out
);

always_comb begin
    out.valid = i_act_pass.valid;
    out.reg_write = i_act_pass.reg_write;
    out.reg_addr = i_act_pass.reg_addr;
    out.reg_data = TEMP;
    out.ps_write = i_act_pass.ps_write;
    out.ps_data = i_act_pass.ps_data;
end
endmodule