`include "nand_cpu.svh"

interface reg_tracker_ifc;
logic [$clog2(`NUM_D_REG)-1:0] rw_addr;
logic [$clog2(`NUM_S_REG)-1:0] rs_addr;

modport in
(
    input rw_addr, rs_addr
);
modport out
(
    output rw_addr, rs_addr
);
endinterface

interface reg_track_checkpoint;
logic restore;
logic r_free_list [`NUM_D_REG];
logic s_free_list [`NUM_S_REG];

modport in
(
    input restore, r_free_list, s_free_list
);
modport out
(
    output restore, r_free_list, s_free_list
);
endinterface

//Keeps track of physical registers which are not currently in use and may be assigned to a logical register.
//Also keeps track of currently calculated registers to allow for readying instructions.
module reg_tracker
(
    input logic clk,
    input logic n_rst,

    input logic valid,
    decoder_ifc.in decoder_in,

    reorder_buffer_ifc.in commit,
    reg_track_checkpoint.in checkpoint,

    output logic r_calculated_list [`NUM_D_REG],
    output logic s_calculated_list [`NUM_S_REG],

    free_reg_list_ifc.out frl_out,

    output logic empty
);

logic r_available;
logic [$clog2(`NUM_D_REG)-1:0] r_addr;

logic s_available;
logic [$clog2(`NUM_D_REG)-1:0] s_addr;

RegState r_state_list [`NUM_D_REG];
RegState s_state_list [`NUM_S_REG];

logic checkout_rw;
logic checkout_rs;

always_comb begin
    r_available = 1'b0;
    for(int i = `NUM_D_REG - 1; i >= 0; i--) begin
        if(r_state_list[i] == REG_FREE) begin
            r_available = 1'b1;
            r_addr = i;
        end
    end

    s_available = 1'b0;
    for(int i = `NUM_S_REG - 1; i >= 0; i--) begin
        if(s_state_list[i] == REG_FREE) begin
            s_available = 1'b1;
            s_addr = i;
        end
    end

    //On a commit, the returned register will be used immediately.
    frl_out.rw_addr = r_addr;
    frl_out.rs_addr = s_addr;
    if(commit.return_r) begin
        r_available = 1'b1;
        frl_out.rw_addr = commit.r_addr;
    end
    if(commit.return_s) begin
        s_available = 1'b1;
        frl_out.rs_addr = commit.s_addr;
    end
    checkout_rw = valid & decoder_in.use_rw;
    checkout_rs = valid & decoder_in.use_rs;
    empty = (checkout_rw & ~r_available) | (checkout_rs & ~s_available);

    r_calculated_list = '{default:1'b0};
    for(int i = 0; i < `NUM_D_REG; i++) begin
        if(r_state_list[i] == REG_CALCULATED) begin
            r_calculated_list[i] = 1'b1;
        end
    end

    s_calculated_list = '{default:1'b0};
    for(int i = 0; i < `NUM_S_REG; i++) begin
        if(s_state_list[i] == REG_CALCULATED) begin
            s_calculated_list[i] = 1'b1;
        end
    end
end

always_ff @(posedge clk) begin
    if(~n_rst) begin
        for(int i = 0; i < `NUM_D_REG; i++) begin
            r_state_list[i] <= REG_FREE;
        end

        for(int i = 0; i < `NUM_S_REG; i++) begin
            s_state_list[i] <= REG_FREE;
        end
    end
    else begin

        //On incorrect execution, the free list will need to be restored to the checkpoint state
        //to prevent from deadlocking registers used by cancelled instructions.
        if(checkpoint.restore) begin
            for(int i = 0; i < `NUM_D_REG; i++) begin
                if(checkpoint.r_state_list[i]) begin
                    r_state_list[i] <= REG_FREE;
                end
            end
            for(int i = 0; i < `NUM_S_REG; i++) begin
                if(checkpoint.s_state_list[i]) begin
                    s_state_list[i] <= REG_FREE;
                end
            end
        end

        //Handles the internal state changes causes by commits and checkouts.
        else begin
            if(checkout_rw) begin
                r_state_list[r_addr] <= REG_BUSY;
            end
            else if(commit.return_r) begin
                r_state_list[commit.r_addr] <= REG_FREE;
            end

            if(checkout_rs) begin
                s_state_list[s_addr] <= REG_BUSY;
            end
            else if(commit.return_s) begin
                s_state_list[commit.s_addr] <= REG_FREE;
            end
        end
    end
end
endmodule