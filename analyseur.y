%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
void yyerror(const char *s);

typedef struct Symbole {
	char nom[20], type[20];
	int valeur;
}Symbole;

Symbole table_symboles[100];
int taille_table;

int rechercher(char* nom);
void inserer(char* nom, int valeur);
%}

%union {
    int entier;
    char* chaineCaracteres;
}


%token INT EGALE FIN PV PLUS MOINS FOIS DIVISER AFFICHER PAR_G PAR_D PP PG PE GE EE FOR
%token <entier> ENTIER
%token <chaineCaracteres> IDENT
%type <entier> Affectation Expression

%right EGALE
%left EE   
%left PP PG PE GE 
%left PLUS MOINS 
%left FOIS DIVISER 


%% 

Input : 
      | Input Ligne 
      ;

Ligne : Affectation FIN {
          if($1 == 0) { 
              printf("--> Resultat : Affectation sans type.\n"); 
          } else { 
              printf("--> Resultat : Affectation avec type.\n"); 
          }
      }
      | Expression PV FIN {printf("%d\n",$1);}
      | Boucle FIN
      | Fonction FIN
      | FIN 
      ;

Affectation : INT IDENT EGALE ENTIER PV { if(verifierNom($2)){ inserer($2,$4); $$=1; }else printf("Vous ne pouvez pas redéclarer une variable avec son type si elle est deja initialisée."); }
            | IDENT EGALE ENTIER PV     { inserer($1,$3); $$ = 0; }
	    | IDENT EGALE Expression { inserer($1,$3); $$ = 0; }
            ;
	  
Expression: Expression PP Expression { $$ = ($1 < $3); }
          | Expression PG Expression { $$ = ($1 > $3); }
          | Expression PE Expression { $$ = ($1 <= $3); }
          | Expression GE Expression { $$ = ($1 >= $3); }
          | Expression EE Expression { $$ = ($1 == $3); }
	  | Expression PLUS Expression   { $$ = $1 + $3; }
	  | Expression FOIS Expression  { $$ = $1 * $3; }
	  | Expression MOINS Expression { $$ = $1 - $3; }
	  | Expression DIVISER Expression  { $$ = $1 / $3; }
	  | IDENT {int pos = rechercher($1); if(pos != -1){ $$ = table_symboles[pos].valeur;}else{printf("La variable %s n'existe pas.",$1);} }
	  | ENTIER;

Boucle: FOR PAR_G Affectation Expression PV Affectation PAR_D {printf("Structure de la boucle FOR correcte.\n");};

Fonction: AFFICHER PAR_G IDENT PAR_D PV {int index = rechercher($3); if(index != -1){printf("%s = %d\n",table_symboles[index].nom,table_symboles[index].valeur);}else{ printf("La variable %s n'existe pas.",$3);}};
	
%%


int rechercher(char* nom){
	int i;
	for(i = 0;i < taille_table;i++){
		if(strcmp(nom, table_symboles[i].nom)== 0){
			return i;
		}
	}
	return -1;
}

void inserer(char* nom, int valeur){
	int index = rechercher(nom);
	if (index == -1){
		strcpy(table_symboles[taille_table].nom,nom);
		table_symboles[taille_table].nom[19] = '\0';

		table_symboles[taille_table].valeur = valeur;
		taille_table++;
	}
	else
	{
		table_symboles[index].valeur = valeur;
	}
}

int verifierNom(char* nom){
	if (rechercher(nom) == -1) return 1;
	else return 0;
}


void yyerror(const char *s) {
    fprintf(stderr, "Erreur syntaxique : %s\n", s);
}

int main() {
    printf("Entrez votre code (ex: int x = 5 ;):\n");
    yyparse();
    return 0;
}