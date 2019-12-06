define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 1, i32* %2, align 4
  store i32 5, i32* %3, align 4
  %4 = load i32, i32* %2
  br label %br1
br1:
  %5 = load i32, i32* %1
  br label %br2
  store i32 7, i32* %3
  br label %br3
br2:
  store i32 5, i32* %3
  br label %br3
  br label %br2
br3:
  ret i32 %5
}
