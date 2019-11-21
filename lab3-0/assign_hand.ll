define i32 @main() #0 {
  %a = alloca i32, align 4
  store i32 1, i32* %a, align 4
  %b = load i32, i32* %a, align 4
  ret i32 %b
}
