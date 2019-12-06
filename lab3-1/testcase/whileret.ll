; ModuleID = 'cminus'
source_filename = "whileret.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

@x = common global [25 x i32] zeroinitializer

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  store i32 0, i32* %1
  store i32 0, i32* %0
  br label %jugBB

jugBB:                                            ; preds = %falseBB3, %entry
  %2 = load i32, i32* %0
  %3 = icmp slt i32 %2, 5
  %4 = zext i1 %3 to i32
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %trueBB, label %falseBB

trueBB:                                           ; preds = %jugBB
  br label %jugBB1

falseBB:                                          ; preds = %jugBB
  ret i32 3

jugBB1:                                           ; preds = %trueBB2, %trueBB
  %6 = load i32, i32* %1
  %7 = icmp slt i32 %6, 5
  %8 = zext i1 %7 to i32
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %trueBB2, label %falseBB3

trueBB2:                                          ; preds = %jugBB1
  %10 = load i32, i32* %1
  %11 = add nsw i32 %10, 1
  store i32 %11, i32* %1
  %12 = load i32, i32* %0
  %13 = add nsw i32 %12, 1
  store i32 %13, i32* %0
  ret i32 2
  br label %jugBB1

falseBB3:                                         ; preds = %jugBB1
  %15 = load i32, i32* %0
  %16 = add nsw i32 %15, 1
  store i32 %16, i32* %0
  br label %jugBB
}
