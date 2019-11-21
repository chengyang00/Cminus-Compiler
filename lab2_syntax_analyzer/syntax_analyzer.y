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
	char filename[50][256];
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
