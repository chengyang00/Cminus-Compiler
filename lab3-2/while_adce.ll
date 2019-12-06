; ModuleID = 'while.ll'
source_filename = "while.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  store i32 1, i32* %0
  br label %jugBB

jugBB:                                            ; preds = %trueBB, %entry
  br i1 false, label %trueBB, label %falseBB

trueBB:                                           ; preds = %jugBB
  %1 = load i32, i32* %0
  %2 = add nsw i32 %1, 1
  store i32 %2, i32* %0
  br label %jugBB

falseBB:                                          ; preds = %jugBB
  %3 = load i32, i32* %0
  ret i32 %3
}
