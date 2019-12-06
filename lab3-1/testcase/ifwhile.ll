; ModuleID = 'cminus'
source_filename = "ifwhile.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  br i1 true, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  br i1 true, label %trueBB1, label %endBB2

endBB:                                            ; preds = %endBB2, %entry
  ret i32 2

trueBB1:                                          ; preds = %trueBB
  store i32 1, i32* %0
  br label %endBB2

endBB2:                                           ; preds = %trueBB1, %trueBB
  br label %endBB
}
