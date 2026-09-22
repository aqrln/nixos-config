;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; Packages are installed declaratively by Home Manager.  Do not let Emacs
;; modify its package set independently.
(setq package-archives nil)

;; Never turn `keyboard-quit' into an audible terminal BEL.
(setq ring-bell-function #'ignore)

;; Match single-spaced prose by default when moving and filling sentences.
(setq-default sentence-end-double-space nil)

(defun my/use-double-space-sentences ()
  "Use the two-space sentence convention in the current buffer."
  (setq-local sentence-end-double-space t))

;; Preserve the Emacs Lisp convention, including in *scratch*, and use it
;; for Org notes as well.  Project-local settings can override these hooks.
(dolist (hook '(emacs-lisp-mode-hook lisp-interaction-mode-hook org-mode-hook))
  (add-hook hook #'my/use-double-space-sentences))

;; Use Solarized's Selenized palette and upstream face definitions.
(load-theme 'solarized-selenized-dark t)

(setq solarized-scale-markdown-headlines t)

;; Frame appearance.  Keep the complete Fontconfig pattern in
;; `default-frame-alist' because graphical frames may be created later by the
;; Emacs daemon.
(tool-bar-mode -1)
(scroll-bar-mode -1)

(defconst my/default-font
  "Fantasque Sans Mono:pixelsize=16")

(add-to-list 'default-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(horizontal-scroll-bars . nil))
(add-to-list 'default-frame-alist `(font . ,my/default-font))
(set-face-attribute 'default nil :font my/default-font)

(setq x-underline-at-descent-line t)

;; Insert matching delimiters and quotes while editing.
(electric-pair-mode 1)

;; Show line numbers in programming buffers.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Decode mouse reports in terminal frames.
(xterm-mouse-mode 1)

;; Don't follow symlinks when opening files, treat the symlink as if
;; it's the original file.
(setq find-file-visit-truename nil
      vc-follow-symlinks nil)

;; Settings from the newcomers preset theme that I like.
(setopt delete-selection-mode t)
(setopt save-interprogram-paste-before-kill t)
(setopt imenu-auto-rescan t)
(setopt view-read-only t)
(setopt repeat-mode t)
(setopt column-number-mode t)
(setopt mode-line-compact 'long)
(setopt savehist-mode t)
(setopt save-place-mode t)
(setopt tab-bar-history-mode t)
(setopt dired-auto-revert-buffer t)
(setopt dired-mouse-drag-files t)
(setopt shell-command-prompt-show-cwd t)
(setopt compilation-scroll-output 'first-error)
(setopt indent-tabs-mode nil)
(setopt editorconfig-mode t)
(setopt vc-deduce-backend-nonvc-modes t)

;; Flyspell settings.
(setq ispell-program-name "aspell"
      flyspell-delay-use-timer t)
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)
(with-eval-after-load 'flyspell
  (keymap-unset flyspell-mode-map "C-.")
  (keymap-unset flyspell-mode-map "C-;"))

;; Share the Wayland clipboard with terminal frames via wl-copy/wl-paste.
(use-package xclip
  :config
  (xclip-mode 1))

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
  :bind ("C-=" . treesit-cycle-sexp-thing)
  :preface
  (defun my/treesit-prefer-node-sexps ()
    "Start with node navigation in modes that support cycling sexp things."
    (when (eq forward-sexp-function #'treesit-forward-sexp-list)
      (treesit-cycle-sexp-thing)))
  :hook
  (after-change-major-mode . my/treesit-prefer-node-sexps)
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

  (add-to-list 'auto-mode-alist '("\\.[mc]?ts\\'" . typescript-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.[mc]js\\'" . js-ts-mode)))

;; Emacs ships markdown-ts-mode without an autoload or a file association.
(use-package markdown-ts-mode
  :mode "\\.\\(?:md\\|markdown\\)\\'")

(use-package org
  :custom
  (org-fontify-todo-headline t)
  :custom-face
  (org-headline-todo ((t (:inherit org-todo)))))

;; Retain rust-mode's Cargo, Clippy, and rustfmt integration while deriving
;; its syntax support from Emacs' native Tree-sitter mode.
(use-package rust-mode
  :init
  (setq rust-mode-treesitter-derive t)
  :custom
  (rust-format-on-save nil))

;; Offer Cargo commands dynamically in Rust buffers.
(use-package cargo-mode
  :hook
  (rust-mode . cargo-minor-mode)
  :config
  (keymap-unset cargo-minor-mode-map "C-c a")
  (keymap-set cargo-minor-mode-map "C-c C-a"
              'cargo-mode-command-map))

(defun my/dape-rust-test-artifacts ()
  "Read Cargo test artifacts from JSON lines in the current buffer."
  (save-excursion
    (goto-char (point-min))
    (let (artifacts)
      (while (not (eobp))
        (when (looking-at "{")
          (let ((message
                 (condition-case nil
                     (json-parse-string
                      (buffer-substring-no-properties
                       (line-beginning-position) (line-end-position))
                      :object-type 'alist :null-object nil :false-object nil)
                   (json-parse-error nil))))
            (when (and (equal (alist-get 'reason message) "compiler-artifact")
                       (eq (alist-get 'test (alist-get 'profile message)) t)
                       (stringp (alist-get 'executable message)))
              (push message artifacts))))
        (forward-line 1))
      (seq-uniq (nreverse artifacts)
                (lambda (a b)
                  (equal (alist-get 'executable a)
                         (alist-get 'executable b)))))))

(defun my/dape-rust-test-select (config)
  "Select a built test executable and test for Dape CONFIG."
  (let* ((artifacts (with-current-buffer (compilation-find-buffer)
                      (my/dape-rust-test-artifacts)))
         (choices
          (mapcar (lambda (artifact)
                    (cons (file-relative-name (alist-get 'executable artifact)
                                              (dape-config-get config 'command-cwd))
                          artifact))
                  artifacts)))
    (unless choices
      (user-error "No test executables found; use cargo test --no-run --message-format=json-render-diagnostics"))
    (let* ((artifact
            (if (length= choices 1)
                (cdar choices)
              (cdr (assoc (completing-read "Test executable: " choices nil t)
                          choices))))
           (program (alist-get 'executable artifact))
           ;; Cargo runs each test from its package directory, including
           ;; when the build was started at a workspace root.
           (default-directory
            (or (plist-get config :cwd)
                (file-name-directory (alist-get 'manifest_path artifact))))
           (test-environment process-environment)
           (test-exec-path exec-path)
           (tests
            (with-temp-buffer
              (setq-local process-environment test-environment
                          exec-path test-exec-path)
              (unless (eq 0 (process-file program nil t nil "--list" "--format=terse"))
                (user-error "Cannot list tests in %s: %s" program (buffer-string)))
              (goto-char (point-min))
              (let (names)
                (while (re-search-forward "^\\(.+\\): test\r?$" nil t)
                  (push (match-string-no-properties 1) names))
                (nreverse names)))))
      (unless tests
        (user-error "No standard Rust tests found in %s" program))
      (let ((test (completing-read "Debug test: " (cons "<all tests>" tests) nil t)))
        (setf (plist-get config :program) program
              (plist-get config :cwd) default-directory
              (plist-get config :args)
              (vconcat (plist-get config :args)
                       (unless (equal test "<all tests>")
                         (vector test "--exact" "--include-ignored")))
              ;; Restart reuses this selection; a new M-x dape prompts again.
              (plist-get config 'fn) nil))
      config)))

(defun my/dape-rust-test-prepare (config)
  "Arrange to select tests after Dape compiles CONFIG."
  (unless (plist-get config 'compile)
    (user-error "The Rust test preset requires a Cargo test build command"))
  ;; Dape applies `fn' before compilation, then again after a successful
  ;; build.  Defer selection until Cargo has emitted the executable paths.
  (setf (plist-get config 'fn) #'my/dape-rust-test-select)
  config)

;; Use GDB's built-in DAP server, with the Rust toolchain's pretty-printers.
;; M-x dape: rust-gdb :program "target/debug/<binary>"
;; M-x dape: rust-gdb-test (build, then select an executable and test)
(use-package dape
  :custom
  (dape-buffer-window-arrangement 'gud)
  :config
  (defcustom my/dape-single-thread-stepping t
    "Keep other threads paused during Dape steps when supported.
Continue still resumes all threads.  Disable this if a step needs
another thread to make progress, for example when waiting for a lock."
    :type 'boolean
    :group 'dape)

  (defun my/dape-request-single-thread (original conn command arguments &rest rest)
    "Add single-thread stepping to requests sent by ORIGINAL on CONN.
Preserve COMMAND, ARGUMENTS and REST for all other requests."
    (when (and my/dape-single-thread-stepping
               (memq command '(:next :stepIn :stepOut))
               (dape--capable-p conn :supportsSingleThreadExecutionRequests))
      ;; GDB's DAP adapter resets scheduler-locking for each request;
      ;; setting it once in the REPL does not affect Dape's next step.
      (setq arguments (plist-put (copy-sequence arguments) :singleThread t)))
    (apply original conn command arguments rest))

  (advice-add 'dape-request :around #'my/dape-request-single-thread)

  (let ((config (copy-tree (alist-get 'gdb dape-configs))))
    (setf (plist-get config 'modes) '(rust-mode rust-ts-mode)
          (plist-get config 'command) "rust-gdb"
          ;; Dape installs pending breakpoints before loading the executable.
          ;; Parse their conditions as Rust from the start (not default C).
          (plist-get config 'command-args)
          (append (plist-get config 'command-args) '("-iex" "set language rust"))
          (plist-get config 'compile) "cargo build"
          (plist-get config :program) "target/debug/")
    (setf (alist-get 'rust-gdb dape-configs) config))
  (let ((config (copy-tree (alist-get 'rust-gdb dape-configs))))
    (setf (plist-get config 'compile)
          "cargo test --no-run --message-format=json-render-diagnostics"
          (plist-get config 'fn) #'my/dape-rust-test-prepare
          (plist-get config :program) nil
          (plist-get config :args) ["--nocapture" "--test-threads=1"])
    (setf (alist-get 'rust-gdb-test dape-configs) config)))

;; Emacs does not yet include a native `fish-ts-mode'.  Keep fish-mode's
;; editing support while attaching the native Tree-sitter parser.
(defun my/fish-treesit-setup ()
  (when (treesit-ready-p 'fish t)
    (treesit-parser-create 'fish)))

(use-package fish-mode
  :mode "\\.fish\\'"
  :hook
  (fish-mode . my/fish-treesit-setup))

;; Edit scores and compile them with LilyPond; open PDFs in the desktop viewer.
(use-package lilypond-mode
  :mode ("\\.ly\\'" "\\.ily\\'")
  :custom
  (lilypond-pdf-command "xdg-open"))

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
  :bind (("C->" . expreg-expand)
         ("C-<" . expreg-contract)))

;; Let Eglot advertise and expand server-provided snippets.  Eglot enables
;; yas-minor-mode in a buffer when a snippet needs expansion.
(use-package yasnippet
  :demand t)

;; Start the installed Nix, Rust, and TOML language servers automatically.
(defun my/eglot-disable-inlay-hints ()
  "Keep Eglot inlay hints opt-in for newly managed buffers."
  (when (eglot-managed-p)
    (eglot-inlay-hints-mode -1)))

(defun my/eglot-rust-format-on-save ()
  "Format managed Rust buffers with Eglot before saving."
  (when (derived-mode-p 'rust-mode 'rust-ts-mode)
    (if (eglot-managed-p)
        (add-hook 'before-save-hook #'eglot-format-buffer nil t)
      (remove-hook 'before-save-hook #'eglot-format-buffer t))))

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
  (eglot-managed-mode . my/eglot-rust-format-on-save)
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
  :bind (("C-x b" . consult-buffer)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-g l" . consult-line)
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

;; Completion popup while editing buffers.
(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.3)
  (corfu-auto-prefix 4)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :bind (:map corfu-map
              ([remap previous-line] . nil)
              ([remap next-line] . nil)
              ("M-p" . corfu-previous)
              ("M-n" . corfu-next)
              ("M-SPC" . corfu-insert-separator))
  :config
  (global-corfu-mode)
  (corfu-popupinfo-mode 1))

;; Let commands in Emacs shells open files in this Emacs instance.
(use-package with-editor
  :demand t
  :config
  (defun my/export-emacs-editor (&optional process)
    "Export both editor variables in a supported shell or terminal buffer."
    (with-editor-export-editor "EDITOR" process)
    (with-editor-export-editor "VISUAL" process))

  (dolist (hook '(shell-mode-hook eshell-mode-hook term-exec-hook
                 vterm-mode-hook eat-exec-hook))
    (add-hook hook #'my/export-emacs-editor))

  (defun my/ghostel-set-editor ()
    "Set editor variables in Ghostel's dynamically bound spawn environment."
    ;; With-Editor's terminal export command does not support Ghostel yet.
    ;; Remote Ghostel terminals cannot use the local Emacsclient socket.
    (unless (file-remote-p default-directory)
      (setq process-environment
            (with-editor
              (setenv "VISUAL" (getenv "EDITOR"))
              process-environment)))))

;; A fast, libghostty-backed project terminal using Fish.  With a prefix
;; argument, `ghostel-project' creates another terminal for the same project.
(use-package ghostel
  :commands (ghostel ghostel-project)
  :hook (ghostel-pre-spawn . my/ghostel-set-editor)
  :bind ("C-c t" . ghostel-project))

;; Use the ChatGPT subscription via browser OAuth; gptel manages its token cache.
(use-package gptel
  :commands (gptel gptel-openai-oauth-login)
  :bind (("C-c a g" . gptel)
         ("C-c a RET" . gptel-send)
         ("C-c a m" . gptel-menu))
  :config
  (require 'gptel-openai-oauth)
  ;; Echo-area and kill-ring output request a complete response, but the
  ;; subscription endpoint requires streaming.  Buffer it for those callbacks.
  ;; https://github.com/karthink/gptel/issues/1432
  (defun my/gptel-oauth-buffered-request (request prompt &rest args)
    "Stream OAuth REQUEST with PROMPT and ARGS for buffered callbacks."
    (let ((callback (plist-get args :callback)))
      (if (not (and (gptel-openai-oauth-p gptel-backend)
                    callback (not (plist-get args :stream))))
          (apply request prompt args)
        (let ((gptel-stream t)
              (gptel-use-curl t)
              chunks reasoning)
          (setq args (plist-put args :stream t))
          (setq args
                (plist-put
                 args :callback
                 (lambda (response info)
                   (pcase response
                     ((pred stringp) (push response chunks))
                     (`(reasoning . ,(and text (pred stringp)))
                      (push text reasoning))
                     (`(reasoning . t) nil)
                     ('t
                      (when reasoning
                        (funcall callback
                                 (cons 'reasoning (apply #'concat (nreverse reasoning)))
                                 info)
                        (setq reasoning nil))
                      (when chunks
                        (let ((text (apply #'concat (nreverse chunks))))
                          (setq chunks nil)
                          (funcall callback text info))))
                     (_ (setq chunks nil reasoning nil)
                        (funcall callback response info))))))
          (apply request prompt args)))))
  (advice-add 'gptel-request :around #'my/gptel-oauth-buffered-request)
  (setq gptel-model 'gpt-6-astra
        gptel-backend (gptel-make-openai-oauth "ChatGPT" :stream t)))

;; Register coding tools and agent/planning presets when gptel loads.
(use-package gptel-agent
  :after gptel
  :demand t
  :bind ("C-c a a" . gptel-agent)
  :config
  ;; Tool inspection closes its buffer after accepting a call.  Keep subagent
  ;; requests and their status overlays in the originating conversation.
  (defun my/gptel-agent-task-in-request-buffer (task &rest args)
    "Run TASK with ARGS in the parent request's buffer."
    (let ((buffer (and (bound-and-true-p gptel--fsm-last)
                       (plist-get (gptel-fsm-info gptel--fsm-last) :buffer))))
      (if (buffer-live-p buffer)
          (with-current-buffer buffer
            (apply task args))
        (apply task args))))
  (advice-add 'gptel-agent--task :around #'my/gptel-agent-task-in-request-buffer)
  (gptel-agent-update))

;; Load these on first use; agent-shell will prompt for an available agent.
(use-package agent-shell
  :commands agent-shell
  :bind (("C-c a x" . agent-shell-openai-start-codex)
         ("C-c a q" . agent-shell-prompt-queue)
	 ("C-c a s" . agent-shell-send-dwim)
         :map agent-shell-mode-map
         ("C-c a u" . agent-shell-copy-link-url-at-point)))

;; Keep the native streaming renderer and reuse terminal image placements.
(use-package agent-shell-kitty-graphics
  :after (agent-shell kitty-graphics)
  :config
  (agent-shell-kitty-graphics-mode 1))

;; Open the full repository interfaces under a shared mnemonic prefix.
(use-package magit
  :commands magit-status
  :bind ("C-c m g" . magit-status))

;; Provide a Magit-style interface for Jujutsu repositories.
(use-package majutsu
  :commands (majutsu majutsu-log)
  :bind ("C-c m j" . majutsu))

;; Show only commit summaries in Majutsu buffers; TAB expands a body.
(with-eval-after-load 'magit-section
  (add-to-list 'magit-section-initial-visibility-alist '(jj-commit . hide)))

;; Register Jujutsu support with Emacs' built-in VC interface.
(use-package vc-jj
  :demand t)

;; Fastmail credentials are read by auth-source, outside the Nix store.
;; See ~/lore/fastmail-gnus.org for app-password setup and first-run instructions.
(defconst my/fastmail-user "alex@aqrln.net"
  "Fastmail sign-in address, which may differ from the sender address.")

(setq user-full-name "Oleksii Orlenko"
      user-mail-address "alex@aqrln.net"
      mail-user-agent 'gnus-user-agent
      send-mail-function #'smtpmail-send-it
      message-send-mail-function #'smtpmail-send-it)

(use-package smtpmail
  :commands smtpmail-send-it
  :custom
  (smtpmail-smtp-server "smtp.fastmail.com")
  (smtpmail-smtp-service 465)
  (smtpmail-stream-type 'tls)
  (smtpmail-smtp-user my/fastmail-user))

(use-package gnus
  :commands gnus
  :custom
  (gnus-select-method
   `(nnimap "fastmail"
            (nnimap-address "imap.fastmail.com")
            (nnimap-server-port 993)
            (nnimap-stream tls)
            (nnimap-user ,my/fastmail-user)))
  (gnus-nntp-server nil)
  ;; Store sent mail on Fastmail, including messages composed with C-x m.
  (gnus-message-archive-method '(nnimap "fastmail"))
  (gnus-message-archive-group "Sent")
  (gnus-gcc-mark-as-read t)
  (gnus-permanently-visible-groups "\\`\\(?:nnimap\\+fastmail:\\)?INBOX\\'"))

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
