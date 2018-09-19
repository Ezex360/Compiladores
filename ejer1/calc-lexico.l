%{

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "calc-sintaxis.tab.h"

%}

%option noyywrap
%option yylineno

letra [a-zA-z]
digito [0-9]

%%
"var"                     	  { yylval.s=(char *) malloc(sizeof(yytext)*yyleng);
                                strcpy(yylval.s,yytext);
                                printf("RW : %s\n",yytext);
								return RW;}

{digito}+                     { yylval.i = atoi(yytext);
                                printf("INT : %d\n",atoi(yytext)); 
                                return INT;}

{letra}({letra}|{digito})*    { yylval.s=(char *) malloc(sizeof(yytext)*yyleng);
                                strcpy(yylval.s,yytext);
                                printf("ID : %s\n",yytext);
                                return ID;}

[+*;()=]                   {  printf("%s\n",yytext);
                                  return *yytext;}

.|\n                          ; /* ignore all the rest */

%%

void yyerror(){
	printf("%s%d\n","-> ERROR Sintactico en la linea: ",yylineno);
}

int main(int argc,char *argv[]){
	++argv,--argc;
	if (argc > 0)
		yyin = fopen(argv[0],"r");
	else
		yyin = stdin;

	yyparse();

}
