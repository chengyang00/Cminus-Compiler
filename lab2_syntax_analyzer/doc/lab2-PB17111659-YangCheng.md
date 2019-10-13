# 实验设计

### 代码

syntax_analyzer.y

```c
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/common.h"
#include "syntax_tree/SyntaxTree.h"

#include "lab1_lexical_analyzer/lexical_analyzer.h"

// external functions from lex
extern int yylex();
extern int yyparse();
extern int yyrestart();
extern FILE * yyin;

// external variables from lexical_analyzer module
extern int lines;
extern char * yytext;

// Global syntax tree.
SyntaxTree * gt;

void yyerror(const char * s);
%}

%union {
/********** TODO: Fill in this union structure *********/
	struct _SyntaxTreeNode * node;
	char *str;
	int value;
}

/********** TODO: Your token definition here ***********/
%token ERROR
%token ADD SUB MUL DIV
%token LT LTE GT GTE EQ NEQ
%token ASSIN
%token SEMICOLON COMMA
%token LPARENTHESE RPARENTHESE LBRACKET RBRACKET LBRACE RBRACE
%token ELSE IF
%token INT
%token RETURN
%token VOID
%token WHILE 
%token<str> IDENTIFIER
%token<value> NUMBER
%token ARRAY
%token LETTER
%token EOL
%token COMMENT
%token BLANK
%type<node> program
%type<node> declaration-list
%type<node> declaration
%type<node> var-declaration
%type<node> type-specifier
%type<node> fun-declaration
%type<node> params
%type<node> param-list
%type<node> param
%type<node> compound-stmt
%type<node> local-declarations
%type<node> statement-list
%type<node> statement
%type<node> expression-stmt
%type<node> selection-stmt
%type<node> iteration-stmt
%type<node> return-stmt
%type<node> expression
%type<node> var
%type<node> simple-expression
%type<node> relop
%type<node> additive-expression
%type<node> addop
%type<node> term
%type<node> mulop
%type<node> factor
%type<node> call
%type<node> args
%type<node> arg-list
/* compulsory starting symbol */
%start program

%%
/*************** TODO: Your rules here *****************/
program :declaration-list {
	$$ = newSyntaxTreeNode("program");
	gt->root = $$;
	SyntaxTreeNode_AddChild($$, $1);
};

declaration-list: declaration {
	$$ = newSyntaxTreeNode("declaration-list");
	SyntaxTreeNode_AddChild($$, $1);
} | declaration-list declaration {
	$$ = newSyntaxTreeNode("declaration-list");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode_AddChild($$, $2);
};

declaration: var-declaration {
	$$ = newSyntaxTreeNode("declaration");
	SyntaxTreeNode_AddChild($$, $1);
} | fun-declaration {
	$$ = newSyntaxTreeNode("declaration");
	SyntaxTreeNode_AddChild($$, $1);
};

var-declaration: type-specifier IDENTIFIER SEMICOLON {
	$$ = newSyntaxTreeNode("var-declaration");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($2);
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp2);
} | type-specifier IDENTIFIER LBRACKET NUMBER RBRACKET SEMICOLON {
	$$ = newSyntaxTreeNode("var-declaration");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($2);
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("[");
	SyntaxTreeNode_AddChild($$, temp2);
	SyntaxTreeNode *temp3 = newSyntaxTreeNodeFromNum($4);
	SyntaxTreeNode_AddChild($$, temp3);
	SyntaxTreeNode *temp4 = newSyntaxTreeNode("]");
	SyntaxTreeNode_AddChild($$, temp4);
	SyntaxTreeNode *temp5 = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp5);
};

type-specifier: INT {
	$$ = newSyntaxTreeNode("type-specifier");
	SyntaxTreeNode *temp = newSyntaxTreeNode("int");
	SyntaxTreeNode_AddChild($$, temp);
} | VOID {
	$$ = newSyntaxTreeNode("type-specifier");
	SyntaxTreeNode *temp = newSyntaxTreeNode("void");
	SyntaxTreeNode_AddChild($$, temp);
};

fun-declaration: type-specifier IDENTIFIER LPARENTHESE params RPARENTHESE compound-stmt {
	$$ = newSyntaxTreeNode("fun-declaration");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($2);
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp2);
	SyntaxTreeNode_AddChild($$, $4);
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp3);
	SyntaxTreeNode_AddChild($$, $6);
};

params: param-list {
	$$ = newSyntaxTreeNode("params");
	SyntaxTreeNode_AddChild($$, $1);
} | VOID {
	$$ = newSyntaxTreeNode("params");
	SyntaxTreeNode *temp = newSyntaxTreeNode("void");
	SyntaxTreeNode_AddChild($$, temp);
};

param-list: param-list COMMA param {
	$$ = newSyntaxTreeNode("param-list");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp = newSyntaxTreeNode(",");
	SyntaxTreeNode_AddChild($$, temp);
	SyntaxTreeNode_AddChild($$, $3);
} | param {
	$$ = newSyntaxTreeNode("param-list");
	SyntaxTreeNode_AddChild($$, $1);
};

param: type-specifier IDENTIFIER {
	$$ = newSyntaxTreeNode("param");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp = newSyntaxTreeNode($2);
	SyntaxTreeNode_AddChild($$, temp);
} | type-specifier IDENTIFIER ARRAY {
	$$ = newSyntaxTreeNode("param");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($2);
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("[]");
	SyntaxTreeNode_AddChild($$, temp2);
};

compound-stmt: LBRACE local-declarations statement-list RBRACE {
	$$ = newSyntaxTreeNode("compound-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("{");
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode_AddChild($$, $2);
	SyntaxTreeNode_AddChild($$, $3);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("}");
	SyntaxTreeNode_AddChild($$, temp2);
};

local-declarations: local-declarations var-declaration {
	$$ = newSyntaxTreeNode("local-declarations");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode_AddChild($$, $2);
} | {
	$$ = newSyntaxTreeNode("local-declarations");
	SyntaxTreeNode *temp = newSyntaxTreeNode("epsilon");
	SyntaxTreeNode_AddChild($$, temp);
};

statement-list: statement-list statement {
	$$ = newSyntaxTreeNode("statement-list");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode_AddChild($$, $2);
} | {
	$$ = newSyntaxTreeNode("statement-list");
	SyntaxTreeNode *temp = newSyntaxTreeNode("epsilon");
	SyntaxTreeNode_AddChild($$, temp);
};

statement: expression-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
} | compound-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
} | selection-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
} | iteration-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
} | return-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
};

expression-stmt: expression SEMICOLON {
	$$ = newSyntaxTreeNode("expression-stmt");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp);
	
} | SEMICOLON {
	$$ = newSyntaxTreeNode("expression-stmt");
	SyntaxTreeNode *temp = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp);
	
};

selection-stmt: IF LPARENTHESE expression RPARENTHESE statement {
	$$ = newSyntaxTreeNode("selection-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("if");
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp2);
	SyntaxTreeNode_AddChild($$, $3);
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp3);
	SyntaxTreeNode_AddChild($$, $5);
} | IF LPARENTHESE expression RPARENTHESE statement ELSE statement {
	$$ = newSyntaxTreeNode("selection-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("if");
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp2);
	SyntaxTreeNode_AddChild($$, $3);
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp3);
	SyntaxTreeNode_AddChild($$, $5);
	SyntaxTreeNode *temp4 = newSyntaxTreeNode("else");
	SyntaxTreeNode_AddChild($$, temp4);
	SyntaxTreeNode_AddChild($$, $7);
};

iteration-stmt: WHILE LPARENTHESE expression RPARENTHESE statement {
	$$ = newSyntaxTreeNode("iteration-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("while");
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp2);
	SyntaxTreeNode_AddChild($$, $3);
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp3);
	SyntaxTreeNode_AddChild($$, $5);
};

return-stmt: RETURN SEMICOLON {
	$$ = newSyntaxTreeNode("return-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("return");
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp2);
} | RETURN expression SEMICOLON {
	$$ = newSyntaxTreeNode("return-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("return");
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode_AddChild($$, $2);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp2);
};

expression: var ASSIN expression {
	$$ = newSyntaxTreeNode("expression");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp = newSyntaxTreeNode("=");
	SyntaxTreeNode_AddChild($$, temp);
	SyntaxTreeNode_AddChild($$, $3);
} | simple-expression {
	$$ = newSyntaxTreeNode("expression");
	SyntaxTreeNode_AddChild($$, $1);
};

var: IDENTIFIER {
	$$ = newSyntaxTreeNode("var");
	SyntaxTreeNode *temp = newSyntaxTreeNode($1);
	SyntaxTreeNode_AddChild($$, temp);
} | IDENTIFIER LBRACKET expression RBRACKET {
	$$ = newSyntaxTreeNode("var");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($1);
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("[");
	SyntaxTreeNode_AddChild($$, temp2);
	SyntaxTreeNode_AddChild($$, $3);
	SyntaxTreeNode *temp3 = newSyntaxTreeNode("]");
	SyntaxTreeNode_AddChild($$, temp3);
};

simple-expression: additive-expression relop additive-expression {
	$$ = newSyntaxTreeNode("simple-expression");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode_AddChild($$, $2);
	SyntaxTreeNode_AddChild($$, $3);
} | additive-expression {
	$$ = newSyntaxTreeNode("simple-expression");
	SyntaxTreeNode_AddChild($$, $1);
};

relop: LTE {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("<=");
	SyntaxTreeNode_AddChild($$, temp);
} | LT {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("<");
	SyntaxTreeNode_AddChild($$, temp);
} | GT {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode(">");
	SyntaxTreeNode_AddChild($$, temp);
} | GTE {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode(">=");
	SyntaxTreeNode_AddChild($$, temp);
} | EQ {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("==");
	SyntaxTreeNode_AddChild($$, temp);
	
} | NEQ {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("!=");
	SyntaxTreeNode_AddChild($$, temp);
};

additive-expression: additive-expression addop term {
	$$ = newSyntaxTreeNode("additive-expression");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode_AddChild($$, $2);
	SyntaxTreeNode_AddChild($$, $3);
} | term {
	$$ = newSyntaxTreeNode("additive-expression");
	SyntaxTreeNode_AddChild($$, $1);
};

addop: ADD {
	$$ = newSyntaxTreeNode("addop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("+");
	SyntaxTreeNode_AddChild($$, temp);
} | SUB {
	$$ = newSyntaxTreeNode("addop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("-");
	SyntaxTreeNode_AddChild($$, temp);
};

term: term mulop factor {
	$$ = newSyntaxTreeNode("term");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode_AddChild($$, $2);
	SyntaxTreeNode_AddChild($$, $3);
} | factor {
	$$ = newSyntaxTreeNode("term");
	SyntaxTreeNode_AddChild($$, $1);
};

mulop: MUL {
	$$ = newSyntaxTreeNode("mulop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("*");
	SyntaxTreeNode_AddChild($$, temp);
} | DIV {
	$$ = newSyntaxTreeNode("mulop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("/");
	SyntaxTreeNode_AddChild($$, temp);
};

factor: LPARENTHESE expression RPARENTHESE {
	$$ = newSyntaxTreeNode("factor");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode_AddChild($$, $2);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp2);
} | var {
	$$ = newSyntaxTreeNode("factor");
	SyntaxTreeNode_AddChild($$, $1);
} | call {
	$$ = newSyntaxTreeNode("factor");
	SyntaxTreeNode_AddChild($$, $1);
} | NUMBER {
	$$ = newSyntaxTreeNode("factor");
	SyntaxTreeNode *temp = newSyntaxTreeNodeFromNum($1);
	SyntaxTreeNode_AddChild($$, temp);
};

call: IDENTIFIER LPARENTHESE args RPARENTHESE {
	$$ = newSyntaxTreeNode("call");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($1);
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp2);
	SyntaxTreeNode_AddChild($$, $3);
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp3);
};

args: arg-list {
	$$ = newSyntaxTreeNode("args");
	SyntaxTreeNode_AddChild($$, $1);
} | {
	$$ = newSyntaxTreeNode("args");
	SyntaxTreeNode *temp = newSyntaxTreeNode("epsilon");
	SyntaxTreeNode_AddChild($$, temp);
};

arg-list: arg-list COMMA expression {
	$$ = newSyntaxTreeNode("arg-list");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp = newSyntaxTreeNode(",");
	SyntaxTreeNode_AddChild($$, temp);
	SyntaxTreeNode_AddChild($$, $3);
} | expression {
	$$ = newSyntaxTreeNode("arg-list");
	SyntaxTreeNode_AddChild($$, $1);
};
%%

void yyerror(const char * s)
{
	// TODO: variables in Lab1 updates only in analyze() function in lexical_analyzer.l
	//       You need to move position updates to show error output below
	fprintf(stderr, "%s:%d syntax error for %s\n", s, lines, yytext);
}

/// \brief Syntax analysis from input file to output file
///
/// \param input basename of input file
/// \param output basename of output file
void syntax(const char * input, const char * output)
{
	gt = newSyntaxTree();
	lines = 1;

	char inputpath[256] = "./testcase/";
	char outputpath[256] = "./syntree/";
	strcat(inputpath, input);
	strcat(outputpath, output);

	if (!(yyin = fopen(inputpath, "r"))) {
		fprintf(stderr, "[ERR] Open input file %s failed.", inputpath);
		exit(1);
	}
	yyrestart(yyin);
	printf("[START]: Syntax analysis start for %s\n", input);
	FILE * fp = fopen(outputpath, "w+");
	if (!fp)	return;

	// yyerror() is invoked when yyparse fail. If you still want to check the return value, it's OK.
	// `while (!feof(yyin))` is not needed here. We only analyze once.
	yyparse();

	printf("[OUTPUT] Printing tree to output file %s\n", outputpath);
	printSyntaxTree(fp, gt);
	deleteSyntaxTree(gt);
	gt = 0;

	fclose(fp);
	printf("[END] Syntax analysis end for %s\n", input);
}

/// \brief starting function for testing syntax module.
///
/// Invoked in test_syntax.c
int syntax_main(int argc, char ** argv)
{
	char filename[10][256];
	char output_file_name[256];
	const char * suffix = ".syntax_tree";
	int fn = getAllTestcase(filename);
	for (int i = 0; i < fn; i++) {
		int name_len = strstr(filename[i], ".cminus") - filename[i];
		strncpy(output_file_name, filename[i], name_len);
		strcpy(output_file_name+name_len, suffix);
		syntax(filename[i], output_file_name);
	}
	return 0;
}

```

lexical_analyzer.l

```c
%option noyywrap
%{
/*****************声明和选项设置  begin*****************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lab1_lexical_analyzer/lexical_analyzer.h"
#include "common/common.h"

#ifndef LAB1_ONLY
#include "syntax_analyzer.h"
#endif

int files_count;
int lines;
int pos_start;
int pos_end;

/*****************声明和选项设置  end*****************/

%}

commentPattern "/*"([^\*]|(\*)*[^\*/])*(\*)*"*/"
digitPattern [0-9]
numberPattern {digitPattern}+
identifierPattern [a-zA-Z][a-zA-Z]*

%%

 /******************TODO*********************/
 /****请在此补全所有flex的模式与动作  start******/

{commentPattern} {
	for (int j = 0; j < strlen(yytext); j++)
	{
		if (yytext[j] == '\n') {
			lines++;
		}
	}
	#ifdef LAB1_ONLY
	return COMMENT;
	#endif
}
"+" {return ADD;}
"-" {return SUB;}
"*" {return MUL;}
"/" {return DIV;}

"<" {return LT;}
"<=" {return LTE;}
">" {return GT;}
">=" {return GTE;}
"==" {return EQ;}
"!=" {return NEQ;}
"=" {return ASSIN;}
";" {return SEMICOLON;}
"," {return COMMA;}
"(" {return LPARENTHESE;}
")" {return RPARENTHESE;}
"[" {return LBRACKET;}
"]" {return RBRACKET;}
"{" {return LBRACE;}
"}" {return RBRACE;}
"[]" {return ARRAY;}
"else" {return ELSE;}
"if" {return IF;}
"int" {return INT;}
"return" {return RETURN;}
"void" {return VOID;}
"while" {return WHILE;}
{identifierPattern} {
	#ifndef LAB1_ONLY
	yylval.str = strdup(yytext);
	#endif
	return IDENTIFIER;
}
{numberPattern} {
	#ifndef LAB1_ONLY
	yylval.value = atoi(yytext);
	#endif
	return NUMBER; 
}

\n { 
	lines++;
	#ifdef LAB1_ONLY
	return EOL;
	#endif
}
[ \t] {
	#ifdef LAB1_ONLY
	return BLANK;
	#endif
}

. {return ERROR;}



 /****请在此补全所有flex的模式与动作  end******/
%%
/****************C代码 start*************/

/// \brief analysize a *.cminus file
///
///	\param input_file_name
/// \param output_file_name
void analyzer(char* input_file_name, char* output_file_name){
	lines = 1;
	pos_start = 1;
	pos_end = 1;
	char input_path[256] = "./testcase/";
	strcat(input_path, input_file_name);
	char output_path[256] = "./tokens/";
	strcat(output_path, output_file_name);
	if(!(yyin = fopen(input_path,"r"))){
		printf("[ERR] No input file\n");
		exit(1);
	}
	printf("[START]: Read from: %s\n", input_file_name);
	FILE *fp = fopen(output_path,"w+");

	int token;
	while ((token = yylex())) {
		pos_start = pos_end;
		pos_end += strlen(yytext);
		switch (token) {
			case ERROR:
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				break;
			case COMMENT: {
				pos_end -= strlen(yytext);
				for (int i = 0; i < strlen(yytext); i++)
				{
					if (yytext[i] == '\n') {
						pos_start = pos_end = 1;
        	        }
					else {
                		pos_end++;
					}
				}
				break;
			}
			case BLANK:
				break;
			case EOL:
				pos_start = 1,pos_end = 1;
				break;
			case NUMBER:
				fprintf(fp, "%d\t%d\t%d\t%d\t%d\n",atoi(yytext), token, lines, pos_start, pos_end);
				break;
			default :
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n",yytext, token, lines, pos_start, pos_end);
		}
	}
	fclose(fp);
	printf("[END]: Analysis completed.\n");
}

/// \brief process all *.cminus file
///
/// note that: use relative path for all i/o operations
int lex_main(int argc, char **argv){
	char filename[10][256];
	char output_file_name[256];
	char suffix[] = ".tokens";
	files_count = getAllTestcase(filename);
	for(int i = 0; i < files_count; i++){
			int name_len = strstr(filename[i], ".cminus")-filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);
			analyzer(filename[i],output_file_name);
	}
	return 0;
}
/****************C代码 end*************/

```

### 设计原理

- 在lexical_analyzer.l中完成行数的递增，并取消注释、空白符的返回。
- 在syntax_analyzer.y中完成产生式，并将分析树从gt建立起来，并成功输出，完成实验。

### 遇到的问题及解决方案

1. Syntax Error，导致无法输出语法分析树。
   - 解决方案：将lexical_analyzer.l中注释和空白符的返回去除，重新执行，发现可以正确输出语法分析树。
2. 当使用语法错误的输入时，发现输出语法错误的行数不正确。
   - 解决方案：经仔细分析，发现lexical_analyzer.l中的analyzer函数不执行，然后将lines的递增放到正规表达式之后的C语句中，成功解决问题。

### 花费时间

1. 了解bison：3h
2. 理解实验：4h
3. 代码编写：4h
4. debug：3h
5. 写报告：0.5h

总计：14.5h