# WinPE-Ghost-FR

Description
-----------
Script de génération automatique d'un WinPE x64
avec Ghost intégré et clavier français.

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
GhostADK
│
├─ Build-WinPE-Ghost.bat
├─ WinPE_Ghost_FR.iso
└─ Ghost
    ├─ Ghost64.exe
    ├─ *.dll
    └─ fichiers Ghost

Prérequis
----------
- Exécuter le script en Administrateur
- Windows ADK installé
- WinPE Add-on installé

Personnalisation
----------------
Le dossier Ghost doit être placé dans le même
répertoire que le script.

Le fichier lancé au démarrage du WinPE est :

%SYSTEMDRIVE%\Windows\Ghost\Ghost64.exe


Résultats :
- Boot BIOS (MBR) : OK
- Boot UEFI : OK
- Clavier Français : OK
- Démarrage automatique Ghost : OK

- Création du script automatisé de génération WinPE Ghost.
