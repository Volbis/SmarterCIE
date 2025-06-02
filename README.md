# Cahier des Charges : SmartMeter CIE Mini

## 1. Contexte et Objectifs
**Contexte** :  
Dans le cadre d’un hackathon organisé par une entreprise énergétique locale (inspirée de la CIE - Compagnie Ivoirienne d’Électricité), l’objectif est de concevoir une solution innovante pour sensibiliser les ménages à leur consommation électrique et promouvoir des pratiques d’économie d’énergie. Le projet s’inscrit dans un contexte où les foyers ivoiriens, notamment dans les zones urbaines et périurbaines, cherchent des outils simples et accessibles pour mieux gérer leur consommation électrique face à des coûts croissants et des enjeux environnementaux. La solution doit être intuitive, multilingue (Français, Nouchi, Anglais) pour s’adapter au public local, et démontrable sous forme de prototype fonctionnel lors d’une présentation finale devant un jury.  

**Projet** : SmartMeter CIE Mini  
**Durée** : 3 jours  
**Équipe** : 5 personnes  
**Objectif** : Développer une solution légère et fonctionnelle pour surveiller en temps réel (ou simulé) la consommation électrique, avec une interface mobile intuitive, un chatbot IA basique et des alertes intelligentes.  
**Public cible** :  
- Jury du hackathon (évaluation technique et impact visuel).  
- Utilisateurs finaux : ménages ivoiriens souhaitant suivre et optimiser leur consommation énergétique.  

---

## 2. Description du Projet
Le projet consiste à créer une solution composée de :  
- Un **module matériel** (capteur sur Arduino) pour mesurer la consommation électrique.  
- Une **API** pour transmettre les données au cloud.  
- Une **application mobile** pour afficher les données, avec un tableau de bord, un historique et des alertes.  
- Un **chatbot IA** simple, multilingue (Français, Nouchi, Anglais), répondant à des questions sur la consommation.  
- Des **alertes intelligentes** pour signaler les dépassements de seuil et proposer des astuces énergie.

---

## 3. Spécifications Fonctionnelles
### 3.1. Module Matériel
- **Capteur** : Utilisation d’un capteur de courant (ex. SCT-013 ou pince ampèremétrique) connecté à un Arduino.  
- **Fonctionnalités** :  
  - Mesurer l’intensité électrique et calculer la consommation en kWh.  
  - Transférer les données via Wi-Fi (ESP8266) ou Bluetooth vers une API.  
- **Livrable** : Prototype fonctionnel simulant ou mesurant une consommation électrique.

### 3.2. Back-end et API
- **Technologie** : API REST développée avec Flask ou FastAPI.  
- **Base de données** : Firebase ou SQLite pour stocker les données de consommation.  
- **Fonctionnalités** :  
  - Réception des données du capteur.  
  - Mise à disposition des données pour l’application mobile.  
  - Gestion des seuils pour déclencher des alertes.  
- **Livrable** : API fonctionnelle avec endpoints pour les données de consommation et les alertes.

### 3.3. Application Mobile
- **Technologie** : React Native ou Flutter.  
- **Fonctionnalités** :  
  - **Tableau de bord** : Affichage en temps réel (ou simulé) de la consommation (kWh).  
  - **Historique** : Graphique ou liste des consommations passées (par jour/heure).  
  - **Alertes** : Notification visuelle (bulle rouge + message) en cas de dépassement de seuil.  
  - **Astuces énergie** : Affichage aléatoire de conseils pour économiser l’énergie (ex. "Éteignez les appareils en veille").  
- **Interface utilisateur** : Design intuitif avec animations (style WhatsApp).  
- **Livrable** : Application mobile fonctionnelle avec interface claire.

### 3.4. Chatbot IA
- **Technologie** : Rasa, Dialogflow, ou règles simples en JavaScript.  
- **Fonctionnalités** :  
  - Supporte 3 langues : Français, Nouchi, Anglais.  
  - Répond à des questions prédéfinies, par exemple :  
    - "Combien ai-je consommé aujourd’hui ?"  
    - "Est-ce que je dépasse mon seuil ?"  
    - "Comment économiser de l’énergie ?"  
- **Livrable** : Chatbot intégré à l’application, avec réponses pertinentes.

### 3.5. Alertes Intelligentes
- **Fonctionnalités** :  
  - Détection automatique des dépassements de seuil de consommation.  
  - Envoi de notifications visuelles (bulle ou message) dans l’application.  
  - Proposition d’astuces énergie aléatoires pour sensibiliser l’utilisateur.  
- **Livrable** : Système d’alertes fonctionnel et intégré.

---

## 4. Répartition des Rôles
- **Équipe 1 : Prototypage & API (2 personnes)**  
  - Responsable du module matériel (Arduino + capteur).  
  - Développement et test de l’API REST.  
  - Gestion de la base de données.  
- **Équipe 2 : Application & IA (3 personnes)**  
  - Développement de l’application mobile (interface et fonctionnalités).  
  - Implémentation du chatbot IA.  
  - Conception des alertes et de l’UX/UI.

---

## 5. Planification sur 3 Jours
| Jour | Tâches | Livrables |
|------|--------|-----------|
| **Jour 1** | - Configurer le capteur Arduino et l’envoi des données via ESP8266/Bluetooth. <br> - Mettre en place l’API REST et la base de données. <br> - Créer une maquette de l’application mobile. | Prototype capteur fonctionnel, API de base, maquette mobile. |
| **Jour 2** | - Finaliser l’application mobile (tableau de bord, historique, alertes). <br> - Implémenter le chatbot IA basique. <br> - Connecter l’API à l’application. | Application mobile fonctionnelle, chatbot basique, intégration API. |
| **Jour 3** | - Intégrer le chatbot et les alertes intelligentes. <br> - Tester l’ensemble du système. <br> - Préparer une démo en direct. | Solution complète, démo prête pour présentation. |

---

## 6. Contraintes et Recommandations
- **Contraintes** :  
  - Temps limité (3 jours).  
  - Équipe de 5 personnes avec compétences variées (électronique, back-end, front-end, IA).  
  - Technologies légères et accessibles (Arduino, Flask/FastAPI, React Native/Flutter, Rasa/Dialogflow).  
  - Multilinguisme (Français, Nouchi, Anglais) pour répondre au contexte local.  
- **Recommandations** :  
  - Prioriser un prototype fonctionnel (MVP) avec des fonctionnalités essentielles.  
  - Adapter l’interface et le langage du chatbot au public ivoirien (ex. intégration du Nouchi).  
  - Assurer une interface claire et un visuel impactant pour la démo.  
  - Tester régulièrement pour éviter les erreurs d’intégration.  

---

## 7. Critères de Succès
- **Fonctionnalité** : Le prototype mesure (ou simule) la consommation, transmet les données, affiche les résultats et répond via le chatbot.  
- **Accessibilité** : Interface intuitive et multilingue (Français, Nouchi, Anglais).  
- **Impact visuel** : Démo en direct convaincante pour le jury.  
- **Fiabilité** : Système stable lors des tests finaux.  
- **Pertinence culturelle** : Solution adaptée au contexte ivoirien (langues et astuces énergie locales).

---

## 8. Livrables Finaux
- Prototype matériel (Arduino + capteur).  
- API REST opérationnelle avec base de données.  
- Application mobile avec tableau de bord, historique, alertes et chatbot.  
- Démo en direct fonctionnelle.  

---

## 9. Pourquoi ce Projet ?
- **Réaliste** : Faisable en 3 jours avec une équipe de 5 personnes.  
- **Impactant** : Démonstration visuelle claire pour le jury.  
- **Utile** : Solution pratique pour suivre et optimiser la consommation énergétique dans un contexte ivoirien.  
- **Technologique** : Combine électronique, développement mobile et IA légère.  
- **Adapté localement** : Intégration du Nouchi et d’astuces énergie pertinentes pour les ménages ivoiriens.