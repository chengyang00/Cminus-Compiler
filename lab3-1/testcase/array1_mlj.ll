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
  br i1 true, label %normal4, label %except3

trueBB:                                           ; preds = %normal6
  ret i32 0

falseBB:                                          ; preds = %normal6
  ret i32 1

endBB:                                            ; No predecessors!
  ret i32 0

except3:                                          ; preds = %normal2
  call void @neg_idx_except()
  ret i32 0

normal4:                                          ; preds = %normal2
  %array = getelementptr [2 x i32], [2 x i32]* %1, i32 0, i32 1
  %4 = load i32, i32* %array
  br i1 true, label %normal6, label %except5

except5:                                          ; preds = %normal4
  call void @neg_idx_except()
  ret i32 0

normal6:                                          ; preds = %normal4
  %array7 = getelementptr [2 x i32], [2 x i32]* %1, i32 0, i32 0
  %5 = load i32, i32* %array7
  %6 = icmp sgt i32 %4, %5
  %7 = zext i1 %6 to i32
  %8 = icmp sgt i32 %7, 0
  br i1 %8, label %trueBB, label %falseBB
}
