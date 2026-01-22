# credit-risk-prediction - R

# Prédiction de Défauts de Paiement - Projet R

Projet réalisé en **R** dans le cadre du cours d’**Informatique Décisionnelle** en **Licence 3 Intelligence Artificielle (L3 IA)** à l’**Université Côte d’Azur**.  
L’objectif est de prédire le **risque de défaut de paiement** de clients bancaires à partir de données financières et démographiques.

This project was developed in **R** as part of the **Business Intelligence** course in the **3rd year of the Artificial Intelligence Bachelor's degree (L3 AI)** at **Université Côte d'Azur**.
The objective is to predict the **risk of default** for bank customers based on financial and demographic data.

---

## 📌 Objectifs du projet

- Nettoyer et préparer les données (valeurs manquantes, typage).
- Explorer les variables influençant le risque de défaut.
- Entraîner plusieurs modèles de classification en R :
  - Régression logistique  
  - Arbre de décision  
  - Random Forest  
  - Gradient Boosting (XGBoost)
- Comparer les performances via :
  - Matrice de confusion  
  - Sensibilité (Recall)  
  - Précision  
  - F1-score  
  - AUC ROC
- Sélectionner le modèle le plus performant.
- Générer un fichier CSV pour les nouveaux clients (classe + probabilité).

## 📌 Project Objectives

- Clean and prepare the data (missing values, typing).

- Explore the variables influencing default risk.

- Train several classification models in R:

- Logistic regression

- Decision tree

- Random Forest

- Gradient Boosting (XGBoost)
- Compare performance using:

- Confusion matrix

- Sensitivity (Recall)

- Accuracy

- F1 score
- AUC ROC
- Select the best-performing model.

- Generate a CSV file for new clients (class + probability).
---

## 📂 Données utilisées

- **Data Projet.csv** :  
  6000 clients avec variable `default`.

- **Data Projet New.csv** :  
  500 clients à prédire.

## 📂 Data Used

- **Data Project.csv**:

6000 clients with a `default` variable.

- **Data Project New.csv**:

500 clients to predict.

---

## 🧠 Technologies

- R  
- tidyverse  
- caret  
- rpart  
- randomForest  
- xgboost  
- pROC  

---

## 🏗️ Structure du projet

