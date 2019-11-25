; ModuleID = 'cminus'
source_filename = "gcd2.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @gcd(i32, i32) {
entry:
  %2 = alloca i32
  %3 = alloca i32
  store i32 %0, i32* %2
  store i32 %1, i32* %3
  %4 = load i32, i32* %3
  %5 = icmp eq i32 %4, 0
  %6 = zext i1 %5 to i32
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %trueBB, label %falseBB

trueBB:                                           ; preds = %entry
  %8 = load i32, i32* %2
  ret i32 %8

falseBB:                                          ; preds = %entry
  %9 = load i32, i32* %3
  %10 = load i32, i32* %2
  %11 = load i32, i32* %2
  %12 = load i32, i32* %3
  %13 = sdiv i32 %11, %12
  %14 = load i32, i32* %3
  %15 = mul nsw i32 %13, %14
  %16 = sub nsw i32 %10, %15
  %17 = call i32 @gcd(i32 %9, i32 %16)
  ret i32 %17
}

define i32 @gcdd(i32*) {
entry:
  %1 = alloca i32*
  store i32* %0, i32** %1
  br i1 true, label %normal, label %except

except:                                           ; preds = %entry
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %entry
  %2 = load i32*, i32** %1
  %3 = getelementptr i32, i32* %2, i32 0
  %4 = load i32, i32* %3
  br i1 true, label %normal2, label %except1

except1:                                          ; preds = %normal
  call void @neg_idx_except()
  ret i32 0

normal2:                                          ; preds = %normal
  %5 = load i32*, i32** %1
  %6 = getelementptr i32, i32* %5, i32 1
  %7 = load i32, i32* %6
  %8 = call i32 @gcd(i32 %4, i32 %7)
  ret i32 %8
}

define void @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  %2 = alloca i32
  %3 = alloca [2 x i32]
  store i32 72, i32* %0
  store i32 18, i32* %1
  %4 = load i32, i32* %0
  %5 = load i32, i32* %1
  %6 = icmp slt i32 %4, %5
  %7 = zext i1 %6 to i32
  %8 = icmp ne i32 %7, 0
  br i1 %8, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  %9 = load i32, i32* %0
  store i32 %9, i32* %2
  %10 = load i32, i32* %1
  store i32 %10, i32* %0
  %11 = load i32, i32* %2
  store i32 %11, i32* %1
  br label %endBB

endBB:                                            ; preds = %trueBB, %entry
  %12 = load i32, i32* %0
  %13 = load i32, i32* %1
  %14 = call i32 @gcd(i32 %12, i32 %13)
  br i1 true, label %normal, label %except

except:                                           ; preds = %endBB
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %endBB
  %15 = getelementptr [2 x i32], [2 x i32]* %3, i32 0, i32 0
  %16 = load i32, i32* %0
  %17 = load i32, i32* %1
  %18 = call i32 @gcd(i32 %16, i32 %17)
  store i32 %18, i32* %15
  br i1 true, label %normal2, label %except1

except1:                                          ; preds = %normal
  call void @neg_idx_except()
  ret i32 0

normal2:                                          ; preds = %normal
  %19 = getelementptr [2 x i32], [2 x i32]* %3, i32 0, i32 1
  %20 = load i32, i32* %1
  store i32 %20, i32* %19
  %21 = call i32 @gcd(i32 %18, i32 %20)
  %22 = add nsw i32 %14, %21
  call void @output(i32 %22)
  %23 = getelementptr [2 x i32], [2 x i32]* %3, i32 0, i32 0
  %24 = call i32 @gcdd(i32* %23)
  call void @output(i32 %24)
  ret void
}
