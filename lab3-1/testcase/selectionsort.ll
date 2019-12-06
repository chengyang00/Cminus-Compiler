; ModuleID = 'cminus'
source_filename = "selectionsort.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

@x = common global [10 x i32] zeroinitializer

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @minloc(i32*, i32, i32) {
entry:
  %3 = alloca i32*
  %4 = alloca i32
  %5 = alloca i32
  store i32* %0, i32** %3
  store i32 %1, i32* %4
  store i32 %2, i32* %5
  %6 = alloca i32
  %7 = alloca i32
  %8 = alloca i32
  %9 = load i32, i32* %4
  store i32 %9, i32* %8
  %10 = load i32, i32* %4
  %11 = icmp sge i32 %10, 0
  br i1 %11, label %normal, label %except

except:                                           ; preds = %entry
  call void @neg_idx_except()
  ret i32 0

normal:                                           ; preds = %entry
  %12 = load i32*, i32** %3
  %13 = getelementptr i32, i32* %12, i32 %10
  %14 = load i32, i32* %13
  store i32 %14, i32* %7
  %15 = load i32, i32* %4
  %16 = add nsw i32 %15, 1
  store i32 %16, i32* %6
  br label %jugBB

jugBB:                                            ; preds = %trueBB, %normal
  %17 = load i32, i32* %6
  %18 = load i32, i32* %5
  %19 = icmp slt i32 %17, %18
  %20 = zext i1 %19 to i32
  %21 = icmp ne i32 %20, 0
  br i1 %21, label %trueBB, label %falseBB

trueBB:                                           ; preds = %jugBB
  %22 = load i32, i32* %6
  %23 = add nsw i32 %22, 1
  store i32 %23, i32* %6
  br label %jugBB

falseBB:                                          ; preds = %jugBB
  %24 = load i32, i32* %8
  ret i32 %24
}

define void @sort(i32*, i32, i32) {
entry:
  %3 = alloca i32*
  %4 = alloca i32
  %5 = alloca i32
  store i32* %0, i32** %3
  store i32 %1, i32* %4
  store i32 %2, i32* %5
  %6 = alloca i32
  %7 = alloca i32
  %8 = load i32, i32* %4
  store i32 %8, i32* %6
  br label %jugBB

jugBB:                                            ; preds = %entry
  %9 = load i32, i32* %6
  %10 = load i32, i32* %5
  %11 = sub nsw i32 %10, 1
  %12 = icmp slt i32 %9, %11
  %13 = zext i1 %12 to i32
  %14 = icmp ne i32 %13, 0
  br i1 %14, label %trueBB, label %falseBB

trueBB:                                           ; preds = %jugBB
  %15 = alloca i32
  %16 = load i32*, i32** %3
  %17 = load i32, i32* %6
  %18 = load i32, i32* %5
  %19 = call i32 @minloc(i32* %16, i32 %17, i32 %18)
  store i32 %19, i32* %7
  %20 = load i32, i32* %7
  %21 = icmp sge i32 %20, 0
  br i1 %21, label %normal, label %except

falseBB:                                          ; preds = %jugBB
  ret void

except:                                           ; preds = %trueBB
  call void @neg_idx_except()
  ret void

normal:                                           ; preds = %trueBB
  %22 = load i32*, i32** %3
  %23 = getelementptr i32, i32* %22, i32 %20
  %24 = load i32, i32* %23
  store i32 %24, i32* %15
  %25 = load i32, i32* %7
  %26 = icmp sge i32 %25, 0
  br i1 %26, label %normal2, label %except1

except1:                                          ; preds = %normal
  call void @neg_idx_except()
  ret void

normal2:                                          ; preds = %normal
  %27 = load i32*, i32** %3
  %28 = getelementptr i32, i32* %27, i32 %25
  %29 = load i32, i32* %6
  %30 = icmp sge i32 %29, 0
  br i1 %30, label %normal4, label %except3

except3:                                          ; preds = %normal2
  call void @neg_idx_except()
  ret void

normal4:                                          ; preds = %normal2
  %31 = load i32*, i32** %3
  %32 = getelementptr i32, i32* %31, i32 %29
  %33 = load i32, i32* %32
  store i32 %33, i32* %28
  %34 = load i32, i32* %6
  %35 = icmp sge i32 %34, 0
  br i1 %35, label %normal6, label %except5

except5:                                          ; preds = %normal4
  call void @neg_idx_except()
  ret void

normal6:                                          ; preds = %normal4
  %36 = load i32*, i32** %3
  %37 = getelementptr i32, i32* %36, i32 %34
  %38 = load i32, i32* %15
  store i32 %38, i32* %37
  %39 = load i32, i32* %6
  %40 = add nsw i32 %39, 1
  store i32 %40, i32* %6
}

define void @main() {
entry:
  %0 = alloca i32
  store i32 0, i32* %0
  br label %jugBB

jugBB:                                            ; preds = %entry
  %1 = load i32, i32* %0
  %2 = icmp slt i32 %1, 10
  %3 = zext i1 %2 to i32
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %trueBB, label %falseBB

trueBB:                                           ; preds = %jugBB
  %5 = load i32, i32* %0
  %6 = icmp sge i32 %5, 0
  br i1 %6, label %normal, label %except

falseBB:                                          ; preds = %jugBB
  call void @sort(i32* getelementptr inbounds ([10 x i32], [10 x i32]* @x, i32 0, i32 0), i32 0, i32 10)
  store i32 0, i32* %0
  br label %jugBB1

except:                                           ; preds = %trueBB
  call void @neg_idx_except()
  ret void

normal:                                           ; preds = %trueBB
  %7 = getelementptr [10 x i32], [10 x i32]* @x, i32 0, i32 %5
  store i32 1, i32* %7
  %8 = load i32, i32* %0
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %0

jugBB1:                                           ; preds = %trueBB2, %falseBB
  %10 = load i32, i32* %0
  %11 = icmp slt i32 %10, 10
  %12 = zext i1 %11 to i32
  %13 = icmp ne i32 %12, 0
  br i1 %13, label %trueBB2, label %falseBB3

trueBB2:                                          ; preds = %jugBB1
  %14 = load i32, i32* %0
  %15 = add nsw i32 %14, 1
  store i32 %15, i32* %0
  br label %jugBB1

falseBB3:                                         ; preds = %jugBB1
  ret void
}
