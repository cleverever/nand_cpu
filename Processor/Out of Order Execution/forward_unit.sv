`include "nand_cpu.svh"

module forward_unit
(
    input logic clk,
    input logic n_rst,

    regfile_d_read_ifc.rf ex_ra_request_in,
    regfile_d_read_ifc.read ex_ra_request_out,
    regfile_d_read_ifc.rf ex_rt_request_in,
    regfile_d_read_ifc.read ex_rt_request_out,

    regfile_d_read_ifc.rf br_rt_request_in,
    regfile_d_read_ifc.read br_rt_request_out,
    regfile_s_read_ifc.rf br_rs_request_in,
    regfile_s_read_ifc.read br_rs_request_out,

    regfile_d_read_ifc.rf mem_ra_request_in,
    regfile_d_read_ifc.read mem_ra_request_out,
    regfile_d_read_ifc.rf mem_rt_request_in,
    regfile_d_read_ifc.read mem_rt_request_out,

    regfile_d_write_ifc.rf e_a_dfw,
    regfile_s_write_ifc.rf e_a_sfw,

    regfile_d_write_ifc.rf e_c_dfw,
    regfile_s_write_ifc.rf e_c_sfw,

    reorder_buffer_ifc.in rob_in,

    output logic r_calculated_list [`NUM_D_REG],
    output logic s_calculated_list [`NUM_S_REG]
);

always_comb begin
    ex_ra_request_out.addr = ex_ra_request_in.addr;
    ex_ra_request_in.data = check_d_fw(ex_ra_request_in.addr, ex_ra_request_out.data);
    ex_rt_request_out.addr = ex_rt_request_in.addr;
    ex_rt_request_in.data = check_d_fw(ex_rt_request_in.addr, ex_rt_request_out.data);

    br_rt_request_out.addr = br_rt_request_in.addr;
    br_rt_request_in.data = check_d_fw(br_rt_request_in.addr, br_rt_request_out.data);
    br_rs_request_out.addr = br_rs_request_in.addr;
    br_rs_request_in.data = check_s_fw(br_rs_request_in.addr, br_rs_request_out.data);

    mem_ra_request_out.addr = mem_ra_request_in.addr;
    mem_ra_request_in.data = check_d_fw(mem_ra_request_in.addr, mem_ra_request_out.data);
    mem_rt_request_out.addr = mem_rt_request_in.addr;
    mem_rt_request_in.data = check_d_fw(mem_rt_request_in.addr, mem_rt_request_out.data);
end

function automatic logic [15:0] check_d_fw(logic [$clog2(`NUM_D_REG)-1:0] addr, logic [15:0] data);
logic [15:0] temp = data;
if(e_c_dfw.valid & (addr == e_c_dfw.addr)) begin
    temp = e_c_dfw.data;
end
if(e_a_dfw.valid & (addr == e_a_dfw.addr)) begin
    temp = e_a_dfw.data;
end
return temp;
endfunction

function automatic logic check_s_fw(logic [$clog2(`NUM_D_REG)-1:0] addr, logic data);
logic temp = data;
if(e_c_sfw.valid & (addr == e_c_sfw.addr)) begin
    temp = e_c_sfw.data;
end
if(e_a_sfw.valid & (addr == e_a_sfw.addr)) begin
    temp = e_a_sfw.data;
end
return temp;
endfunction

always_ff @(posedge clk) begin
    if(~n_rst) begin
        r_calculated_list <= '{default:'0};
        s_calculated_list <= '{default:'0};
    end
    else begin
        if(rob_in.valid) begin
            if(rob_in.write_rw) begin
                r_calculated_list[rob_in.prev_rw_addr] <= 1'b0;
            end
            if(rob_in.write_rs) begin
                s_calculated_list[rob_in.prev_rs_addr] <= 1'b0;
            end
        end
    end
end
endmodule