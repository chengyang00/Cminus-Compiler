; ModuleID = 'commondead.ll'
source_filename = "commondead.cminus"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare i32 @input()

declare void @output(i32)

declare void @neg_idx_except()

define i32 @main() {
entry:
  %0 = alloca i32
  %1 = alloca i32
  store i32 1, i32* %0
  store i32 3, i32* %1
  %2 = load i32, i32* %0
  %3 = icmp sgt i32 %2, 0
  %4 = zext i1 %3 to i32
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %trueBB, label %endBB

trueBB:                                           ; preds = %entry
  ret i32 1
                                                  ; No predecessors!
  br label %endBB

endBB:                                            ; preds = %6, %entry
  ret i32 3
}
