%option noyywrap
%x comment
%{
/*****************声明和选项设置  begin*****************/
#include <stdio.h>
#include <stdlib.h>

#include "lab1_lexical_analyzer/lexical_analyzer.h"
#include "common/common.h"

#ifndef LAB1_ONLY
#include "syntax_analyzer.h"
#endif

int files_count;
int lines;
int pos_start;
int pos_end;

<<<<<<< HEAD
enum cminus_token_type{
	ERROR = 258,
	ADD = 259,
	SUB = 260,
	MUL = 261,
	DIV = 262,
	LT = 263,
	LTE = 264,
	GT = 265,
	GTE = 266,
	EQ = 267,
	NEQ = 268,
	ASSIN = 269,
	SEMICOLON = 270,
	COMMA = 271,
	LPARENTHESE = 272,
	RPARENTHESE = 273,
	LBRACKET = 274,
	RBRACKET = 275,
	LBRACE = 276,
	RBRACE = 277,
	ELSE = 278,
	IF = 279,
	INT = 280,
	RETURN = 281,
	VOID = 282,
	WHILE = 283,
	IDENTIFIER = 284, 
	NUMBER = 285,
	LETTER = 286,
	ARRAY = 287,
	EOL = 288,
	COMMENT = 289,
	BLANK = 290
};
/*****************end*****************/

%}
/***正规定义***/
digit [0-9]
number {digit}+
letter [A-Za-z]
id {letter}+
array {id}(\[{number}\])+
delim [ \t]
blank {delim}+
=======
/*****************声明和选项设置  end*****************/

%}

commentPattern "/*"([^\*]|(\*)*[^\*/])*(\*)*"*/"
identifierPattern [a-zA-Z][a-zA-Z]*

>>>>>>> upstream/master
%%

 /******************TODO*********************/
 /****请在此补全所有flex的模式与动作  start******/
"+"	{return (ADD);}
"-" {return (SUB);}
"*" {return (MUL);}
"/" {return (DIV);}
"<" {return (LT);}
"<=" {return (LTE);}
">" {return (GT);}
">=" {return (GTE);}
"==" {return (EQ);}
"!=" {return (NEQ);}
"=" {return (ASSIN);}
";" {return (SEMICOLON);}
"," {return (COMMA);}
"(" {return (LPARENTHESE);}
")" {return (RPARENTHESE);}
"[" {return (LBRACKET);}
"]" {return (RBRACKET);}
"{" {return (LBRACE);}
"}" {return (RBRACE);}
"\t" {pos_start += 1;}
else {return ELSE;}
if {return IF;}
int {return INT;}
return {return RETURN;}
void {return VOID;}
while {return WHILE;}
{array} {return ARRAY;}
{id} {return IDENTIFIER;}
{number} {return NUMBER;}
\n {return EOL;}
{blank} {return BLANK;}
"/*" {pos_start += 2; BEGIN comment;}
<comment>"*/" {pos_start += 2; BEGIN 0;}
<comment>. {return COMMENT;}
<comment>\n {return EOL;}

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
	lines = 1;
	pos_start = 1;
	while(token = yylex()){
		pos_start = pos_end;
		pos_end += strlen(yytext);
		switch(token){
			case ERROR:
				pos_end = pos_start + yyleng;
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				pos_start = pos_end;
				break;
			case COMMENT:
				pos_start += 1;
				break;
			case BLANK:
				pos_start += yyleng;
				break;
			case EOL:
				lines += 1;
				pos_start = 1,pos_end = 1;
				break;
			case NUMBER:
				fprintf(fp, "%d\t%d\t%d\t%d\t%d\n",atoi(yytext), token, lines, pos_start, pos_end);
				break;
			default :
				pos_end = pos_start + yyleng;
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n",yytext, token, lines, pos_start, pos_end);
				pos_start = pos_end;
		}
	}
	fclose(fp);
	printf("[END]: Analysis completed.\n");
}

/// \brief get all file paths under 'testcase' directory
///
/// under 'testcase' directory, there could be many *.cminus files.
/// \todo student should fill this function
void getAllTestcase(char filename[][256]){
	DIR *dp = opendir("./testcase");
	int i = 0;
	struct dirent *file;
	while (file = readdir(dp)) {
		if (strstr(file->d_name, ".cminus")) {
			strcpy(filename[i], file->d_name);
			i++;
		}
	}
	files_count = i;
	closedir(dp);
}

/// \brief process all *.cminus file
///
/// note that: use relative path for all i/o operations
int main(int argc, char **argv){
	char filename[10][256];
	char output_file_name[256];
	char suffix[] = ".tokens";
	getAllTestcase(filename);
	for(int i = 0; i < files_count; i++){
		int j = 0;
		while (filename[i][j] != '.') {
			output_file_name[j] = filename[i][j];
			j++;
		}
		output_file_name[j] = 0;
		strcat(output_file_name, suffix);
		analyzer(filename[i],output_file_name);
	}
	return 0;
}

/****************C代码 end*************/
