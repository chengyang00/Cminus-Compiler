; ModuleID = 'while.c'
source_filename = "while.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
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

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 8.0.1 (tags/RELEASE_801/final)"}
