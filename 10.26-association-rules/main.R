#######################################################
###                 Association Rules         #########
#######################################################
# by juline <3


# Define a project called "Association" and store it in a file called "Modelling Techniques"

# Download and store the dataset "market_basket" and the script into the file "Modelling Techniques"


# Import the dataset

suppressWarnings(retail<-read.transactions('market_basket.csv', format = 'basket', sep=','))

#Installer les packages avant de load la base de données avec la fonction
#La base est au format matrice (nécessaire pour l'association

# Packages

install.packages('arules')
install.packages('arulesViz')
    

library('arules', warn.conflicts=F, quietly=T)
library('arulesViz', warn.conflicts=F, quietly=T)
library('readxl', warn.conflicts=F, quietly=T)

#  A summary of the dataset

retail #voir les caractéristiques de la base (NB colonnes et NB lignes)
summary(retail)#donne les valeurs (items) les plus fréquents

class(retail)

#768: "we have 768 transactions with 5 items"

# Frequent itemset Generation
 
itemsets1 <- apriori(retail,parameter=list(minlen=1,maxlen=1,support=0.001,target="frequent itemsets"))

summary(itemsets1)

#Prendre dans la base les itemset les plus fréquents avec au minimum 1 item


# Top 10 frequent 1-itemsets

inspect(head(sort(itemsets1, by = "support"), 10))

#Sort all the itemset by the SUPPORT (ranking) = mesure of frequency
#The first item : appear 9% in the base
#COUNT : nb de fois ou apparait (nb de transactions avec le itemset correspondant)

# Frequent 2-itemset Generation
  
itemsets2 <- apriori(retail,parameter=list(minlen=2,maxlen=2,support=0.001,target="frequent itemsets"))

#Ici, au moins 2 items dans les itemsets

summary(itemsets2)

  
# Top 10 frequent 2-itemsets

inspect(head(sort(itemsets2, by = "support"), 10))

  
# Frequent 3-itemset Generation
  
itemsets3 <- apriori(retail,parameter=list(minlen=3,maxlen=3,support=0.001,target="frequent itemsets"))



summary(itemsets3)


# Top 10 frequent 3-itemsets

inspect(head(sort(itemsets3, by = "support"), 10))

# Create some rules
 
rules <- apriori(retail, parameter = list(supp=0.001, conf=0.8))

#### APRIORI ALGO ####

# 1 : a priori fuction in the package
# 2 : Arguments
#     -> database
#     -> supp = le minimum support d'où 0.001 
#     -> conf = confidence criteria avec au moins 80%

#Avoir les règles d'itemset avec dès le support minimum et avec le meilleur confidence criteria

rules <- sort(rules, by='confidence', decreasing = TRUE)

#Trie les règles par leur confidence : d'abbord la plus significative (avec la plus haute "conf")
  
summary(rules)

#donne le nb de rules et en fonction du nb d'éléments qu'elle contient, combien il y a des règles 
# ex : Il y a 105 rules avec 2 items

#lift = mesure of the quality of the rule too (en fonction de la confidence et du support cf. plot en dessous )

plot(rules)

#Scatter plot pour voir les fluctuations du support 
# Lift : The lift value of an association rule is the ratio of the confidence of the rule and the expected confidence of the rule. 
#si augmente le support, ya moins de rules

#Maintenant on a les revelant rules

# Finding subsets of rules containing "COFFEE" items
# Trouver avec quoi le Café est associé en fonction des règles qui le contiennent

COFFEE_rules <- subset(rules, items %in% "COFFEE")
inspect(head(sort(COFFEE_rules , by="lift") , 10))

#Donne le Top 10 rules en fonction du lift avec du café dedans
#La première contient Black tea and Coffee et est associé à Sugare and Jar
#La rule X, contient les items lhs X qui sont associés aux items rhs X 

# Finding subsets of rules that precede "SUGAR JARS" purchases
SUGAR_rules <- subset(rules, rhs %pin% "SUGAR JARS")
inspect(SUGAR_rules)

#Etablie les connections entre un good et d'autres goods dispo dans le magasin
  
# The top ten rules sorted by the lift
  
inspect(head(sort(rules , by="lift") , 10))

# Classe les règles en fonction du lift 
#Voir ce que les gens achètent ensemble avec la meilleur "proba" puisqu'on demande de voir les meilleurs règles

# Graph visualization of the top ten rules sorted by lift
  
highLiftRules<-head(sort(rules, by="lift"),10)
plot(highLiftRules, method="graph" , control=list (type="items" ))

#Demande encore les 10 meilleurs règles en fonction du lift
#Obtien un network map
#Un point = un noeud = 1 item 
#Un noeud relie un item en haut et un en bas
#en fonction de la couleur et de la taille, on voit l'importance du noeud 
# Plus le support et bas, plus le lien est faible
