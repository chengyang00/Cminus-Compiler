; ModuleID = 'cminus'
source_filename = "deadcode.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  store i32 1, i32* %0
  store i32 1, i32* %1
  br i1 false, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  store i32 2, i32* %1
  br label %endBB

endBB:                                            ; preds = %trueBB, %entry
  br i1 true, label %trueBB1, label %endBB2

trueBB1:                                          ; preds = %endBB
  store i32 3, i32* %1
  br label %endBB2

endBB2:                                           ; preds = %trueBB1, %endBB
  %2 = load i32, i32* %1
  %3 = icmp slt i32 %2, 4
  %4 = zext i1 %3 to i32
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %trueBB3, label %endBB4

trueBB3:                                          ; preds = %endBB2
  %6 = load i32, i32* %1
  %7 = add nsw i32 %6, 1
  store i32 %7, i32* %1
  br label %endBB4

endBB4:                                           ; preds = %trueBB3, %endBB2
  %8 = load i32, i32* %1
  ret i32 %8
}
