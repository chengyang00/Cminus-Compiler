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
  store i32 0, i32* %1
  br label %jugBB1

falseBB:                                          ; preds = %jugBB
  store i32 1, i32* %0
  store i32 1, i32* %1
  br label %jugBB4

jugBB1:                                           ; preds = %normal, %trueBB
  %6 = load i32, i32* %1
  %7 = icmp slt i32 %6, 5
  %8 = zext i1 %7 to i32
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %trueBB2, label %falseBB3

trueBB2:                                          ; preds = %jugBB1
  %10 = load i32, i32* %0
  %11 = mul nsw i32 %10, 5
  %12 = load i32, i32* %1
  %13 = add nsw i32 %11, %12
  %14 = icmp sge i32 %13, 0
  br i1 %14, label %normal, label %except

falseBB3:                                         ; preds = %jugBB1
  %15 = load i32, i32* %0
  %16 = add nsw i32 1, %15
  store i32 %16, i32* %0
  br label %jugBB

except:                                           ; preds = %trueBB2
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %trueBB2
  %17 = getelementptr [25 x i32], [25 x i32]* @x, i32 0, i32 %13
  store i32 1, i32* %17
  %18 = load i32, i32* %1
  %19 = add nsw i32 %18, 1
  store i32 %19, i32* %1
  br label %jugBB1

jugBB4:                                           ; preds = %endBB, %falseBB
  %20 = load i32, i32* %0
  %21 = icmp slt i32 %20, 5
  %22 = zext i1 %21 to i32
  %23 = icmp ne i32 %22, 0
  br i1 %23, label %trueBB5, label %falseBB6

trueBB5:                                          ; preds = %jugBB4
  %24 = load i32, i32* %1
  %25 = icmp slt i32 %24, 5
  %26 = zext i1 %25 to i32
  %27 = icmp ne i32 %26, 0
  br i1 %27, label %trueBB7, label %endBB

falseBB6:                                         ; preds = %jugBB4
  ret i32 3

trueBB7:                                          ; preds = %trueBB5
  ret i32 4
  br label %endBB

endBB:                                            ; preds = %trueBB7, %trueBB5
  br label %jugBB4
}
