; ModuleID = 'cminus'
source_filename = "copy_dead.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  %2 = alloca i32
  %3 = alloca i32
  store i32 1, i32* %0
  store i32 2, i32* %2
  %4 = load i32, i32* %2
  store i32 %4, i32* %3
  %5 = load i32, i32* %3
  store i32 %5, i32* %1
  %6 = load i32, i32* %1
  %7 = load i32, i32* %0
  %8 = icmp sgt i32 %6, %7
  %9 = zext i1 %8 to i32
  %10 = icmp ne i32 %9, 0
  br i1 %10, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  store i32 5, i32* %0
  br label %endBB

endBB:                                            ; preds = %trueBB, %entry
  %11 = load i32, i32* %0
  ret i32 %11
}
