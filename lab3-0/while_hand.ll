define i32 @main() #0 {
  %a = alloca i32, align 4    ; int a
  %i = alloca i32, align 4    ; int i
  store i32 10, i32* %a, align 4    ; a = 10
  store i32 0, i32* %i, align 4    ; i = 0
  br label %while
  
while:
  %ival = load i32, i32* %i, align 4    ; i value
  %cond = icmp slt i32 %ival, 10
  br i1 %cond, label %true, label %false

true:
  %ival2 = add nsw i32 %ival, 1    ; i = i + 1
  store i32 %ival2, i32* %i, align 4
  %aval = load i32, i32* %a, align 4     ; a value
  %aval2 = add nsw i32 %aval, %ival2    ; a = a + i
  store i32 %aval2, i32* %a, align 4
  br label %while

false:
  %aval3 = load i32, i32* %a, align 4    ; a value
  ret i32 %aval3
}
