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
    AluOp;

    typedef enum logic
    {
        MEM_READ,
        MEM_WRITE
    }
    MemOp;

    typedef enum
    {
        REQ_NONE,
        REQ_READ,
        REQ_WRITE
    }
    CacheRequest;
endpackage