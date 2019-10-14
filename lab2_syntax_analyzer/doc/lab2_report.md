## lab2实验报告

杨城

PB17111659

### 实验要求

本次实验需将flex返回的词法记号进行语法分析，利用LALR技术构建一棵语法分析树，为以后的语义分析做准备。

### 实验设计

1. 为flex和bison设置了共享变量lines，通过在flex的正则表达式的附加C语句添加lines相关代码来更新lines，并在bison程序中的yyerror()函数中使用lines指示错误的所在行，简化代码。
2. 在%union中加入struct _SyntaxTreeNode *node， char *str， int value的声明，IDENTIFIER的声明使用str，NUMBER的声明使用value，非终结符的声明使用node。
3. 在program的产生式中给gt->root赋值，并在所有产生式中创建$$的新节点和终结符的新节点，从而构建出一个正确的语法树。

### 实验结果

1、测试样例：lab2_expression-assign.cminus

```c
int main(void)
{
	a = b = c + d;
	return 0;
}
```

```
>--+ program
|  >--+ declaration-list
|  |  >--+ declaration
|  |  |  >--+ fun-declaration
|  |  |  |  >--+ type-specifier
|  |  |  |  |  >--* int
|  |  |  |  >--* main
|  |  |  |  >--* (
|  |  |  |  >--+ params
|  |  |  |  |  >--* void
|  |  |  |  >--* )
|  |  |  |  >--+ compound-stmt
|  |  |  |  |  >--* {
|  |  |  |  |  >--+ local-declarations
|  |  |  |  |  |  >--* epsilon
|  |  |  |  |  >--+ statement-list
|  |  |  |  |  |  >--+ statement-list
|  |  |  |  |  |  |  >--+ statement-list
|  |  |  |  |  |  |  |  >--* epsilon
|  |  |  |  |  |  |  >--+ statement
|  |  |  |  |  |  |  |  >--+ expression-stmt
|  |  |  |  |  |  |  |  |  >--+ expression
|  |  |  |  |  |  |  |  |  |  >--+ var
|  |  |  |  |  |  |  |  |  |  |  >--* a
|  |  |  |  |  |  |  |  |  |  >--* =
|  |  |  |  |  |  |  |  |  |  >--+ expression
|  |  |  |  |  |  |  |  |  |  |  >--+ var
|  |  |  |  |  |  |  |  |  |  |  |  >--* b
|  |  |  |  |  |  |  |  |  |  |  >--* =
|  |  |  |  |  |  |  |  |  |  |  >--+ expression
|  |  |  |  |  |  |  |  |  |  |  |  >--+ simple-expression
|  |  |  |  |  |  |  |  |  |  |  |  |  >--+ additive-expression
|  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ additive-expression
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ term
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ factor
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ var
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* c
|  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ addop
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* +
|  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ term
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ factor
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ var
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* d
|  |  |  |  |  |  |  |  |  >--* ;
|  |  |  |  |  |  >--+ statement
|  |  |  |  |  |  |  >--+ return-stmt
|  |  |  |  |  |  |  |  >--* return
|  |  |  |  |  |  |  |  >--+ expression
|  |  |  |  |  |  |  |  |  >--+ simple-expression
|  |  |  |  |  |  |  |  |  |  >--+ additive-expression
|  |  |  |  |  |  |  |  |  |  |  >--+ term
|  |  |  |  |  |  |  |  |  |  |  |  >--+ factor
|  |  |  |  |  |  |  |  |  |  |  |  |  >--* 0
|  |  |  |  |  |  |  |  >--* ;
|  |  |  |  |  >--* }

```

2、

- 函数调用：首先调用syntax_main函数，在该函数中调用getAllTestcase函数得到输入文件名并返回文件个数，之后循环调用syntax函数对输入文件进行分析，并把输出放到syntree文件夹中。在syntax函数中，首先调用newSyntaxTree函数新建一个树，并用gt指向它；在每次parse之前调用yyrestart()来确保lex每次从头开始分析而不是从上次的地方继续分析；然后调用yyparse函数开始词法和语法的分析，并且根据编写的产生式构造语法树；之后调用printSyntaxTree打印语法树；最后调用deleteSyntaxTree删除语法树。
- 产生式归约顺序：

```
type-specifier -> int
params -> void
local-declarations -> epsilon
statement-list -> epsilon
var -> a
var -> b
var -> c
factor -> var
term -> factor
additive-expression -> term
addop -> +
var -> d
factor -> var
term -> factor
additive-expression -> additive-expression addop term
simple-expression -> additive-expression
expression -> simple-expression
expression -> var = expression
expression -> var = expression
expression-stmt -> expression;
statement -> expression-stmt
statement-list -> statement-list statement
factor -> 0
term -> factor
additive-expression -> term
simple-expression -> additive-expression
expression -> simple-expression
return-stmt -> return expression;
statement -> return-stmt
statement-list -> statement-list statement
compound-stmt -> { local-declarations statement-list }
fun-declaration -> type-specifier main ( params ) compound-stmt
declaration -> fun-declaration
declaration-list -> declaration
program -> declaration
```

### 实验难点

1. Syntax Error，导致无法输出语法分析树。
   - 解决方案：将lexical_analyzer.l中注释和空白符的返回去除，重新执行，发现可以正确输出语法分析树。
2. 当使用语法错误的输入时，发现输出语法错误的行数不正确。
   - 解决方案：经仔细分析，发现lexical_analyzer.l中的analyzer函数不执行，然后将lines的递增放到正规表达式之后的C语句中，成功解决问题。
3. 学习%union的使用，用其中声明的类型定义token，用yylval传递给bison标识符的文本和整型变量的数字。

### 实验总结

通过此次实验，我学习了git merge的使用和原理，进一步接触到了git版本控制系统；了解了bison的使用，和bison与flex如何协同工作。

### 实验反馈

建议给出更加详细的tutorial。
