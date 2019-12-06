; ModuleID = 'cminus'
source_filename = "local-declarations.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @foo() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  ret i32 1
}

define void @main() {
entry:
  %0 = alloca i32
  store i32 1, i32* %0
  %1 = load i32, i32* %0
  call void @output(i32 %1)
  %2 = alloca i32
  store i32 2, i32* %2
  %3 = load i32, i32* %2
  call void @output(i32 %3)
  %4 = alloca i32
  store i32 3, i32* %4
  %5 = load i32, i32* %4
  call void @output(i32 %5)
  %6 = alloca i32
  store i32 4, i32* %6
  %7 = load i32, i32* %6
  call void @output(i32 %7)
  %8 = load i32, i32* %6
  call void @output(i32 %8)
  %9 = load i32, i32* %4
  call void @output(i32 %9)
  %10 = load i32, i32* %0
  call void @output(i32 %10)
  ret void
}
