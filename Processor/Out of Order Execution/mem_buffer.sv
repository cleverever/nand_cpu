`include "nand_cpu.svh"

interface mem_buffer_input_ifc;
logic valid;

logic use_ra;
logic[$clog2(`NUM_REG) - 1 : 0] ra_addr;

logic use_rt;
logic[$clog2(`NUM_REG) - 1 : 0] rt_addr;

logic use_rw;
logic[$clog2(`NUM_REG) - 1 : 0] rw_addr;

nand_cpu_pkg::MemOp mem_op;

modport in
(
    input valid, use_ra, ra_addr, use_rt, rt_addr, use_rw, rw_addr, mem_op
);
modport out
(
    output valid, use_ra, ra_addr, use_rt, rt_addr, use_rw, rw_addr, mem_op
);
endinterface

module mem_buffer
(
    mem_buffer_input_ifc.in instr
);

typedef struct packed
{
    
}
Entry;

always_comb begin
    
end

always_ff begin
end
endmodule