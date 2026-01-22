### =============================
###   PROJET : Défauts de paiement
###   Script R - Base 
### =============================

# Packages nécessaires
library(tidyverse)
library(caret)
library(xgboost)
library(randomForest)
library(rpart)
library(pROC)



# 1. Importation des données

df <- read.csv("Data Projet.csv")
df_new <- read.csv("Data Projet New.csv")

# Aperçu rapide (optionnel)
# str(df)
# summary(df)

# 1.1 Gestion des valeurs manquantes

# D’après l’énoncé : 999 = valeur manquante pour age et adresse

df$age[df$age == 999] <- NA
df$adresse[df$adresse == 999] <- NA

df_new$age[df_new$age == 999] <- NA
df_new$adresse[df_new$adresse == 999] <- NA


# 1.2 Conversion des types

# Variable cible
df$defaut <- factor(df$defaut, levels = c("Non", "Oui"))

# Education = ordonnée
df$education <- factor(df$education, ordered = TRUE)
df_new$education <- factor(df_new$education, ordered = TRUE)

# Categorie = facteur (mais peut-être constante)
df$categorie <- factor(df$categorie)
df_new$categorie <- factor(df_new$categorie)


# 1.3 Préparation : enlever l'identifiant client


# On garde df complet pour info, mais on crée des versions "modélisation"
df_model <- df
df_model$client <- NULL   # On ne veut pas utiliser l'ID comme variable explicative

df_new_model <- df_new
id_new <- df_new_model$client  # On sauvegarde l'identifiant pour la sortie finale
df_new_model$client <- NULL

# Imputation simple des NA (médiane pour numériques, mode pour facteurs)
for (col in names(df_model)) {
  
  # Numérique dans df_model → médiane
  if (is.numeric(df_model[[col]])) {
    med <- median(df_model[[col]], na.rm = TRUE)
    df_model[[col]][is.na(df_model[[col]])] <- med
  }
  
  # Facteur dans df_model → valeur la plus fréquente
  if (is.factor(df_model[[col]])) {
    mode_value <- names(sort(table(df_model[[col]]), decreasing = TRUE))[1]
    df_model[[col]][is.na(df_model[[col]])] <- mode_value
  }
}

for (col in names(df_new_model)) {
  
  # On se base aussi sur le type dans df_model
  if (is.numeric(df_model[[col]])) {
    med <- median(df_model[[col]], na.rm = TRUE)
    df_new_model[[col]][is.na(df_new_model[[col]])] <- med
  }
  
  if (is.factor(df_model[[col]])) {
    mode_value <- names(sort(table(df_model[[col]]), decreasing = TRUE))[1]
    df_new_model[[col]][is.na(df_new_model[[col]])] <- mode_value
  }
}



# 2. Partitionnement des données


set.seed(123)
trainIndex <- createDataPartition(df_model$defaut, p = 0.7, list = FALSE)
train <- df_model[trainIndex, ]
test  <- df_model[-trainIndex, ]

train <- na.omit(train)
test  <- na.omit(test)



# 2.1 Suppression des variables avec un seul niveau

# Ces variables n'apportent rien et peuvent provoquer l'erreur de "contrastes"

pred_cols <- setdiff(names(train), "defaut")  # colonnes prédictives uniquement

nzv <- nearZeroVar(train[, pred_cols, drop = FALSE], saveMetrics = TRUE)
vars_to_remove <- rownames(nzv[nzv$zeroVar == TRUE, ])

if (length(vars_to_remove) > 0) {
  cat("Variables supprimées car un seul niveau ou zeroVar :", vars_to_remove, "\n")
  train <- train[, !(names(train) %in% vars_to_remove)]
  test  <- test[,  !(names(test)  %in% vars_to_remove)]
  df_new_model <- df_new_model[, !(names(df_new_model) %in% vars_to_remove)]
}


# 2.2 Harmonisation des niveaux des facteurs

# On s'assure que test et df_new_model ont les mêmes levels que train pour chaque facteur

for (col in names(train)) {
  if (is.factor(train[[col]])) {
    # Adapter les niveaux dans test
    if (col %in% names(test)) {
      test[[col]] <- factor(test[[col]], levels = levels(train[[col]]))
    }
    # Adapter les niveaux dans df_new_model
    if (col %in% names(df_new_model)) {
      df_new_model[[col]] <- factor(df_new_model[[col]], levels = levels(train[[col]]))
    }
  }
}

# Vérification rapide (optionnel)
# str(train)
# str(test)
# str(df_new_model)

# 3. Modèles testés

# 3.1 Régression Logistique
logit <- glm(defaut ~ ., data = train, family = binomial)

# 3.2 Random Forest
rf <- randomForest(defaut ~ ., data = train, ntree = 300)

# 3.3 Arbre de décision
tree <- rpart(defaut ~ ., data = train, method = "class")

# Visualisation de l'arbre
# plot(tree)
# text(tree, pretty = 0)

# 3.4 Gradient Boosting (XGBoost)
# Préparation des matrices de design (dummy variables)

X_train <- model.matrix(defaut ~ ., data = train)[, -1]  # on enlève la colonne d'intercept
y_train <- ifelse(train$defaut == "Oui", 1, 0)

X_test  <- model.matrix(defaut ~ ., data = test)[, -1]
y_test  <- ifelse(test$defaut == "Oui", 1, 0)

xgb_model <- xgboost(
  data = X_train,
  label = y_train,
  nrounds = 150,
  objective = "binary:logistic",
  eval_metric = "auc",
  max_depth = 4,
  eta = 0.1,
  verbose = 0
)

# 4. Évaluation des modèles

# 4.1 Régression Logistique

pred_log <- predict(logit, test, type = "response")

# 4.2 Random Forest
pred_rf_prob <- predict(rf, test, type = "prob")[, "Oui"]  # probabilité de la classe "Oui"

# 4.3 XGBoost
pred_xgb <- predict(xgb_model, X_test)  # proba de classe 1 = "Oui"

# 4.4 Calcul des AUC
auc_log <- roc(test$defaut, pred_log)$auc
auc_rf  <- roc(test$defaut, pred_rf_prob)$auc
auc_xgb <- roc(test$defaut, pred_xgb)$auc

cat("AUC - Logistique :", auc_log, "\n")
cat("AUC - Random Forest :", auc_rf, "\n")
cat("AUC - XGBoost :", auc_xgb, "\n")

# On peut aussi calculer des matrices de confusion en choisissant un seuil (0.5 par défaut par ex.)
seuil <- 0.5

pred_log_class <- ifelse(pred_log >= seuil, "Oui", "Non") |> factor(levels = c("Non", "Oui"))
pred_rf_class  <- ifelse(pred_rf_prob >= seuil, "Oui", "Non") |> factor(levels = c("Non", "Oui"))
pred_xgb_class <- ifelse(pred_xgb >= seuil, "Oui", "Non") |> factor(levels = c("Non", "Oui"))

cat("\nMatrice de confusion - Logistique :\n")
print(table(Observé = test$defaut, Prédit = pred_log_class))

cat("\nMatrice de confusion - Random Forest :\n")
print(table(Observé = test$defaut, Prédit = pred_rf_class))

cat("\nMatrice de confusion - XGBoost :\n")
print(table(Observé = test$defaut, Prédit = pred_xgb_class))


# 5. Application du meilleur modèle aux nouvelles données

X_new <- model.matrix(~ ., data = df_new_model)[, -1]
pred_new <- predict(xgb_model, X_new)

classe <- ifelse(pred_new >= seuil, "Oui", "Non")

resultat <- data.frame(
  client = id_new,
  classe = classe,
  probabilite = pred_new
)

# Export des résultats
write.csv(resultat, "resultats_defaut.csv", row.names = FALSE)
cat("\nFichier 'resultats_defaut.csv' généré avec succès.\n")

resultat <- read.csv("resultats_defaut.csv", header = TRUE, sep = ",")
resultat

