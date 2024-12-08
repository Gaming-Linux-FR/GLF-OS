
# Construction de l'ISO

Pour construire l'ISO, suivez les étapes ci-dessous :

1. **Accédez au répertoire** :
   ```sh
   cd chemin/vers/Nixos-by-GLF
   ```

2. **Exécutez la commande de construction** :
   ```sh
   nix build .#iso --impure
   ```


# Alternative (via utilisation de make)

> [!NOTE]  
> Pré-requis: `gnumake` doit être installé  
> Peut être installé temporairement via la commande `nix-shell -p gnumake`  

1. **Contruction de l'iso** :

La construction de l'iso peut être lancée via la commande:  
   ```
   make
   ```

Cette commande exécutera 2 opérations consécutives: `make iso` et `make install`.  

La première aura le même effet que la commande `nix build .#iso` hormis qu'elle ajoutera automatiquement les extra-features `nix-command flakes`.  
La deuxième copiera l'ISO généré (suffixé du nom de la branche courante) dans le répertoire `iso` à la racine du projet et créera son fichier hash associé.  

Exemple de résultat:  
   ```
   $ ls iso
   glfos-24.11.20241202.f9f0d5c_dev.iso  glfos-24.11.20241202.f9f0d5c_dev.iso.sha256sum
   ```

2. **Nettoyage après la construction** : 

Cette commande effacera tout ce qui a été généré localement, ISOs inclus.  

   ```
   make clean
   ```

3. **Test de la configuration nix** : 

> [!WARNING]  
> en cours de développement

Cette commande peut être utilisée pour pour pré-tester la configuration nix présente dans le répertoire `nix-cfg`.  
   ```
   make test
   ```

Elle n'est toutefois pas encore totalement fonctionnelle du fait que la configuration est incomplète.  
L'erreur suivante sera donc produite: 
   ```
       error:
       Failed assertions:
       - The ‘fileSystems’ option does not specify your root file system.
       - You must set the option ‘boot.loader.grub.devices’ or 'boot.loader.grub.mirroredBoots' to make the system bootable.
make: *** [Makefile:6: test] Error 1
   ```
Un patch de la configuration sera sûrement nécessaire à terme pour terminer sans erreur.  
