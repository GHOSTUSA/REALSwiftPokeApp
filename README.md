# REALSwiftPokeApp

REALSwiftPokeApp est une application SwiftUI qui permet de visualiser et gérer des Pokémon. L'application récupère des données à partir de l'API de Pokémon, les affiche dans une interface interactive, et utilise CoreData pour stocker les Pokémon localement.

## Structure du projet

Le projet est divisé en plusieurs fichiers qui gèrent différentes parties de l'application :

- **REALSwiftPokeAppApp.swift** : Ce fichier initialise l'application et injecte le contexte CoreData dans l'environnement de SwiftUI pour rendre les données accessibles dans toute l'application.
  
- **PokemonViewModel.swift** : Contient la logique principale de gestion des Pokémon. Il est responsable de la récupération des données depuis l'API, de la gestion de l'état des Pokémon (favoris), ainsi que de la sauvegarde et du chargement de ces données dans CoreData.
  
- **PokemonDetailView.swift** : Affiche les détails d'un Pokémon, y compris son image, ses types, ses statistiques, et permet de l'ajouter aux favoris.

- **CoreData Models** : Gère la persistance des données locales via CoreData. Cela inclut les entités Pokémon et leurs attributs comme l'ID, le nom, l'image, les types, les statistiques, et l'état favori.

## Choix Techniques

### 1. **API de Pokémon** :
   - L'application utilise l'API publique de Pokémon (`https://pokeapi.co/api/v2`) pour récupérer des informations sur les Pokémon. Les données sont récupérées en deux étapes :
     1. Une liste de Pokémon est d'abord obtenue (limité à 151 pour la première génération).
     2. Ensuite, les détails de chaque Pokémon (types, statistiques, etc.) sont récupérés.

### 2. **CoreData pour la persistance** :
   - **CoreData** est utilisé pour stocker localement les Pokémon récupérés, ce qui permet d'éviter de charger les mêmes données à chaque lancement de l'application. Lorsque l'application est ouverte, elle vérifie d'abord si les données sont présentes dans CoreData avant de tenter de récupérer les données depuis l'API.
   - La gestion de CoreData inclut la suppression des anciennes données à chaque mise à jour, mais cela peut être optimisé en modifiant les entités existantes plutôt que de tout supprimer et réinsérer.

### 3. **SwiftUI et Animations** :
   - L'interface est construite avec **SwiftUI**, qui offre une approche déclarative pour la création d'interfaces utilisateur.
   - Des animations sont utilisées pour améliorer l'interaction de l'utilisateur avec des éléments comme l'image du Pokémon, les types, et le bouton des favoris.

### 4. **Utilisation des tâches asynchrones** :
   - L'application utilise des **tâches asynchrones** pour gérer les appels réseau de manière non bloquante et récupérer les données de manière parallèle pour améliorer la performance et l'expérience utilisateur.

