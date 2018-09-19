%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define LIMIT 16

//variables
int cant_var = 0;
struct variable {
  char name[LIMIT];
  int value;
};
struct variable variables[LIMIT];
int val(char var_name[]);
void add_var(char var_name[],int var_value);

//arbol
typedef struct nodos {
  char *info;
  struct nodos *izq;
  struct nodos *der;
}nodo;

nodo *raiz=NULL;

nodo * create_nodo(char inf[],nodo* left, nodo* right);
int evaluar(nodo* reco);
void cargar_variables(nodo* reco);

%}
 
%union { int i; char *s; struct nodos * p;}
 
%token<i> INT
%token<s> ID
%token<s> VAR

%type<p> expresion
%type<p> declaration
 
%left '+'
%left '*'
 
%%
 
program: expresion ';'  {printf("Resultado: %d\n",evaluar($1));} 
    | declaration ';' expresion ';' {cargar_variables($1); printf("Resultado: %d\n",evaluar($3));}
    ; 

declaration: VAR ID '=' expresion { $$ = create_nodo("=",create_nodo($2,NULL,NULL),$4); }
    | declaration ';' VAR ID '=' expresion  { }
    ;
  
expresion: INT          {char str[LIMIT];
                         sprintf(str, "%d", $1);
                         $$ = create_nodo(str,NULL,NULL);
                       }
    | ID                { $$ = create_nodo($1,NULL,NULL); }
    | expresion '+' expresion     { $$ = create_nodo("+",$1,$3);}
    | expresion '*' expresion     { $$ = create_nodo("*",$1,$3);}
    //| '(' expresion ')'           { $$ =  $2; }
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

nodo * create_nodo(char inf[],nodo* left, nodo* right){
    nodo *nuevo;
    nuevo = (nodo*) malloc(sizeof(nodo));
    nuevo->info = inf;
    nuevo->izq = left;
    nuevo->der = right;
    return nuevo;
}

int evaluar(nodo* reco){
  int value;
  if(strcmp(reco->info,"+") == 0)
    value = evaluar(reco->izq) + evaluar(reco->der);
  else if(strcmp(reco->info,"*") == 0)
    value = evaluar(reco->izq) * evaluar(reco->der);
  else if(exists_var(reco->info) != -1){
    value = val(reco->info);
  }
  else{
    value = atoi(reco->info);
  }
  return value;
}

void borrar(nodo *reco){
    if (reco != NULL)
    {
        borrar(reco->izq);
        borrar(reco->der);
        free(reco);
    }
}

void cargar_variables(nodo* reco){
  add_var((reco->izq)->info, evaluar(reco->der));
}