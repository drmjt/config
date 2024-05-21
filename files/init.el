
;; Install plugins from Ubuntu repos:
;; sudo apt install --no-install-recommends emacs elpa-lsp-ui elpa-lsp-treemacs elpa-lsp-mode elpa-treemacs elpa-which-key elpa-company

;; Disable auto-indent mode. There might be a way to make indents
;; match clang-format instead?
(electric-indent-mode 0)
;; Similar formatting options to my clang-format
(c-add-style "microsoft"
          '("stroustrup"
            (c-offsets-alist
             (innamespace . -)
             (inline-open . 0)
             (inher-cont . c-lineup-multi-inher)
             (arglist-cont-nonempty . +)
             (template-args-cont . +))))
(setq c-default-style "microsoft")

;; Configure backups
;; Alternatively, can be disabled with:
;; (setq make-backup-files nil)
(setq backup-directory-alist `(("." . "~/.emacs_backups")))
(setq backup-by-copying t)
(setq delete-old-versions t
  kept-new-versions 9
  kept-old-versions 5
  version-control t)

(use-package company-mode
  ;;:ensure t
  )

(use-package treemacs
  ;;:ensure t
  :init
  :config
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package lsp-mode
  ;;:ensure t
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "<f4>")
  :hook (
         (c-mode . lsp)
         (c++-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)
(use-package lsp-ui
  ;;:ensure t
  :commands lsp-ui-mode)
(use-package lsp-treemacs
  ;;:ensure t
  :commands lsp-treemacs-errors-list)
;; For completion. Ubuntu has elpa-ivy, but not elpa-lsp-ivy?
;; (use-package lsp-ivy :ensure t :commands lsp-ivy-workspace-symbol)
;; optionally if you want to use debugger
;; (use-package dap-mode :ensure t)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(use-package which-key
    ;;:ensure t
    :config
    (which-key-mode))

;; Start emacs with only one window
(add-hook 'emacs-startup-hook
          (lambda () (delete-other-windows)) t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes nil)
 '(inhibit-startup-screen t)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Hack Nerd Font" :foundry "SRC" :slant normal :weight regular :height 110 :width normal))))))
