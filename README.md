# 💰 FamiliaBudget

> Application mobile intelligente de gestion de budget familial

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?logo=postgresql)
![Python](https://img.shields.io/badge/ML-Python-3776AB?logo=python)
![License](https://img.shields.io/badge/License-MIT-green)

---

##  Description

FamiliaBudget est une application mobile Flutter permettant à une famille de gérer ses finances de manière collaborative. Elle offre un suivi des dépenses, une analyse budgétaire avancée et des recommandations intelligentes basées sur le Machine Learning.

Projet de fin d'année — Génie Logiciel × Data Science, ESSAT Gabès.

---

##  Fonctionnalités

-  **Authentification** — Inscription, connexion, gestion des rôles (JWT)
-  **Multi-utilisateurs** — Admin, Utilisateur, Co-utilisateur
-  **Gestion des dépenses** — Catégorisation et suivi en temps réel
-  **Analyse financière** — Graphiques et tableaux de bord interactifs
-  **Intelligence artificielle** — Prévisions budgétaires & recommandations ML
-  **Notifications** — Alertes de dépassement de budget

---

##  Technologies

| Couche | Technologie |
|--------|------------|
| Mobile | Flutter / Dart |
| État | Provider |
| Backend | FastAPI (Python) |
| Base de données | PostgreSQL |
| Authentification | JWT |
| Data Science | Scikit-learn, Pandas, Matplotlib |

---

##  Architecture — Sprints SCRUM

```
Sprint 1 — Gestion des comptes & authentification
Sprint 2 — Structuration des données (PostgreSQL)
Sprint 3 — Analyse financière & visualisation
Sprint 4 — Intelligence ML & recommandations
```

---

##  Installation

```bash
# Cloner le dépôt
git clone https://github.com/HayfaBouali/FamiliaBudget.git
cd FamiliaBudget

# Lancer le frontend Flutter
flutter pub get
flutter run

# Lancer le backend FastAPI
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

---

##  Auteure

**Haifa Bouali** — Étudiante en Génie Logiciel, orientée Data Science  
ESSAT Gabès, Tunisie

---

##  Licence

Ce projet est sous licence [MIT](LICENSE).
