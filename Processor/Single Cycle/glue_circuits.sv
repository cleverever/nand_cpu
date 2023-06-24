module alu_glue_circuit
(
    decoded_instr.in decoded,
    regfile_ifc.in reg_data,
    
    alu_input.out alu_in
);

always_comb begin
    if(decoded.alu_op == ALU_LI) begin
        case(decoded.shift)
            2'b00 : begin
                alu_in.op0 = reg_data.acc & 16'b1111111111110000;
            end
            2'b01 : begin
                alu_in.op0 = reg_data.acc & 16'b1111111100001111;
            end
            2'b10 : begin
                alu_in.op0 = reg_data.acc & 16'b1111000011111111;
            end
            2'b1 : begin
                alu_in.op0 = reg_data.acc & 16'b0000111111111111;
            end
        endcase
    end
    else begin
        alu_in.op0 = reg_data.acc;
    end

end
endmodule