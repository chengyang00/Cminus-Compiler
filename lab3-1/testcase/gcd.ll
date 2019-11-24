; ModuleID = 'cminus'
source_filename = "gcd.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define void @gcd() {
entry:
  %0 = alloca i32
  store i32 1, i32* %0
  ret void
}

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  %2 = alloca i32
  store i32 2, i32* %0
  store i32 1, i32* %0
  ret i32 0
}
