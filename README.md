# WinPE Ghost FR

Version : 1.0
Date : 16/08/2026

Fonctionnalités
---------------
- Détection automatique de l'ADK
- Détection automatique du WinPE Add-on
- Configuration fr-FR
- Suppression du pack en-US
- Intégration de Ghost
- Création automatique du winpeshl.ini
- Compression du boot.wim
- Génération automatique de l'ISO
- Compatible BIOS/MBR et UEFI

Arborescence
------------
```
GhostADK
│
├─ Build-WinPE-Ghost.bat
├─ WinPE_Ghost_FR.iso
└─ Ghost
    ├─ Ghost64.exe
    ├─ *.dll
    └─ fichiers Ghost
```
Prérequis
----------
- Exécuter le script en Administrateur
- Windows ADK installé
- WinPE Add-on installé

Versions utilisées
------------------
- Windows ADK : 10.1.26100.2454
- Windows PE  : 10.0.26100.1
- Ghost       : 12.0.0.11761

Personnalisation
----------------
Le dossier Ghost doit être placé dans le même répertoire que le script.

Le fichier lancé au démarrage du WinPE est : %SYSTEMDRIVE%\Windows\Ghost\Ghost64.exe

Validation
----------
Version testée sous VMware.

Résultats :
- Boot BIOS (MBR) : OK
- Boot UEFI : OK
- Clavier Français : OK
- Démarrage automatique Ghost : OK

Historique
----------
16/08/2026
- Création du script automatisé de génération WinPE Ghost.
