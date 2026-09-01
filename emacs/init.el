;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; Packages are installed declaratively by Home Manager.  Do not let Emacs
;; modify its package set independently.
(setq package-archives nil)

;; Never turn `keyboard-quit' into an audible terminal BEL.
(setq ring-bell-function #'ignore)

;; The theme mirrors the semantic color choices in helix/selenized.nix.
;; Its companion theme supplies palette-indexed faces to terminal frames.
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
(load-theme 'selenized-dark t)
(enable-theme 'selenized-terminal)

(defconst my/terminal-ansi-color-names
  ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"
   "brightblack" "brightred" "brightgreen" "brightyellow"
   "brightblue" "brightmagenta" "brightcyan" "brightwhite"])

(defun my/setup-terminal-palette (frame)
  "Make FRAME use the terminal's default and sixteen ANSI colors."
  (unless (display-graphic-p frame)
    (with-selected-frame frame
      ;; Register these after terminal initialization, which replaces the
      ;; daemon's initial `dumb' terminal color table.  Unlike Emacs' named
      ;; aliases, each name below always denotes the corresponding ANSI slot.
      (dotimes (index 16)
        (let* ((standard-name
                (aref my/terminal-ansi-color-names index))
               (description (tty-color-desc standard-name))
               (rgb (nthcdr 2 description)))
          ;; Keep canonical RGB metadata so packages such as Ghostel can
          ;; construct a palette.  The explicit INDEX still makes terminal
          ;; redisplay emit ANSI colors rather than these RGB values.
          (tty-color-define (format "color-%d" index) index rgb frame)))

      ;; Re-resolve theme faces now that the indexed names exist for this
      ;; terminal, then undo RGB defaults inherited from graphical frames.
      (dolist (setting (get 'selenized-terminal 'theme-settings))
        (when (eq (car setting) 'theme-face)
          (face-spec-recalc (nth 1 setting) frame)))
      (set-face-attribute 'default frame
                          :foreground "unspecified-fg"
                          :background "unspecified-bg"))))

(add-hook 'after-make-frame-functions #'my/setup-terminal-palette)
(unless (daemonp)
  (my/setup-terminal-palette (selected-frame)))

;; Frame appearance.  Keep the complete Fontconfig pattern in
;; `default-frame-alist' because graphical frames may be created later by the
;; Emacs daemon.
(tool-bar-mode -1)
(scroll-bar-mode -1)

(defconst my/default-font
  "Fantasque Sans Mono:pixelsize=15")

(add-to-list 'default-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(horizontal-scroll-bars . nil))
(add-to-list 'default-frame-alist `(font . ,my/default-font))
(set-face-attribute 'default nil :font my/default-font)

;; Insert matching delimiters and quotes while editing.
(electric-pair-mode 1)

;; Show line numbers in programming buffers.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Decode mouse reports in terminal frames.
(xterm-mouse-mode 1)

;; Restore inline images in terminal Emacs.  Foot is detected as a Sixel
;; terminal; `img2sixel' is installed alongside Emacs by Home Manager.
(use-package kitty-graphics
  :config
  (kitty-graphics-setup))

;; Keep auto-saves, backups, and recovery metadata out of project trees.
(defconst my/state-directory
  (expand-file-name "var/" user-emacs-directory))
(defconst my/auto-save-directory
  (expand-file-name "auto-save/" my/state-directory))
(defconst my/backup-directory
  (expand-file-name "backup/" my/state-directory))
(defconst my/lock-directory
  (expand-file-name "lock/" my/state-directory))

(dolist (directory (list my/auto-save-directory
                         my/backup-directory
                         my/lock-directory))
  (make-directory directory t))

(setq auto-save-file-name-transforms
      `((".*" ,my/auto-save-directory t))
      auto-save-list-file-prefix
      (expand-file-name ".saves-" my/auto-save-directory)
      backup-directory-alist
      `(("." . ,my/backup-directory))
      lock-file-name-transforms
      `((".*" ,my/lock-directory t)))

;; Reload clean file buffers when their contents change on disk.  Buffers
;; with unsaved edits are left untouched.
(use-package autorevert
  :config
  (global-auto-revert-mode))

;; Display available key bindings after a prefix key is pressed.
(use-package which-key
  :custom
  ;; A literal zero races TTY mouse escape-sequence decoding: each SGR mouse
  ;; report starts with ESC and briefly looks like an incomplete Meta prefix.
  (which-key-idle-delay 0.01)
  :config
  (which-key-mode))

;; Prefer Tree-sitter major modes when both Emacs and an installed grammar
;; support them.  The grammars themselves are supplied by Home Manager.
(use-package treesit
  :config
  (dolist (mapping '((c-mode c-ts-mode c)
                     (c++-mode c++-ts-mode cpp)
                     (c-or-c++-mode c-or-c++-ts-mode c)
                     (conf-toml-mode toml-ts-mode toml)
                     (css-mode css-ts-mode css)
                     (html-mode html-ts-mode html)
                     (js-mode js-ts-mode javascript)
                     (js-json-mode json-ts-mode json)
                     (markdown-mode markdown-ts-mode (markdown markdown-inline))
                     (python-mode python-ts-mode python)
                     (sh-mode bash-ts-mode bash)
                     (yaml-mode yaml-ts-mode yaml)))
    (pcase-let ((`(,old-mode ,new-mode ,language) mapping))
      (when (treesit-ready-p language t)
        (add-to-list 'major-mode-remap-alist
                     (cons old-mode new-mode)))))

  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode)))

;; Retain rust-mode's Cargo, Clippy, and rustfmt integration while deriving
;; its syntax support from Emacs' native Tree-sitter mode.
(use-package rust-mode
  :init
  (setq rust-mode-treesitter-derive t)
  :custom
  (rust-format-on-save t))

;; Offer Cargo commands dynamically in Rust buffers.
(use-package cargo-mode
  :hook
  (rust-mode . cargo-minor-mode)
  :config
  (keymap-unset cargo-minor-mode-map "C-c a")
  (keymap-set cargo-minor-mode-map "C-c C-a"
              'cargo-mode-command-map))

;; Emacs does not yet include a native `fish-ts-mode'.  Keep fish-mode's
;; editing support while attaching the native Tree-sitter parser.
(defun my/fish-treesit-setup ()
  (when (treesit-ready-p 'fish t)
    (treesit-parser-create 'fish)))

(use-package fish-mode
  :mode "\\.fish\\'"
  :hook
  (fish-mode . my/fish-treesit-setup))

;; While a nix buffer has parse errors, routine in mid-edit, the built-in
;; indent rules anchor lines inside ERROR nodes at column 0.  Prepend a
;; rule that keeps the previous non-blank line's indentation until the
;; tree parses again.
(defun my/nix-ts-tree-has-error-p (&rest _)
  (treesit-node-check (treesit-buffer-root-node) 'has-error))

(defun my/nix-ts-prev-line-indent-anchor (_node _parent bol &rest _)
  (save-excursion
    (goto-char bol)
    (forward-line -1)
    (while (and (not (bobp)) (looking-at-p "[ \t]*$"))
      (forward-line -1))
    (back-to-indentation)
    (point)))

(defun my/nix-ts-indent-error-fallback ()
  (setf (alist-get 'nix treesit-simple-indent-rules)
        (cons '(my/nix-ts-tree-has-error-p my/nix-ts-prev-line-indent-anchor 0)
              (alist-get 'nix treesit-simple-indent-rules))))

(use-package nix-ts-mode
  :mode "\\.nix\\'"
  :hook
  (nix-ts-mode . my/nix-ts-indent-error-fallback))

;; Expand and contract the region along syntax-tree boundaries.
(use-package expreg
  :bind (("C-c r e" . expreg-expand)
         ("C-c r c" . expreg-contract)))

;; Start the installed Nix, Rust, and TOML language servers automatically.
(defun my/eglot-disable-inlay-hints ()
  "Keep Eglot inlay hints opt-in for newly managed buffers."
  (when (eglot-managed-p)
    (eglot-inlay-hints-mode -1)))

(use-package eglot
  :init
  (setq eglot-autoshutdown t)
  (setq-default eglot-workspace-configuration
                '(:rust-analyzer
                  (:cargo (:features "all"
                           :targetDir t))))
  :hook
  ((nix-ts-mode rust-mode toml-ts-mode) . eglot-ensure)
  (eglot-managed-mode . my/eglot-disable-inlay-hints)
  :bind
  (:map eglot-mode-map
        ("C-c e a" . eglot-code-actions)
        ("C-c e r" . eglot-rename)
        ("C-c e f" . eglot-format-buffer)
        ("C-c e o" . eglot-code-action-organize-imports)
        ("C-c e h" . eglot-inlay-hints-mode)
        ("C-c e R" . eglot-reconnect)
        ("C-c e q" . eglot-shutdown))
  :config
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nil")))
  (add-to-list 'eglot-server-programs
               '(toml-ts-mode . ("tombi" "lsp"))))

;; Keep minibuffer history between sessions.
(use-package savehist
  :init
  (savehist-mode))

;; A compact vertical display for minibuffer completion candidates.
(use-package vertico
  :config
  (vertico-mode))

;; Flexible, space-separated filtering.  For files, retain convenient path
;; component completion while also allowing Orderless matching.
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion orderless))))
  (completion-pcm-leading-wildcard t))

;; Add useful annotations to minibuffer candidates.
(use-package marginalia
  :config
  (marginalia-mode))

;; Jump directly to visible characters and words using labeled targets.
(use-package avy
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char-2)
         ("M-g w" . avy-goto-word-1)
         ("M-g e" . avy-goto-word-0)))

;; Enhanced versions of common navigation and search commands.
(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-y" . consult-yank-pop)))

;; Context-sensitive actions for the current completion candidate.
(use-package embark
  :demand t
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)
         ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

;; Show Consult results in Embark collection buffers.
(use-package embark-consult
  :after (embark consult))

;; Completion popup while editing buffers.  M-SPC inserts a separator when
;; using Orderless, and M-g moves to the first candidate.
(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :bind (:map corfu-map
              ("M-SPC" . corfu-insert-separator)
              ("M-g" . corfu-first))
  :config
  (global-corfu-mode))

;; A fast, libghostty-backed project terminal using Fish.  With a prefix
;; argument, `ghostel-project' creates another terminal for the same project.
(use-package ghostel
  :commands (ghostel ghostel-project)
  :bind ("C-c t" . ghostel-project))

;; Load these on first use; agent-shell will prompt for an available agent.
(use-package agent-shell
  :commands agent-shell
  :custom
  ;; kitty-graphics's agent-shell integration only hooks this overlay
  ;; renderer, so terminal frames need it for inline images.
  ;; TODO: drop this once kitty-graphics supports the default in-place
  ;; renderer (`agent-shell-markdown-replace-markup').
  (agent-shell-markdown-render-function #'agent-shell--markdown-overlays-put)
  :bind (("C-c a x" . agent-shell-openai-start-codex)
         ("C-c a q" . agent-shell-prompt-queue)
         :map agent-shell-mode-map
         ("C-c a u" . agent-shell-copy-link-url-at-point)))

;; Open the full repository interfaces under a shared mnemonic prefix.
(use-package magit
  :commands magit-status
  :bind ("C-c m g" . magit-status))

;; Provide a Magit-style interface for Jujutsu repositories.
(use-package majutsu
  :commands (majutsu majutsu-log)
  :bind ("C-c m j" . majutsu))

;; Register Jujutsu support with Emacs' built-in VC interface.
(use-package vc-jj
  :demand t)

;; Apply each project's direnv environment buffer-locally, so Eglot,
;; compilation commands, and other development tools see the project's
;; own environment. Enabling the global mode last makes its hook run before
;; mode hooks that read the environment when they start.
(use-package envrc
  :demand t
  :bind (:map envrc-mode-map
              ("C-c d" . envrc-command-map))
  :config
  (envrc-global-mode))

(provide 'init)
;;; init.el ends here
