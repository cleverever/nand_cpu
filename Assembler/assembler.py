#TEMP

def parseReg(reg):
    pass

def parseImmdt(immdt):
    pass

def assemble(line):
    trimmed = line.strip()
    decommented = trimmed.split("//")[0]
    spaced = decommented.replace(",", " ")
    args = spaced.split()
    print(args)
    match args[0]:
        case "CL":
            if(len(args) == 1):
                return "00000000"
        case "CP":
            if(len(args) == 2):
                return "0000" + parseReg(args[1])
        case "NND":
            if(len(args) == 2):
                return "0001" + parseReg(args[1])
        case "LS":
            if(len(args) == 2):
                return "0010" + parseReg(args[1])
        case "RS":
            if(len(args) == 2):
                return "0011" + parseReg(args[1])
        case "EQ":
            if(len(args) == 2):
                return "0100" + parseReg(args[1])
        case "NE":
            if(len(args) == 2):
                return "0101" + parseReg(args[1])
        case "BR":
            if(len(args) == 2):
                return "0110" + parseReg(args[1])
        case "JRL":
            if(len(args) == 2):
                return "0111" + parseReg(args[1])
        case "LI":
            if(len(args) == 3):
                return "10" + parseImmdt(args[1]) + parseImmdt(args[2])
        case "LD":
            if(len(args) == 2):
                return "1100" + parseReg(args[1])
        case "ST":
            if(len(args) == 2):
                return "1101" + parseReg(args[1])
        case "INT":
            if(len(args) == 2):
                return "1110" + parseImmdt(args[1])
        case "HLT":
            if(len(args) == 2):
                return "1111" + parseImmdt(args[1])
    #THROW EXCEPTION

assemble("              NAND R0, R1, R3      //TEST")

try:
    temp = 1
except:
    temp = 0
finally:
    temp = -1