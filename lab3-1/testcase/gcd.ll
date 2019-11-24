; ModuleID = 'cminus'
source_filename = "gcd.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  store i32 1, i32* %0
  store i32 10, i32* %1
  br label %jugBB

jugBB:                                            ; preds = %endBB, %entry
  %2 = load i32, i32* %0
  %3 = load i32, i32* %1
  %4 = icmp slt i32 %2, %3
  br i1 %4, label %trueBB, label %falseBB

trueBB:                                           ; preds = %jugBB
  %5 = load i32, i32* %0
  %6 = icmp slt i32 %5, 20
  br i1 %6, label %trueBB1, label %endBB

falseBB:                                          ; preds = %jugBB
  %7 = load i32, i32* %0
  ret i32 %7

trueBB1:                                          ; preds = %trueBB
  %8 = load i32, i32* %0
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %0
  br label %endBB

endBB:                                            ; preds = %trueBB1, %trueBB
  br label %jugBB
}
