package nand_cpu_pkg;
    typedef enum logic [2 : 0]
    {
        ALU_CL,
        ALU_CP,
        ALU_NAND,
        ALU_LS,
        ALU_RS,
        ALU_EQ,
        ALU_NE,
        ALU_LI
    }
    ALU_OP;

    typedef enum logic
    {
        READ,
        WRITE
    }
    MEM_OP;
endpackage