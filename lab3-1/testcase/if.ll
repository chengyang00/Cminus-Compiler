; ModuleID = 'cminus'
source_filename = "if.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  br i1 true, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  ret i32 1
  br label %endBB

endBB:                                            ; preds = %trueBB, %entry
  ret i32 2
}
