/*
  Pre-Proyecto Taller de Diseño de Software
  Integrantes:
    Fischer, Sebastian 37128158
    Gardiola, Joaquin 38418091
    Giachero, Ezequiel 39737931
 */

%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define LIMIT 16

//Manejo de tabla de simbolos
int cant_var = 0;
struct variable {
  char name[LIMIT];
  int value;
};
struct variable variables[LIMIT];


//Manejo de arboles
typedef struct nodos {
  char *info;
  struct nodos *izq;
  struct nodos *der;
}nodo;

//Declaracion de Funciones
nodo * create_nodo(char inf[],nodo* left, nodo* right);
int evaluar(nodo* reco);
void cargar_variables(nodo* reco);
void cargar_nodo(nodo* reco);
void borrar(nodo *reco);
int val(char var_name[]);
void add_var(char var_name[],int var_value);
int isNumber(char ch);

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

//Programa
program: expresion ';'  {printf("Resultado: %d\n",evaluar($1)); //Evaluo el arbol
                         borrar($1); //Limpio el arbol
                         exit(0);} //Finalizo programa

    | declaration ';' expresion ';' {cargar_variables($1); //Carga la tabla de simbolos
                                     printf("Resultado: %d\n",evaluar($3)); //Evaluo el arbol de expresiones
                                     borrar($1); //Limpio arboles de variables
                                     borrar($3); //Limpio arboles de expresiones
                                     exit(0);} //Finalizo el programa
    ; 

//Declaraciones
declaration: VAR ID '=' expresion { $$ = create_nodo("=",create_nodo($2,NULL,NULL),$4); }

    | declaration ';' VAR ID '=' expresion  { nodo* def = create_nodo("=",create_nodo($4,NULL,NULL),$6);
                                              $$ = create_nodo(";",def,$1); }
    ;
  
//Expresiones
expresion: INT          {char * str = malloc(sizeof(char[LIMIT]));
                         sprintf(str, "%d", $1);
                         $$ = create_nodo(str,NULL,NULL);}
    | ID                { $$ = create_nodo($1,NULL,NULL); }
    | expresion '+' expresion     { $$ = create_nodo("+",$1,$3);}
    | expresion '*' expresion     { $$ = create_nodo("*",$1,$3);}
    | '(' expresion ')'           { $$ = create_nodo("()",$2,NULL);}
    ;
 
%%

//Funcion que busca una variable por el nombre en la tabla de simbolos y retorna su valor.
int val(char var_name[]){
  for (int i = 0; i < cant_var; ++i)
  {
    if (strcmp(variables[i].name,var_name) == 0)
    {
      return variables[i].value;
    }
  }
}

//Funcion que dado una cadena, la busca en la tabla de simbolos y retorna su posicion en caso de encontrar
//una variable con ese nombre, o -1 en caso de no hacerlo.
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

//Dado un identificador y un valor, los agrega a la tabla de simbolos
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

//Crea un nodo del arbol a partir del campo info, izq y der.
nodo * create_nodo(char inf[],nodo* left, nodo* right){
    nodo *nuevo;
    nuevo = (nodo*) malloc(sizeof(nodo));
    nuevo->info = inf;
    nuevo->izq = left;
    nuevo->der = right;
    return nuevo;
}

//Funcion de evaluacion de expresiones a partir del arbol
int evaluar(nodo* reco){
  int value;
  //Si el nodo es una suma
  if(strcmp(reco->info,"+") == 0)
    value = evaluar(reco->izq) + evaluar(reco->der);
  //Si el nodo es una multiplicacion
  else if(strcmp(reco->info,"*") == 0)
    value = evaluar(reco->izq) * evaluar(reco->der);
  //Si el nodo es una expresion entre parentesis
  else if(strcmp(reco->info,"()") == 0)
    value = evaluar(reco->izq);
  //Si el nodo es un entero
  else if(isNumber(reco->info[0]))
    value = atoi(reco->info);
  //Si el nodo es una variable
  else if(exists_var(reco->info) != -1){
    value = val(reco->info);
  }
  //Si la variable no esta declarada
  else{
    printf("ERROR: La variable %s no existe \n",reco->info); 
    exit(0);
  }
  return value;
}

//Funcion para liberar la memoria
void borrar(nodo *reco){
    if (reco != NULL)
    {
        borrar(reco->izq);
        borrar(reco->der);
        free(reco);
    }
}

void cargar_nodo(nodo* reco){
  add_var((reco->izq)->info, evaluar(reco->der));
}

//Recorre el arbol para cargar las variables en la tabla de simbolos
void cargar_variables(nodo* reco){
  if(reco != NULL){
    if(strcmp(reco->info, "=") == 0){
      cargar_nodo(reco);
    }else{
      cargar_variables(reco->der);
      cargar_variables(reco->izq);
    }
  }
}

//Dado un caracter devuelve 1 si es un numero o un 0 si no lo es
int isNumber(char ch){
  if('0' <= ch && ch <= '9')
    return 1;
  else 
    return 0;
}

/*
void in_order(nodo* reco){
  if(reco != NULL){
    in_order(reco->izq);
    printf(" %s |",reco->info );
    in_order(reco->der);
  }
}
*/