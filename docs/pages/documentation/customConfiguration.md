---
title: Configurations personnalisées
layout: default
parent: Documentation
---

# Configurations personnalisées

**GLF-OS** fournit un espace pour ajouter vos configurations personnalisés dans `/etc/nixos/customConfig/default.nix`
Si la configuration actuelle et les flatpaks ne répondent pas entièrement à vos besoins, vous avez la possibilité de modifier la configuration. 

Voici un exemple pratique, nous allons ajouter zsh. 

L'option permettant d'installer zsh est `programs.zsh.enable` ([doc](https://search.nixos.org/options?channel=24.11&from=0&size=50&sort=relevance&type=packages&query=programs.zsh)).

**Ouvrez** le fichier `/etc/nixos/customConfig/default.nix`

```bash
sudo nano /etc/nixos/customConfig/default.nix
```

```nix
{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  environment.systemPackages = [
  # Add your stable apps here (exemple: pkgs.btop)



  # Add your unstable apps here (exemple: pkgs-unstable.btop)


  ];


  # Add your custom configuration here ↓

}
```

Si nous rajoutons l'option zsh : 


```nix
{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  environment.systemPackages = [
  # Add your stable apps here (exemple: pkgs.btop)



  # Add your unstable apps here (exemple: pkgs-unstable.btop)


  ];


  # Add your custom configuration here ↓
  programs.zsh.enable = true;

}
```

Sauvegardez votre fichier avec `CTRL+O`, `ENTER`, puis quittez avec `CTRL+X`, `ENTER`.

**Exécutez la commande**:

```nix
glf-switch
```

