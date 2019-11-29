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
  store i32 3, i32* %0
  br i1 true, label %normal, label %except

except:                                           ; preds = %entry
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %entry
  %2 = getelementptr [2 x i32], [2 x i32]* %1, i32 0, i32 0
  store i32 0, i32* %2
  br i1 true, label %normal2, label %except1

except1:                                          ; preds = %normal
  call void @neg_idx_except()
  ret i32 0

normal2:                                          ; preds = %normal
  %3 = getelementptr [2 x i32], [2 x i32]* %1, i32 0, i32 1
  store i32 2, i32* %3
  ret i32 2
}
