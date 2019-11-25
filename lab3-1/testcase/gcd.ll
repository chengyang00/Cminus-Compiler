; ModuleID = 'cminus'
source_filename = "gcd.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

@b = common global i32 zeroinitializer

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define void @sort(i32*) {
entry:
  %1 = alloca i32*
  store i32* %0, i32** %1
  %2 = alloca i32
  br i1 true, label %normal, label %except

except:                                           ; preds = %entry
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %entry
  %3 = load i32*, i32** %1
  %4 = getelementptr i32, i32* %3, i32 1
  %5 = load i32, i32* %4
  store i32 %5, i32* %2
  ret void
}

define void @main() {
entry:
  %0 = alloca [5 x i32]
  br i1 true, label %normal, label %except

except:                                           ; preds = %entry
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %entry
  %1 = getelementptr [5 x i32], [5 x i32]* %0, i32 0, i32 0
  store i32 3, i32* %1
  br i1 true, label %normal2, label %except1

except1:                                          ; preds = %normal
  call void @neg_idx_except()
  ret i32 0

normal2:                                          ; preds = %normal
  %2 = getelementptr [5 x i32], [5 x i32]* %0, i32 0, i32 1
  store i32 2, i32* %2
  br i1 true, label %normal4, label %except3

except3:                                          ; preds = %normal2
  call void @neg_idx_except()
  ret i32 0

normal4:                                          ; preds = %normal2
  %array = getelementptr [5 x i32], [5 x i32]* %0, i32 0, i32 1
  %3 = load i32, i32* %array
  store i32 %3, i32* @b
  %4 = getelementptr [5 x i32], [5 x i32]* %0, i32 0, i32 0
  call void @sort(i32* %4)
  ret void
}
