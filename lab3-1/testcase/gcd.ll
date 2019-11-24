; ModuleID = 'cminus'
source_filename = "gcd.cminus"
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
  br i1 %5, label %trueBB, label %falseBB

trueBB:                                           ; preds = %entry
  %6 = load i32, i32* %2
  ret i32 %6

falseBB:                                          ; preds = %entry
  %7 = load i32, i32* %3
  %8 = load i32, i32* %2
  %9 = load i32, i32* %2
  %10 = load i32, i32* %3
  %11 = sdiv i32 %9, %10
  %12 = load i32, i32* %3
  %13 = mul nsw i32 %11, %12
  %14 = sub nsw i32 %8, %13
  %15 = call i32 @gcd(i32 %7, i32 %14)
  ret i32 %14
}

define void @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  %2 = alloca i32
  %3 = call i32 @input()
  store i32 %14, i32* %0
  %4 = call i32 @input()
  store i32 %14, i32* %1
  %5 = load i32, i32* %0
  %6 = load i32, i32* %1
  %7 = icmp slt i32 %5, %6
  br i1 %7, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  %8 = load i32, i32* %0
  store i32 %8, i32* %2
  %9 = load i32, i32* %1
  store i32 %9, i32* %0
  %10 = load i32, i32* %2
  store i32 %10, i32* %1
  br label %endBB

endBB:                                            ; preds = %trueBB, %entry
  %11 = load i32, i32* %0
  %12 = load i32, i32* %1
  %13 = call i32 @gcd(i32 %11, i32 %12)
  store i32 %12, i32* %2
  %14 = load i32, i32* %2
  call void @output(i32 %14)
  ret void
}
