`include "nand_cpu.svh"

interface commit_unit_ifc
endinterface

module commit_unit
(
    output logic reg_write,
    output logic [$clog2(`NUM_REG)-1 : 0] reg_addr
);

endmodule