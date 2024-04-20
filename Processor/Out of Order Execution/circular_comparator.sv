`include "nand_cpu.svh"

//Offset represents the start of the circular counter. Result is 1
//when in1 comes before in0 in the circular counter and 0 otherwise.
module circular_comparator#(parameter N)
(
    input logic [N-1:0] offset,
    input logic [N-1:0] in0,
    input logic [N-1:0] in1,

    output logic result
);

always_comb begin
    result = (in1 < in0) ^ (in0 < offset) ^ (in1 < offset);
end
endmodule