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

define void @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  %2 = alloca i32
  %3 = call i32 @input()
  store i32 %3, i32* %0
  %4 = call i32 @input()
  store i32 %4, i32* %1
  %5 = load i32, i32* %0
  %6 = load i32, i32* %1
  %7 = icmp slt i32 %5, %6
  %8 = zext i1 %7 to i32
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  %10 = load i32, i32* %0
  store i32 %10, i32* %2
  %11 = load i32, i32* %1
  store i32 %11, i32* %0
  %12 = load i32, i32* %2
  store i32 %12, i32* %1
  br label %endBB

endBB:                                            ; preds = %trueBB, %entry
  %13 = load i32, i32* %0
  %14 = load i32, i32* %1
  %15 = call i32 @gcd(i32 %13, i32 %14)
  store i32 %15, i32* %2
  %16 = load i32, i32* %2
  call void @output(i32 %16)
  ret void
}
