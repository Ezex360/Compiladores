%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define LIMIT 16

  int cant_var = 0;

  struct variable {
    char name[LIMIT];
    int value;
  };

  struct variable variables[LIMIT];

  int val(char var_name[]);
  void add_var(char var_name[],int var_value);

%}
 
%union { int i; char *s; }
 
%token<i> INT
%token<s> ID
%token<s> RW

%type<i> expr
%type<i> statement
 
%left '+'
%left '*'
 
%%
 
prog: prog statement ';'  { } 
    | statement ';' {}
    ; 

statement: expr { printf("%s%d\n", "Resultado: ",$1); }
    | RW ID '=' expr { printf("%s%s%s%d\n","Variable: ",$2," | ",$4 ); add_var($2,$4); }
  
expr: INT               { $$ = $1; 
                           printf("%s%d\n","Constante entera:",$1);
                        }
    | ID                { $$ = val($1);

                        }
    | expr '+' expr     { $$ = $1 + $3; 
                          // printf("%s,%d,%d,%d\n","Operador Suma\n",$1,$3,$1+$3);
                        }
    | expr '*' expr     { $$ = $1 * $3; 
                          // printf("%s,%d,%d,%d\n","Operador Producto\n",$1,$3,$1*$3);  
                        }
    | '(' expr ')'              { $$ =  $2; }
    ;
 
%%


int val(char var_name[]){
  for (int i = 0; i < cant_var; ++i)
  {
    if (strcmp(variables[i].name,var_name) == 0)
    {
      return variables[i].value;
    }
  }
}

int exists_var(char var_name[]){
  for (int i = 0; i < cant_var; ++i)
  {
    if (strcmp(variables[i].name,var_name) == 0)
    {
      return i;
    }
  }
  return -1;
}

void add_var(char var_name[],int var_value){
  int index = exists_var(var_name);
  if (index != -1){
   variables[index].value = var_value;
  }else{
    struct variable var;
    strcpy( var.name, var_name);
    var.value = var_value;
    variables[cant_var++] = var;
  }
}