module nand_cpu
(
    input logic clk,
    input logic n_rst,

    output logic halt
);

//F

//D
decoder_output_ifc decoded();
reg_alloc_ifc reg_mappings();

//I

//A

//C


//====================================================================================================
//FETCH
//====================================================================================================
fetch_unit FETCH_UNIT();
branch_predictor BRANCH_PREDICTOR();

//----------------------------------------------------------------------------------------------------
//F2D
//----------------------------------------------------------------------------------------------------
fetch_glue FETCH_GLUE();
pr_f2d PR_F2D();

//====================================================================================================
//DECODE
//====================================================================================================
decoder DECODER
(
    .out(decoded)
);

free_list FREE_LIST
(
    .i_decoded(decoded)
);

reg_alloc_table REG_ALLOC_TABLE
(
    .i_decoded(decoded)

    .out(reg_mappings)
);

//----------------------------------------------------------------------------------------------------
//D2I
//----------------------------------------------------------------------------------------------------
decode_glue DECODE_GLUE
(
    .i_decoded(decoded),
    .i_reg_mappings(reg_mappings)
);

alu_queue ALU_QUEUE
(

);

mem_queue MEM_QUEUE
(

);

ctrl_queue CTRL_QUEUE
(

);

//====================================================================================================
//ISSUE
//====================================================================================================
regfile REGFILE();

//----------------------------------------------------------------------------------------------------
//I2A
//----------------------------------------------------------------------------------------------------

//====================================================================================================
//ACTION
//====================================================================================================
alu ALU();
d_cache D_CACHE();

//----------------------------------------------------------------------------------------------------
//A2C
//----------------------------------------------------------------------------------------------------

//====================================================================================================
//COMMIT
//====================================================================================================
active_list ACTIVE_LIST();

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//HAZARD
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
hazard_unit HAZARD_UNIT();

//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//MEMORY
//WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
memory MEMORY();

endmodule