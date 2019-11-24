; ModuleID = 'cminus'
source_filename = "array1_mlj.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca [2 x i32]
  %array = getelementptr [2 x i32], [2 x i32]* %1, i32 0
  store i32 0, [2 x i32]* %array
  %array1 = getelementptr [2 x i32], [2 x i32]* %1, i32 1
  store i32 2, [2 x i32]* %array1
  store i32 3, i32* %0
  br i1 true, label %trueBB, label %falseBB

trueBB:                                           ; preds = %entry
  ret i32 0

falseBB:                                          ; preds = %entry
  ret i32 1
}
