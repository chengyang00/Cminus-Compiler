; ModuleID = 'cminus'
source_filename = "input_test.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = load i32, i32* %0
  %2 = call i32 @input(i32 %1)
  %3 = load i32, i32* %0
  ret i32 %3
}
