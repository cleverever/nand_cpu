`include "nand_cpu.svh"

module fetch_unit
(
    input logic clk,
    input logic n_rst,

    input logic unsigned [`PC_SIZE - 1 : 0] interrupt_handler [15],

    fetch_ctrl_ifc.in i_fetch_ctrl,

    output logic unsigned [`PC_SIZE - 1 : 0] pc,
    output logic halted
);
logic unsigned [`PC_SIZE - 1 : 0] int_return_pc;

always_ff @(posedge clk) begin
    if(~n_rst) begin
        pc <= 0;
        halted <= 1'b0;
    end
    else begin
        if(~halted) begin
            if(i_fetch_ctrl.halt) begin
                halted <= 1'b1;
            end
            else begin
                if(i_fetch_ctrl.interrupt) begin
                    if(i_fetch_ctrl.int_code == 0) begin
                        pc <= int_return_pc;
                    end
                    else begin
                        pc <= interrupt_handler[i_fetch_ctrl.int_code];
                        int_return_pc <= pc + 1;
                    end
                end
                else if(i_fetch_ctrl.pc_override) begin
                    pc <= i_fetch_ctrl.target;
                end
                else if(~i_fetch_ctrl.stall) begin
                    pc <= pc + 1;
                end
            end
        end
    end
end
endmodule