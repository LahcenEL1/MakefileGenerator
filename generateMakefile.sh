#!/bin/dash
#~ clear
count=0

#**************************************************************#
# 				Projet shell : generateMakefile.sh 			   #
#				 Système et programmation système			   #
#							2021-2022						   #
#															   #
#				PERGAUD Sylvain / EL OUARDI Lahcen			   #
#**************************************************************#

#**************************************************************# 		   		
#						FONCTION : --help              		   #

usage()	{
	echo "usage : ./generateMakefile.sh [OPTION]...\n"
	echo "Generates a Makefile from a project written in C language."
	echo "OPTIONS
	--help 			show help and exit\n
	-d ROOTDIR 		Set the root directory of the project.\n
				Without this option, the current directory is used.\n
	-o PROGNAME		Set the name of executable binary file to produce.\n
				Without this option, the name \"a.out\" is used.\n"

}

#**************************************************************#
# 						CHECK OPTION --help                    #
print_usage()
{
	if (test "$1" = "--help") && [ $# -eq 1 ]; then
		usage
		exit 0
	fi
}
#**************************************************************#
# 	  FONCTION : VERIFICATION DE LA VALIDITE DES ARGUMENTS	   #

option_d=""
option_o=""

verif_options()	{
	print_usage $*
	cpt_d=0
	cpt_o=0
	while [ $# -ne 0 ]; do
		case $1 in

		-d) 
			#VERIFICATION DE l'UNICITE DE L'OPTION -d
			if [ $cpt_d -ne 0 ]; then
				echo "ERROR : The -d option can only be present once." >&2
				echo "use : --help for more information" >&2
				exit 1
			fi

			shift
		
			#VERIFICATION DE LA VALIDITE DU REPERTOIRE TRANSMIS
			DIRECTORY=$(echo $1 | grep -E '^./|^../|^[^-][^--]')
			if ! [ -d $DIRECTORY ]; then 
				echo "ERROR : $DIRECTORY isn't a directory" >&2
				echo "use : --help for more information" >&2
				exit 2
			fi
			cpt_d=$(($cpt_d+1))
			option_d=$DIRECTORY
			
			
			;;
		-o)	
			#VERIFICATION DE l'UNICITE DE L'OPTION -o
			if [ $cpt_o -ne 0 ]; then
				echo "ERROR : The -o option can only be present once." >&2
				echo "use : --help for more information" >&2
				exit 3
			fi

			shift

			# VERIFICATION DE LA VALIDITE DU NOM TRANSMIS
			# lettres / chiffre / char : ('.' / ',' / '_' / '-') / sa doit pas commencé par '.'
			PROG_NAME=$1 #c'est sa qu'il faut verifier
			Test=$(echo $PROG_NAME | grep -v -E "[0-9][a-z][A-Z][.][,][-][_]" | grep -v -E ^[.] | wc -l)
			if [ $Test -eq 0 ]; then
				echo "ERROR : The PROGNAME must be a name containing only letters, 
	numbers, and the characters [.] [,] [_] and [-]." >&2
				echo "use : --help for more information" >&2
				exit 4
			fi
			cpt_o=$(($cpt_o+1))
			option_o=$PROG_NAME
			;;
			
		*)
			echo "usage : ./generateMakefile.sh [OPTION]...\n" >&2
			echo "use : --help for more information" >&2
			exit 5
			;;
		esac
		shift
			
	done
	echo "SUCCESS : valid options\n"
	
}

#**************************************************************#
# 	  FONCTION : Trouver les dependances locale d'un fichier   #

# Return :  string L_HEADER (la chaine contenant les dependances locales)
L_HEADERS=""
find_local ()
{
	L_HEADERS=""
	# On recupere les lignes d'include sans le #include et sans les chevrons																		
	headers=$(grep -e "#include" $1 | grep -v "<" | sed -r -e 's/#include//g' -e 's/"//g')
	# On remplace dans le chemin les / par des \/	
	option=$(echo $option_d | sed -r 's|\/|\\/|g')											
	# parametres de sed(1) pour remplacer "fichier" par "ROOTDIR/fichier"
	option="s/.*.h/$option&/"																
	L_HEADERS=$(echo "$L_HEADERS $headers" | tr ' ' '\n' | sort | uniq | sed -r $option | tr '\n' ' ')
}

#**************************************************************#
# 	  FONCTION : Calcul récursif des dependances des fichiers  #

# (dep_fichier : dep_local + dep dep_local)
# Retour : R_HEADERS (string)
R_HEADERS=""
find_recursive()
{
	# On chercher les dependances locales de fichiers
	find_local $1

	# On ajoute ces dependances locales à notre liste de dependance
	# puis on trie et supprime les doublons avec sort(1) et uniq(1)
	TMP_HEADERS=$(echo "$R_HEADERS $L_HEADERS" | tr ' ' '\n' | sort | uniq)			 
	R_HEADERS=$(echo "$R_HEADERS" | tr ' ' '\n' | sort | uniq)						

	# Test de stabilite (on verifie s'il y a eu des ajouts et si c'est pas le cas c'est finis
	# Sinon on recommence)
	if (test "$R_HEADERS" = "$TMP_HEADERS"); then									
		return 0																	
	fi

	# On ajoute les nouveaux ajouts puis on cherche les dependances de ces dependances recursivement
	R_HEADERS="$R_HEADERS $L_HEADERS"												
	for h_file in $L_HEADERS; do													
		find_recursive $h_file
	done
}

#**************************************************************#
# 	  	FONCTION : Trouve les dependances d'un fichiers  	   #

# Return : DEPS (string)
DEPS=""
find_deps()																
{
	R_HEADERS=""		
	# sauvegarde de $1
	src_file="$1"	
	# On trouve les dépendances locales du fichier													
	find_local $1														
	DEPS="$L_HEADERS"
	# On cherche les dépendances de ces dépendances en l'occurence : L_HEADERS
	find_recursive $L_HEADERS	
	# Ajout des dépendances trouvé										
	DEPS="$DEPS $R_HEADERS"	
	# On trie/supprime les doublons et on transforme les saut de lignes en espaces											
	DEPS=$(echo $DEPS | tr ' ' '\n' | sort | uniq | tr '\n' ' ')
	# On rajoute le nom du fichier ($1) au début		
	DEPS="$src_file $DEPS"												
	
}

#**************************************************************#
# 	  				FONCTION : Ecris le MakeFile  	   		   #
gen_Makefile()
{
	echo "Generation :"
	echo ""
	echo "# Created by generateMakefile.sh" > Makefile
	echo "" >> Makefile
	# On définit les variables du Makefile et on les rediriges vers le makefile
	echo "  Writting compilation variables"								
	#	5.6
	echo "CC=cc" >> Makefile
	echo "CFLAGS=" >> Makefile
	echo "LDFLAGS=" >> Makefile
	echo "LDLIBS=" >> Makefile

	# On verifie si on a reçu un nom de programme (l'option -o)
	# Si option_o est vide on appel notre programme a.out
	#	sinon on l'appelle du nom renseigné 
	if [ -z $option_o ]; then											
		echo "PROGNAME=a.out" >> Makefile								
	else
		echo "PROGNAME=$option_o" >> Makefile							
	fi 

	# Idem pour le repertoire a l'exception que s'il est renseigné 
	# il faut le concatener en debut de fichier
	if [ -z $option_d ]; then											
		echo "ROOTDIR=" >> Makefile
	else
		echo "ROOTDIR=$option_d" >> Makefile
	fi 
	echo "" >> Makefile
	echo "  Writting target : [all]"
	#	5.2
	echo "all: \$(PROGNAME)" >> Makefile

	# Ecriture des cibles pour tous les fichiers sources (*.c)
	echo "  Writting object targets :"
	
	#	5.3
	#~ Dépendances locales d'un fichier sources (.c)
	for file in $fichier_c; do
		# On trouve les dependances d'un fichier C puis on les trie
		find_local $file
		L_HEADERS=$(echo $L_HEADERS | tr ' ' '\n' | sort | uniq | tr '\n' ' ')
		# On ajoute au début de la cible le nom_du_fichier.o après transformation
		file_o=$(echo $file | tr ' ' '\n' | sed -r "s|.c|.o|g" | tr '\n' ' ')
		L_HEADERS="$file_o: $file $L_HEADERS"
		echo "    - target [$file]"
		echo "$L_HEADERS" >> Makefile
		
		# On ecrit la ligne de compilation
		echo  "\\t\$(CC) \$(CFLAGS) -c -o \$@ \$<" >> Makefile
		echo "" >> Makefile
	done

	echo "Writting target [\$(PROGNAME)]"					

	#	5.4

	# On ajoute .o a la fin du nom de chaque fichier .c
	fichier_o=$(echo $fichier_c | tr ' ' '\n' | sed -r "s|.c|.o|g" | tr '\n' ' ')
	echo $fichier_o > /tmp/fichier_o.txt
	
	# On ecrit la cible PROGRAMME avec les dependances aux fichiers objets (*.o)
	echo "\$(PROGNAME): $fichier_o" >> Makefile

	# On ecrit la ligne de compilation de l'executable
	echo "\\t\$(CC) \$(CFLAGS) -o \$@ \$^ \$(LDFLAGS)" >> Makefile
	echo "" >> Makefile

	echo "Writting target [clean]"

	#	5.5
	echo "clean:" >> Makefile
	# On ajoute le repertoire a notre clean pour effacer dans le bon dossier
	echo "\\trm -f \$(ROOTDIR)*.o" >> Makefile
	echo "" >> Makefile

	echo "Writting target [mrproper]"
	echo "mrproper: clean" >> Makefile
	echo "\\trm -f \$(PROGNAME)" >> Makefile
	echo ""
	echo "Generated : $(pwd)/Makefile"
	echo "           to be used from directory $(pwd)"
}

########################################################################
####                              MAIN                              ####
########################################################################


verif_options $*

echo "ROOTDIR : $option_d"
echo "PROGNAME : $option_o\n"

WORKDIR=""
#test -z STRING, retourne vrai si la longueur de la chaine = 0
if [ -z $option_d ];then
	WORKDIR="."
else
	WORKDIR=$option_d
fi

#Récuperation des fichiers ".c" contenu dans WORKDIR
fichier_c=$(find $WORKDIR -name "*.c") # | sed -r "s|./||")
if [ -z $option_d ]; then
	fichier_c=$(echo $fichier_c | tr ' ' '\n' | sed -r "s|./||" | tr '\n' ' ')
fi

gen_Makefile $*
