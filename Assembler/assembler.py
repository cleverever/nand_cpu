import os
import re
import argparse

class CompileError(Exception):
    def __init__(self, path, line, lineNum, message):
        self.path = path
        self.line = line
        self.lineNum = lineNum
        super().__init__(path + ":" + str(lineNum) + ": error: " + message + "\n" + line)

class InvalidOpError(CompileError):
    def __init__(self, path, line, lineNum, op):
        self.op = op
        super().__init__(path, line, lineNum, "Invalid operator: " + op)

class InvalidNumArgsError(CompileError):
    def __init__(self, path, line, lineNum, numActual, numExpected):
        self.numActual = numActual
        self.numExpected = numExpected
        super().__init__(path, line, lineNum, "Incorrect number of arguments: Actual: " + str(numActual) + " Expected: " + str(numExpected))

class InvalidArgError(CompileError):
    def __init__(self, path, line, lineNum, arg):
        self.arg = arg
        super().__init__(path, line, lineNum, "Invalid argument: " + arg)

line = None
lineNum = None
path = None
def parseReg(reg: str) -> str:
    if(reg.startswith("R")):
        numStr = reg[1:]
    elif(reg.startswith("r")):
        numStr = reg[1:]
    elif(reg.startswith("$")):
        numStr = reg[1:]
    if(not numStr.isnumeric() or "." in numStr):
        raise InvalidArgError(path, line, lineNum, reg)
    num = int(numStr)
    binStr = format(num, "b")
    if(len(binStr) > 4):
        raise Exception
    while(len(binStr) < 4):
        binStr = "0" + binStr
    return binStr


def parseImmdt(immdt: str, size: int) -> str:
    if(immdt.startswith("0b")):
        binStr = immdt[2:]
    elif(immdt.startswith("#")):
        numStr = immdt[1:]
        if(not numStr.isnumeric() or "." in numStr):
            raise InvalidArgError(path, line, lineNum, immdt)
        binStr = format(int(numStr), "b")
    elif(immdt.startswith("0x")):
        hex = immdt[2:]
        if(not re.compile(r"[0-9a-fA-F]").match(hex)):
            raise InvalidArgError(path, line, lineNum, immdt)
        binStr = format(int(hex, 16), "b")
    if(len(binStr) > size):
        raise Exception
    while(len(binStr) < size):
        binStr = "0" + binStr
    return binStr

def assemble(string):
    args = string.split()
    match args[0]:
        case "CL":
            if(len(args) != 1):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 0)
            return "00000000"
        case "CP":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "0000" + parseReg(args[1])
        case "NND":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "0001" + parseReg(args[1])
        case "LS":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "0010" + parseReg(args[1])
        case "RS":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "0011" + parseReg(args[1])
        case "EQ":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "0100" + parseReg(args[1])
        case "NE":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "0101" + parseReg(args[1])
        case "BR":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "0110" + parseReg(args[1])
        case "JRL":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "0111" + parseReg(args[1])
        case "LI":
            if(len(args) != 3):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 2)
            return "10" + parseImmdt(args[2], 2) + parseImmdt(args[1], 4)
        case "LD":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "1100" + parseReg(args[1])
        case "ST":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "1101" + parseReg(args[1])
        case "INT":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "1110" + parseImmdt(args[1], 4)
        case "HLT":
            if(len(args) != 2):
                raise InvalidNumArgsError(path, line, lineNum, len(args) - 1, 1)
            return "1111" + parseImmdt(args[1], 4)
    raise InvalidOpError(path, line, lineNum, args[0])

parser = argparse.ArgumentParser()
parser.add_argument("filename")
args = parser.parse_args()
filename = args.filename
if(not os.path.exists(filename)):
    print("File does not exist")
else:
    path = filename
    try:
        infile = open(filename, "r")
        result = open(filename.rstrip(".asm") + ".bin", "w")
        lineNum = 1
        firstLine = True
        for line in infile:
            trimmed = line.strip()
            decommented = trimmed.split("//")[0]
            spaced = decommented.replace(",", " ")
            if(spaced != ""):
                if(firstLine):
                    firstLine = False
                else:
                    result.write("\n")
                result.write(assemble(spaced))
            lineNum += 1
    except CompileError as e:
        print(e)
    finally:
        infile.close()
        result.close()