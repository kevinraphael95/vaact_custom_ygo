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

1. **Decks** : copier les fichiers `.ydk` dans `EDOPro/deck/`.  
2. **Puzzles** : copier les fichiers dans `EDOPro/puzzles/`.  
3. **Images** : copier dans `EDOPro/pics/` ou `EDOPro/pics/custom/`.  
4. **Scripts (.lua)** : copier dans `EDOPro/script/`.  
5. **Bases de données (.cdb)** : copier dans `EDOPro/expansions/`.  
6. **Configuration du fichier `user.json`** : pour que les cartes custom soient reconnues, ajoutez ou modifiez votre fichier `EDOPro/config/user.json` avec le bloc suivant pour inclure le dépôt externe :

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
}
