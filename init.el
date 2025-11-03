;;------------------------DEFAULT CONFIGS------------------------------------------
(defconst c/red "#E63953")
(defconst c/lred "#E67585")
(defconst c/dred "#BE132D")
(defconst c/green "#9EC48D")
(defconst c/lgreen "#A9F494")
(defconst c/dgreen "#2C950F")
(defconst c/blue "#5471AB")
(defconst c/dblue "#182030")
(defconst c/lblue "#92A4C9")
(defconst c/orange "#E0AA69")
(defconst c/yellow "#DAE069")
(defconst c/pink "#ED4EC0")
(defconst c/purple "#7B4EED")

(set-frame-parameter (selected-frame) 'alpha-background 90) ;; For Emacs 29+
(add-to-list 'default-frame-alist '(alpha-background . 90))
(set-face-attribute 'default nil :font "JetBrains Mono Nerd Font" :height 110)
(electric-pair-mode 1)
(delete-selection-mode 1)
(pixel-scroll-precision-mode 1)
(global-display-line-numbers-mode 1)
(tab-bar-mode 1)
(setq scroll-conservatively 9999)
(menu-bar-mode 0)
(tool-bar-mode 0)
(column-number-mode 1)
(scroll-bar-mode 0)
(setq inhibit-startup-message t)
(fset 'yes-or-no-p 'y-or-n-p)
;; ──────────────────────────────────────────────────────────────
;;  Prettify Symbols Mode – Beautiful Unicode Ligatures (fixed)
;; ──────────────────────────────────────────────────────────────
(setq prettify-symbols-unprettify-at-point 'right-edge)				      

(defun my/ps (char strings)
  "Return an alist of (STRING . CHAR) for each string in STRINGS."
  (mapcar (lambda (s) (cons s char)) strings))

(defun my/setup-prettify-symbols ()
  "Set up pretty symbols for the current buffer."
  (setq-local prettify-symbols-alist nil)

  (dolist (pair
           (append
            (my/ps ?λ '("lambda"))
            (my/ps ?ƒ '("defun" "fn" "function" "def"))
            (my/ps ?≝ '("define"))
            (my/ps ?→ '("->"))
            (my/ps ?↠ '("->>"))
            (my/ps ?⇒ '("=>"))
            (my/ps ?← '("<-"))
            (my/ps ?↔ '("<->"))
            (my/ps ?⇔ '("<==>"))
            (my/ps ?▷ '("|>"))
            (my/ps ?◁ '("<|"))
            (my/ps ?≡ '("=="))
            (my/ps ?≠ '("!=" "/="))
            (my/ps ?≤ '("<="))
            (my/ps ?≥ '(">="))
            (my/ps ?≈ '("=~"))
            (my/ps ?… '("..."))
            (my/ps ?∅ '("null" "None" "nil"))
            (my/ps ?✓ '("true" "yes" "True"))
            (my/ps ?✗ '("false" "no" "False"))))
    (push pair prettify-symbols-alist))
  (when (derived-mode-p 'org-mode)
    (dolist (pair (append
                   (my/ps ?☐ '("[ ]"))
                   (my/ps ?☑ '("[X]"))
                   (my/ps ?⛝ '("[-]"))))
      (push pair prettify-symbols-alist)))
  (prettify-symbols-mode 1))
(dolist (hook '(prog-mode-hook
                org-mode-hook
                latex-mode-hook
                markdown-mode-hook
                conf-mode-hook
                emacs-lisp-mode-hook
                python-mode-hook))
  (add-hook hook #'my/setup-prettify-symbols))
;; ... add more hooks here as needed ...
;;----------------------------------------
(defun electric-pair ()
  "If at end of line, insert character pair without surrounding spaces.
Otherwise, just insert the typed character."
  (interactive)
  (if (eolp) (let (parens-require-spaces) (insert-pair)) (self-insert-command 1)))
;;------------------------PACKAGES--------------------------------------------------
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-after-load 'package
  '(require 'use-package))
(use-package doom-themes
  :ensure t
  :init
  :config
  (load-theme 'doom-dracula t))
(use-package which-key
  :ensure t
  :config
  (which-key-mode))
;-----------------------------------------EVIL--------------------------------------------|
(use-package evil
  :ensure t
  :init
  ;; These MUST be set before evil loads for evil-collection to work
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (defvar my-leader-keymap (make-sparse-keymap)
    "My custom leader keymap.")
  ;; --- ALL LEADER KEYS ARE NOW IN ONE PLACE ---
  (define-key my-leader-keymap (kbd "d") 'dired) ; "d" for directory
  (define-key my-leader-keymap (kbd "f") 'find-file)
  (define-key my-leader-keymap (kbd "s") 'save-buffer)
  (define-key my-leader-keymap (kbd "b") 'switch-to-buffer)
  (define-key my-leader-keymap (kbd "p") 'popup-kill-ring)
  (define-key my-leader-keymap (kbd "u") 'undo-tree-visualize)
  (define-key my-leader-keymap (kbd "g") 'magit-status)
  (define-key my-leader-keymap (kbd "j") 'avy-goto-char-timer)
  (define-key my-leader-keymap (kbd "t n") 'tab-new)       ; "Tab New"
  (define-key my-leader-keymap (kbd "t k") 'tab-close)    ; "Tab Kill"
  (define-key my-leader-keymap (kbd "t l") 'tab-next)      ; "Tab Next" (l)
  (define-key my-leader-keymap (kbd "t h") 'tab-previous)  ; "Tab Previous" (h)
  :config
  (evil-mode 1)
  (define-key evil-normal-state-map (kbd "SPC") my-leader-keymap)
  (define-key evil-visual-state-map (kbd "SPC") my-leader-keymap))
;----------------------------------------------------------------------------------------|
;; ──────────────────────────────────────────────────────────────
;;  Org Mode Beautification
;; ──────────────────────────────────────────────────────────────
(use-package org
  :ensure nil ; This is built-in
  :hook ((org-mode . org-indent-mode)     ; 1. Turn on clean indentation
         (org-mode . variable-pitch-mode)) ; 2. Use variable-pitch fonts
  :config
  ;; 3. Set the fonts for variable-pitch and code blocks
  (set-face-attribute 'variable-pitch nil :font "JetBrains Mono Nerd Font" :height 1.0)
  (set-face-attribute 'fixed-pitch nil :font "JetBrains Mono Nerd Font" :height 1.0)

  ;; 4. Set the Org headline sizes
  (custom-set-faces
   '(org-level-1 ((t (:inherit bold :height 1.4))))
   '(org-level-2 ((t (:inherit bold :height 1.3))))
   '(org-level-3 ((t (:inherit bold :height 1.2))))
   '(org-level-4 ((t (:inherit bold :height 1.1))))))

(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))


(use-package recentf
  :ensure nil
  :init
  (setq recentf-max-saved-items 200
        recentf-auto-cleanup 'never)
  (recentf-mode 1))

;; --- Dashboard banner picker (no 'random) ---
(defvar my/dashboard-banner-dir (expand-file-name "~/.config/emacs/banners/")
  "Directory containing dashboard banner images.")

(defun my/dashboard-pick-banner ()
  "Return a random image path from `my/dashboard-banner-dir`, or nil."
  (when (file-directory-p my/dashboard-banner-dir)
    (let ((files (directory-files my/dashboard-banner-dir t "\\.\\(png\\|jpe?g\\|svg\\|gif\\)\\'" t)))
      (when files
        (nth (random (length files)) files)))))

;; recentf stays as-is above
(use-package dashboard
  :ensure t
  :after projectile
  :init
  (let ((banner-file (my/dashboard-pick-banner)))
    (setq dashboard-startup-banner (or banner-file 'logo)
          ;; If banner-file is non-nil, Emacs will use that image; otherwise use ASCII 'logo
          dashboard-banner-logo-title "Remember: cos(a)cos(b) = 1/2[cos(a - b) + cos(a + b)],
sin(a)sin(b) = 1/2[cos(a - b) - cos(a + b)], sin(a)cos(b)=1/2[sin(a - b) + sin(a + b)]"
          dashboard-image-banner-max-height 400
          dashboard-center-content t
          dashboard-show-shortcuts t
          dashboard-items '((recents  . 8)
                            (projects . 5)
                            (bookmarks . 5)
                            (agenda   . 5))
          ;; Projects via Projectile
          dashboard-projects-backend 'projectile
          dashboard-projects-switch-function #'projectile-switch-project
          ;; Plain text (no icon lookups)
          dashboard-set-heading-icons nil
          dashboard-set-file-icons nil
          ;; Footer
          dashboard-footer-messages
          '("SPC f: find file" "P p: switch project" "Welcome back!")))
  :config
  (setq dashboard-navigator-buttons
        '(((nil "GitHub" "Open GitHub"
            (lambda () (browse-url "https://github.com")))
           (nil "Init" "Open init.el"
            (lambda () (find-file user-init-file)))
           (nil "Update" "Refresh package list"
            (lambda () (package-refresh-contents))))))
  (dashboard-setup-startup-hook))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package nerd-icons
  :ensure t)

(use-package colorful-mode
  :ensure t
  :custom
  (colorful-use-prefix t) 
  (global-colorful-modes '(prog-mode help-mode html-mode css-mode latex-mode))
  :config
  (add-to-list 'colorful-extra-color-keyword-functions '(prog-mode . colorful-add-hex-colors))
  (add-to-list 'colorful-extra-color-keyword-functions '(prog-mode . colorful-add-rgb-colors))
  (global-colorful-mode t)
  (add-to-list 'global-colorful-modes 'helpful-mode))

(use-package highlight-indent-guides
  :ensure t
  :hook ((prog-mode . highlight-indent-guides-mode))
  :custom
  (highlight-indent-guides-auto-enabled nil)
  ;(highlight-indent-guides-method 'character) 
  ;(highlight-indent-guides-character ?\|) ; The '|' character
  :config
  (set-face-foreground 'highlight-indent-guides-character-face "gray40")
  (set-face-background 'highlight-indent-guides-odd-face "#2F3B54")
  (set-face-background 'highlight-indent-guides-even-face "#3B4B69"))

(use-package prism
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'prism-mode)
  (add-hook 'python-mode-hook 'prism-whitespace-mode)
  (add-hook 'shell-mode-hook 'prism-whitespace-mode)
  (add-hook 'yaml-mode-hook 'prism-whitespace-mode))

(use-package popup-kill-ring
  :ensure t
  :bind ("M-y" . popup-kill-ring)
  :config
  ;; Keybinding was moved to the evil block
)

(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1) )
(use-package markdown-mode
  :ensure t
  :config
  ;; --- Make Copilot Chat use Markdown HIGHLIGHTING ---
  ;;
  ;; This is the fix: We use the *minor* mode `markdown-fontify-mode`
  ;; (for highlighting) instead of the *major* mode `markdown-mode`.
  (add-hook 'copilot-chat-mode-hook #'markdown-fontify-mode))				 ;(use-package treesit-auto
 ; :ensure t
  ;:config
  ;(setq treesit-auto-major-mode-remap-alist
   ;     '((java-mode . java-ts-mode)
    ;      (javascript-mode . js-ts-mode)
     ;     (json-mode . json-ts-mode)
      ;    (python-mode . python-ts-mode)
       ;   (css-mode . css-ts-mode)
        ;  (c-mode . c-ts-mode)
         ; (c++-mode . c++-ts-mode)
 ;         (typescript-mode . typescript-ts-mode)
  ;        (yaml-mode . yaml-ts-mode)
   ;       (rust-mode . rust-ts-mode)
    ;      (go-mode . go-ts-mode)))
  ;(global-treesit-auto-mode 1))
(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp-deferred)))
  :config
  ;; You can also use python-ts-mode-hook if you re-enable treesitter
  (add-hook 'python-mode-hook #'lsp-pyright-enable))

(use-package company
  :ensure t
  :config
  (global-company-mode 1)
  (setq company-minimum-prefix-length 2)
  (setq company-show-numbers t)
  (define-key company-active-map (kbd "TAB") #'company-select-next)
  (define-key company-active-map (kbd "<tab>") #'company-select-next)
  (define-key company-active-map (kbd "S-TAB") #'company-select-previous)
  (define-key company-active-map (kbd "<backtab>") #'company-select-previous))

(use-package flycheck
  :ensure t
  :init
  ;; This turns on flycheck *everywhere*
  (global-flycheck-mode 1))

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  ;; This hook stops lsp-mode from trying to run on your init.el
  :hook ((prog-mode . (lambda ()
                       (unless (or (eq major-mode 'emacs-lisp-mode)
                                   (eq major-mode 'lisp-interaction-mode))
                         (lsp-deferred))))))

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t)

(use-package magit
  :ensure t
  :config
  ;; Keybinding was moved to the evil block
)

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/proj" "/home/thinh/proj" "~/.config" "~/work"))
  (setq projectile-completion-system 'auto)
  :config
  (projectile-mode 1)
  ;; Optional leader bindings under "P" to avoid your existing "p"
  (with-eval-after-load 'evil
    (when (boundp 'my-leader-keymap)
      (define-key my-leader-keymap (kbd "P p") #'projectile-switch-project)
      (define-key my-leader-keymap (kbd "P f") #'projectile-find-file)
      (define-key my-leader-keymap (kbd "P s") #'projectile-grep))))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
