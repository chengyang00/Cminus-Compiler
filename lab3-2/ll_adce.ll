; ModuleID = 'll.ll'
source_filename = "ll.ll"

define dso_local i32 @main() {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 5, i32* %2, align 4
  br label %br1

br1:                                              ; preds = %0
  %3 = load i32, i32* %1
  br label %br2

br2:                                              ; preds = %br1
  store i32 5, i32* %2
  br label %br3

br3:                                              ; preds = %br2
  ret i32 %3
}
