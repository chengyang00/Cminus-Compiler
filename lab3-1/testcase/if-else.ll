; ModuleID = 'cminus'
source_filename = "if-else.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  store i32 1, i32* %0
  store i32 2, i32* %1
  %2 = load i32, i32* %0
  %3 = load i32, i32* %1
  %4 = icmp sgt i32 %2, %3
  %5 = zext i1 %4 to i32
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %trueBB, label %falseBB

trueBB:                                           ; preds = %entry
  ret i32 0

falseBB:                                          ; preds = %entry
  ret i32 1
}
