; ModuleID = 'cminus'
source_filename = "array2_mlj.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @gcd(i32*) {
entry:
  %1 = alloca i32*
  store i32* %0, i32** %1
  br i1 true, label %normal, label %except

trueBB:                                           ; preds = %normal2
  ret i32 1

falseBB:                                          ; preds = %normal2
  ret i32 0

except:                                           ; preds = %entry
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %entry
  %2 = load i32*, i32** %1
  %3 = getelementptr i32, i32* %2, i32 1
  %4 = load i32, i32* %3
  br i1 true, label %normal2, label %except1

except1:                                          ; preds = %normal
  call void @neg_idx_except()
  ret i32 0

normal2:                                          ; preds = %normal
  %5 = load i32*, i32** %1
  %6 = getelementptr i32, i32* %5, i32 0
  %7 = load i32, i32* %6
  %8 = icmp sgt i32 %4, %7
  %9 = zext i1 %8 to i32
  %10 = icmp ne i32 %9, 0
  br i1 %10, label %trueBB, label %falseBB
}

define void @main() {
entry:
  %0 = alloca [2 x i32]
  %1 = alloca i32
  br i1 true, label %normal, label %except

except:                                           ; preds = %entry
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %entry
  %2 = getelementptr [2 x i32], [2 x i32]* %0, i32 0, i32 1
  store i32 2, i32* %2
  br i1 true, label %normal2, label %except1

except1:                                          ; preds = %normal
  call void @neg_idx_except()
  ret i32 0

normal2:                                          ; preds = %normal
  %3 = getelementptr [2 x i32], [2 x i32]* %0, i32 0, i32 0
  store i32 1, i32* %3
  %4 = getelementptr [2 x i32], [2 x i32]* %0, i32 0, i32 0
  %5 = call i32 @gcd(i32* %4)
  store i32 %5, i32* %1
  ret void
}
