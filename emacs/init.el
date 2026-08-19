(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(agent-shell claude-code-ide consult corfu eat
		 gruber-darker-theme marginalia orderless vertico
		 vterm)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;;; init.el --- Configuracion personal -*- lexical-binding: t; -*-

;; Repositorios de paquetes. Vterm se distribuye desde MELPA.
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; Recargar buffers sin cambios locales cuando el archivo cambie en disco
(setq auto-revert-verbose nil)
(global-auto-revert-mode 1)

;; Apariencia
(menu-bar-mode -1)
(tool-bar-mode -1)
(set-face-attribute 'default nil
                    :family "DejaVu Sans Mono"
                    :height 140)

;; Numeros de linea relativos, como en Vim/Neovim
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Tema utilizado por Tsoding
(use-package gruber-darker-theme
  :ensure t
  :config
  (load-theme 'gruber-darker t))

;; Mostrar las opciones del minibuffer verticalmente
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

;; Buscar candidatos usando fragmentos en cualquier orden
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  ;; Preserve convenient path completion for files.
  (completion-category-overrides
	'((file (styles partial-completion)))))


;; Mostrar informacion adicional junto a los candidatos
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

;; Busqueda y navegacion mejoradas
(use-package consult
  :ensure t
  :bind
  (("C-s" . consult-line)
   ("M-g i" . consult-imenu)
   ([remap switch-to-buffer] . consult-buffer)
   ([remap goto-line] . consult-goto-line)
   ([remap yank-pop] . consult-yank-pop)))

;; Autocompletado emergente dentro del buffer
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  :init
  (global-corfu-mode 1))

;; LSP para C++ mediante clangd
(use-package eglot
  :ensure nil
  :hook
  ((c++-mode c++-ts-mode) . eglot-ensure)
  :custom
  (eglot-autoshutdown t))

;; Terminal nativa para aplicaciones interactivas como Codex
(use-package vterm
  :ensure t
  :commands vterm
  :custom
  (vterm-max-scrollback 10000))

;; Interfaz nativa para Codex mediante el protocolo ACP
(use-package agent-shell
  :ensure t
  :bind ("C-c a" . agent-shell-openai-start-codex))
