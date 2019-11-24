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
  %4 = load i32, i32* %3
  %5 = icmp eq i32 %4, 0
  br i1 %5, label %trueBB, label %falseBB

trueBB:                                           ; preds = %entry
  %6 = load i32, i32* %2
  ret i32 %6
  br label %endBB

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
  br label %endBB
  br label %endBB

endBB:                                            ; preds = %falseBB, %falseBB, %trueBB
}

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  %2 = alloca i32
  store i32 72, i32* %0
  store i32 18, i32* %1
  %3 = load i32, i32* %0
  %4 = load i32, i32* %1
  %5 = icmp slt i32 %3, %4
  br i1 %5, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  %6 = load i32, i32* %0
  store i32 %6, i32* %2
  %7 = load i32, i32* %1
  store i32 %7, i32* %0
  %8 = load i32, i32* %2
  store i32 %8, i32* %1

endBB:                                            ; preds = %entry
  %9 = load i32, i32* %0
  %10 = load i32, i32* %1
  %11 = call i32 @gcd(i32 %9, i32 %10)
  ret i32 %10
}
