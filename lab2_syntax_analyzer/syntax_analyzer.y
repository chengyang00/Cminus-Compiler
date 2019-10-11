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
	SyntaxTreeNode * node;
	char *str[MAX_TOKEN_LEN];
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
%type<node> patam-list
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
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
};

declaration-list: declaration {
	$$ = newSyntaxTreeNode("declaration-list");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | declaration-list declaration {
	$$ = newSyntaxTreeNode("declaration-list");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode_AddChild($$, $2);
	$1->parent = $$;
	$2->parent = $$;
};

declaration: var-declaration {
	$$ = newSyntaxTreeNode("declaration");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | fun-declaration {
	$$ = newSyntaxTreeNode("declaration");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
};

var-declaration: type-specifier IDENTIFIER SEMICOLON {
	$$ = newSyntaxTreeNode("var-declaration");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($2);
	SyntaxTreeNode_AddChild($$, temp1);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp2);
	$1->parent = $$;
	temp1->parent = $$;
	temp2->parent = $$;
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
	$1->parent = $$;
	temp1->parent = $$;
	temp2->parent = $$;
	temp3->parent = $$;
	temp4->parent = $$;
	temp5->parent = $$;
};

type-specifier: INT {
	$$ = newSyntaxTreeNode("type-specifier");
	SyntaxTreeNode *temp = newSyntaxTreeNode("int");
	SyntaxTreeNode_AddChild($$, $1);
	temp->parent = $$;
} | VOID {
	$$ = newSyntaxTreeNode("type-specifier");
	SyntaxTreeNode *temp = newSyntaxTreeNode("void");
	SyntaxTreeNode_AddChild($$, $1);
	temp->parent = $$;
};

fun-declaration: type-specifier IDENTIFIER LPARENTHESE params RPARENTHESE compound-stmt {
	$$ = newSyntaxTreeNode("fun-declaration");
	SyntaxTreeNode_AddChild($$, $1);
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($2);
	SyntaxTreeNode_AddChild($$, $2);
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, $3);
	SyntaxTreeNode_AddChild($$, $4);
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, $5);
	SyntaxTreeNode_AddChild($$, $6);
	$1->parent = $$;
	$4->parent = $$;
	$6->parent = $$;
	temp1->parent = $$;
	temp2->parent = $$;
	temp3->parent = $$;
};

params: param-list {
	$$ = newSyntaxTreeNode("params");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | VOID {
	$$ = newSyntaxTreeNode("params");
	SyntaxTreeNode *temp = newSyntaxTreeNode("void");
	SyntaxTreeNode_AddChild($$, $1);
	temp->parent = $$;
};

param-list: param-list COMMA param {
	$$ = newSyntaxTreeNode("param-list");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode *temp = newSyntaxTreeNode(",");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
} | param {
	$$ = newSyntaxTreeNode("param-list");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
};

param: type-specifier IDENTIFIER {
	$$ = newSyntaxTreeNode("param");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode *temp = newSyntaxTreeNode($2);
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | type-specifier IDENTIFIER LPARENTHESE RPARENTHESE {
	$$ = newSyntaxTreeNode("param");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($2);
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("[");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
	SyntaxTreeNode *temp3 = newSyntaxTreeNode("]");
	SyntaxTreeNode_AddChild($$, temp3);
	temp3->parent = $$;
};

compound-stmt: LBRACE local-declarations statement-list RBRACE {
	$$ = newSyntaxTreeNode("compound-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("{");
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode_AddChild($$, $2);
	$2->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("}");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
};

local-declarations: local-declarations var-declaration {
	$$ = newSyntaxTreeNode("local-declarations");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode_AddChild($$, $2);
	$2->parent = $$;
} | {
	$$ = newSyntaxTreeNodeNoName();
};

statement-list: statement-list statement {
	$$ = newSyntaxTreeNode("statement-list");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode_AddChild($$, $2);
	$2->parent = $$;
} | {
	$$ = newSyntaxTreeNodeNoName();
};

statement: expression-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | compound-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | selection-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | iteration-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | return-stmt {
	$$ = newSyntaxTreeNode("statement");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
};

expression-stmt: expression SEMICOLON {
	$$ = newSyntaxTreeNode("expression-stmt");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode *temp = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | SEMICOLON {
	$$ = newSyntaxTreeNode("expression-stmt");
	SyntaxTreeNode *temp = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
};

selection-stmt: IF LPARENTHESE expression RPARENTHESE statement {
	$$ = newSyntaxTreeNode("selection-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("if");
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp3);
	temp3->parent = $$;
	SyntaxTreeNode_AddChild($$, $5);
	$5->parent = $$;
} | IF LPARENTHESE expression RPARENTHESE statement ELSE statement {
	$$ = newSyntaxTreeNode("selection-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("if");
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp3);
	temp3->parent = $$;
	SyntaxTreeNode_AddChild($$, $5);
	$5->parent = $$;
	SyntaxTreeNode *temp4 = newSyntaxTreeNode("else");
	SyntaxTreeNode_AddChild($$, temp4);
	temp4->parent = $$;
	SyntaxTreeNode_AddChild($$, $7);
	$7->parent = $$;
};

iteration-stmt: WHILE LPARENTHESE expression RPARENTHESE statement {
	$$ = newSyntaxTreeNode("iteration-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("while");
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp3);
	temp3->parent = $$;
	SyntaxTreeNode_AddChild($$, $5);
	$5->parent = $$;
};

return-stmt: RETURN SEMICOLON {
	$$ = newSyntaxTreeNode("return-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("return");
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
} | RETURN expression SEMICOLON {
	$$ = newSyntaxTreeNode("return-stmt");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("return");
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode_AddChild($$, $2);
	$2->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode(";");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
};

expression: var ASSIN expression {
	$$ = newSyntaxTreeNode("expression");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode *temp = newSyntaxTreeNode("=");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
} | simple-expression {
	$$ = newSyntaxTreeNode("expression");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
};

var: IDENTIFIER {
	$$ = newSyntaxTreeNode("var");
	SyntaxTreeNode *temp = newSyntaxTreeNode($1);
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | IDENTIFIER LBRACKET expression RBRACKET {
	$$ = newSyntaxTreeNode("var");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($1);
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("[");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
	SyntaxTreeNode *temp3 = newSyntaxTreeNode("]");
	SyntaxTreeNode_AddChild($$, temp3);
	temp3->parent = $$;
};

simple-expression: additive-expression relop additive-expression {
	$$ = newSyntaxTreeNode("simple-expression");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode_AddChild($$, $2);
	$2->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
} | additive-expression {
	$$ = newSyntaxTreeNode("simple-expression");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
};

relop: LTE {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("<=");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | LT {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("<");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | GT {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode(">");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | GTE {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode(">=");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | EQ {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("==");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | NEQ {
	$$ = newSyntaxTreeNode("relop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("!=");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
};

additive-expression: additive-expression addop term {
	$$ = newSyntaxTreeNode("additive-expression");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode_AddChild($$, $2);
	$2->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
} | term {
	$$ = newSyntaxTreeNode("additive-expression");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
};

addop: ADD {
	$$ = newSyntaxTreeNode("addop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("+");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | SUB {
	$$ = newSyntaxTreeNode("addop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("-");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
};

term: term mulop factor {
	$$ = newSyntaxTreeNode("term");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode_AddChild($$, $2);
	$2->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
} | factor {
	$$ = newSyntaxTreeNode("term");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
};

mulop: MUL {
	$$ = newSyntaxTreeNode("mulop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("*");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
} | DIV {
	$$ = newSyntaxTreeNode("mulop");
	SyntaxTreeNode *temp = newSyntaxTreeNode("/");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
};

factor: LPARENTHESE expression RPARENTHESE {
	$$ = newSyntaxTreeNode("factor");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode_AddChild($$, $2);
	$2->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
} | var {
	$$ = newSyntaxTreeNode("factor");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | call {
	$$ = newSyntaxTreeNode("factor");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | NUMBER {
	$$ = newSyntaxTreeNode("factor");
	SyntaxTreeNode *temp = newSyntaxTreeNodeFromNum($1);
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
};

call: IDENTIFIER LPARENTHESE args RPARENTHESE {
	$$ = newSyntaxTreeNode("call");
	SyntaxTreeNode *temp1 = newSyntaxTreeNode($1);
	SyntaxTreeNode_AddChild($$, temp1);
	temp1->parent = $$;
	SyntaxTreeNode *temp2 = newSyntaxTreeNode("(");
	SyntaxTreeNode_AddChild($$, temp2);
	temp2->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
	SyntaxTreeNode *temp3 = newSyntaxTreeNode(")");
	SyntaxTreeNode_AddChild($$, temp3);
	temp3->parent = $$;
};

args: arg-list {
	$$ = newSyntaxTreeNode("args");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
} | {
	$$ = newSyntaxTreeNodeNoName();
};

arg-list: arg-list COMMA expression {
	$$ = newSyntaxTreeNode("arg-list");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
	SyntaxTreeNode *temp = newSyntaxTreeNode(",");
	SyntaxTreeNode_AddChild($$, temp);
	temp->parent = $$;
	SyntaxTreeNode_AddChild($$, $3);
	$3->parent = $$;
} | expression {
	$$ = newSyntaxTreeNode("arg-list");
	SyntaxTreeNode_AddChild($$, $1);
	$1->parent = $$;
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
