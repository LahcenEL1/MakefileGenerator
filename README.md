-------------------------------------------------
# 					PROJET SHELL
# 		PERGAUD Sylvain / EL OUARDI Lahcen
-------------------------------------------------

##	Conclusion / Bilan sur le produit final

* Exo 1 Taux de réalisation : 100%
    * Reprise du Makefile réalisé au TD 
    * Nous avons sauvegardé dans des variable option_o et option_d, respectivement PROGNAME et WORKDIR.

* Exo 2 Taux de réalisation : 100%
    * Pour commencer, nous avons créé la fonction usage() qui permet d’afficher le message indiqué dans le sujet du projet.
    * On a traité le cas ou un repertoire spécifique est renseigné, dans le cas ou se dernier n'est pas renseigné, le répertoire racine est utilisé par défaut.
    * On a implémenté une fonction verif_options(), qui vérifie la validité de chacun des arguments transmis
    
* Exo 3 Taux de réalisation : 100%
    * On a implémenté une fonction find_local() qui permet de selectionner les lignes du fichier qui contient les directives d'inclusion, en supprimant les **"#include"** et les **"<>"**. Notre fonction retourne une variable de type String L_HEADER qui contient les dépendances locales

* Exo 4 Taux de réalisation : 100%
    * On a implémenté une fonction find_recursive() qui permet de calculer **les dependances des dependances** d'un fichier recursivement, tant que la condition de stabilité n'est pas respecté jusqu'a que B=A (i.e.Enoncé). Notre fonction retourne une variable de type String R_HEADER qui contient les dependances de tout les fichiers inclus dans les fichiers
    * On a implémenté une fonction find_deps() qui permet de trouver les dependances, elle va s'aider des deux fonctions precedentes respectivement find_local() et find_recursive(), la suppression des doublons est bien respecté. Notre fonction retourne une variable DEPS qui contient toutes les dependances precédement calculé.
* Exo 5 Taux de réalisation : 98%
    * On a implémenté une fonction gen_Makefile() qui permet de generer le Makefile proprement dit, par le biais de la redirection de flux.
    * Nous avons respecté l'intégralité des demandes et tout fonctionne, à l'exception de la possibilité d'appeler notre script avec les variables CFLAGS, LDFLAGS, LDLIBS (i.e. Q5.6), Mais nous avons pris la presence de ces variables dans l'implementation de notre fonction, mais il est notament possible d'utiliser ces dernière en les redigeants en BRUT dans le code.


##	Présentation des améliorations possible
* 
    * Rajouter la possibilité de prendre en compte les répertoires avec des sous-répertoires.
    * De réaliser des fonctionnalités supplémentaires pour qu'il soit fonctionnel avec le C++.

##	Bilan par rapport au travail en binôme
* 
    * Nous avons appris de nos erreurs passé, nous avions des problèmes d'organisation, et nous cherchions à travailler ensemble en présentiel. 
    * Cependant cette année nous avons priorisé des options tel qu'un dépôt git, mais également l'extention liveShare qui nous as permis de travaillé simultanément sur un même fichier.
    * Enfin, ces outils cumulé et une bonne répartition des tâches nous as permis de travailler de manière beaucoup plus optimale, nous nous sommes entraidé et avons renforcer nos acquis.
