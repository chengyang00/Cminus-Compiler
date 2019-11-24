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
  br i1 true, label %normal, label %except

except:                                           ; preds = %entry
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %entry
  %array = getelementptr [2 x i32], [2 x i32]* %1, i32 0, i32 0
  store i32 0, i32* %array
  br i1 true, label %normal2, label %except1

except1:                                          ; preds = %normal
  call void @neg_idx_except()
  ret i32 0

normal2:                                          ; preds = %normal
  %array3 = getelementptr [2 x i32], [2 x i32]* %1, i32 0, i32 1
  store i32 2, i32* %array3
  store i32 3, i32* %0
  br i1 true, label %normal5, label %except4

trueBB:                                           ; preds = %normal8
  ret i32 0

falseBB:                                          ; preds = %normal8
  ret i32 1

except4:                                          ; preds = %normal2
  call void @neg_idx_except()
  ret i32 0

normal5:                                          ; preds = %normal2
  %array6 = getelementptr [2 x i32], [2 x i32]* %1, i32 0, i32 1
  %2 = load i32, i32* %array6
  br i1 true, label %normal8, label %except7

except7:                                          ; preds = %normal5
  call void @neg_idx_except()
  ret i32 0

normal8:                                          ; preds = %normal5
  %array9 = getelementptr [2 x i32], [2 x i32]* %1, i32 0, i32 0
  %3 = load i32, i32* %array9
  %4 = icmp sgt i32 %2, %3
  br i1 %4, label %trueBB, label %falseBB
}
