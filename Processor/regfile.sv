interface readport;
logic enable;
logic [$clog2(`NUM_REG) - 1 : 0] addr;
logic [`DATA_WIDTH - 1 : 0] data;

modport regfile
(
    input enable, addr,
    output data
);
modport reader
(
    input data,
    output enable, addr
);
endinterface

interface writeport;
logic enable;
logic [$clog2(`NUM_REG) - 1 : 0] addr;
logic [`DATA_WIDTH - 1 : 0] data;

modport regfile
(
    input enable, addr, data
);
modport writer
(
    output enable, addr, data
);
endinterface

module regfile
(
    input logic clk,

    readport.regfile rp,
    writeport.regfile wp
);

logic [`DATA_WIDTH - 1 : 0] regs [`NUM_REG];

always_comb begin
    if(rp.enable) begin
        rp.data = regs[rp.addr];
    end
end

always_ff @(posedge clk) begin
    if(wp.enable) begin
        regs[wp.addr] <= wp.data;
    end
end
endmodule