; ModuleID = 'cminus'
source_filename = "assign.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define void @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  %2 = alloca i32
  %3 = alloca i32
  %4 = load i32, i32* %2
  %5 = load i32, i32* %3
  %6 = add nsw i32 %4, %5
  store i32 %6, i32* %1
  store i32 %6, i32* %0
  call void @output(i32 %6)
  %7 = load i32, i32* %0
  call void @output(i32 %7)
  %8 = load i32, i32* %1
  call void @output(i32 %8)
  %9 = load i32, i32* %2
  call void @output(i32 %9)
  %10 = load i32, i32* %3
  call void @output(i32 %10)
  ret void
}
