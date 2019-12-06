; ModuleID = 'll.ll'
source_filename = "ll.ll"

define dso_local i32 @main() {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 1, i32* %2, align 4
  store i32 5, i32* %3, align 4
  br label %br1

br1:                                              ; preds = %0
  %4 = load i32, i32* %1
  br label %br2
                                                  ; No predecessors!
  store i32 7, i32* %3
  br label %br3

br2:                                              ; preds = %6, %br1
  store i32 5, i32* %3
  br label %br3
                                                  ; No predecessors!
  br label %br2

br3:                                              ; preds = %br2, %5
  ret i32 %4
}
