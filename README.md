# Cartes et Decks Yu-Gi-Oh! Custom — Style Manga/Anime — Project Ignis EDOPro

**Créateurs des cartes et decks custom : Kal / Angel**

Ce dépôt contient des cartes, decks et puzzles pour jouer avec des decks custom inspirés du manga et de l'anime.

## Conditions d’utilisation

1. Les cartes custom sont la propriété de leurs créateurs, **Kal / Angel**.  
2. Il est **interdit** d’utiliser, modifier ou redistribuer ces cartes sans autorisation préalable.  
3. Toute réutilisation (vidéos, serveurs, projets, decks) nécessite une permission explicite.  
4. Usage privé et personnel uniquement, sauf accord contraire.  

> En utilisant ces cartes, vous acceptez ces conditions.

## Installation

1. **Configurer EDOPro pour reconnaître les cartes custom** :  
   Ajoutez le dépôt des cartes dans votre fichier `EDOPro/config/user.json` pour que le jeu charge automatiquement les cartes et decks custom. Exemple :

```json
{
  "repos": [
    {
      "url": "https://github.com/kevinraphael95/vaact_custom_ygo",
      "repo_name": "Vaact Cartes",
      "repo_path": "./repositories/vaact",
      "is_language": false,
      "language": "",
      "data_path": "",
      "should_update": true,
      "should_read": true
    }
  ]
1}
Copier les decks :
Copier tous les fichiers .ydk dans le dossier EDOPro/deck/ de votre installation.

Copier les puzzles :
Copier tous les fichiers .ydk ou .lua correspondants dans le dossier EDOPro/puzzles/ de votre installation.

Ajouter les autres fichiers nécessaires :

Images : copier dans EDOPro/pics/ ou EDOPro/pics/custom/.

Scripts (.lua) : copier dans EDOPro/script/.

Bases de données (.cdb) : copier dans EDOPro/expansions/.

⚠️ Toujours copier-coller, ne pas déplacer l’original pour éviter toute perte.
