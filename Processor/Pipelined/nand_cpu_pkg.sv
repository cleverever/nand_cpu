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
        READ,
        WRITE
    }
    MemOp;

    typedef enum
    {
        GSHARE
    }
    PredictorType;

    typedef enum
    {
        READY,
        REQUEST_WRITE,
        WRITING,
        REQUEST_READ,
        READING
    }
    CacheState;

    typedef enum
    {
        READY,
        I_READING,
        D_WRITING,
        D_READY,
        D_READING
    }
    MemState;

    typedef enum
    {
        NONE,
        READ,
        WRITE
    }
    CacheRequest;
endpackage