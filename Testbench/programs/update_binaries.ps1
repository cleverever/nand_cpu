cd ..
foreach($file in Get-ChildItem Assembler/*.asm)
{
    python Assembler/assembler.py $file
}
foreach($file in Get-ChildItem Assembler/*.bin)
{
    copy -path $file -Destination Testbench/programs
}