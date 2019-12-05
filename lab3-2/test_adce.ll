; ModuleID = 'test.ll'
source_filename = "test.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  store i32 1, i32* %0
  br i1 true, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  store i32 2, i32* %0
  br label %endBB

endBB:                                            ; preds = %trueBB, %entry
  %1 = load i32, i32* %0
  ret i32 %1
}
