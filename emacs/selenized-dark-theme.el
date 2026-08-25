;;; selenized-dark-theme.el --- Selenized theme matching Helix -*- lexical-binding: t; -*-

(deftheme selenized-dark
  "Selenized Dark colors for graphical frames.")

(deftheme selenized-terminal
  "Selenized semantic colors using the terminal's ANSI palette.")

(let ((class '((type graphic)))
      (bg0 "#103c48")
      (bg1 "#174956")
      (bg2 "#325b66")
      (dim "#72898f")
      (fg0 "#adbcbc")
      (fg1 "#cad8d9")
      (mode-line-bg "#234c57")
      (completion-bg "#365b65")
      (completion-annotation "#919e9e")
      (selection "#184956")
      (selection-primary "#2d5b69")
      (red "#fa5750")
      (green "#75b938")
      (yellow "#dbb32d")
      (blue "#4695f7")
      (magenta "#f275be")
      (cyan "#41c7b9")
      (orange "#ed8649")
      (violet "#af88eb")
      (light-red "#ff665c")
      (light-green "#84c747")
      (light-yellow "#ebc13d")
      (light-blue "#58a3ff")
      (light-magenta "#ff84cd")
      (light-cyan "#53d6c7")
      (light-orange "#fd9456")
      (light-violet "#bd96fa"))
  (custom-theme-set-faces
   'selenized-dark

   ;; Core UI.
   `(default ((,class (:foreground ,fg0 :background ,bg0))))
   `(cursor ((,class (:background ,fg1))))
   `(fringe ((,class (:foreground ,dim :background ,bg0))))
   `(vertical-border ((,class (:foreground ,bg2))))
   `(window-divider ((,class (:foreground ,bg2))))
   `(minibuffer-prompt ((,class (:foreground ,blue :weight bold))))
   `(region ((,class (:background ,selection-primary :extend t))))
   `(secondary-selection ((,class (:background ,selection :extend t))))
   `(highlight ((,class (:background ,selection))))
   `(hl-line ((,class (:background ,bg1 :extend t))))
   `(shadow ((,class (:foreground ,dim))))
   `(success ((,class (:foreground ,light-green :weight bold))))
   `(warning ((,class (:foreground ,yellow :weight bold))))
   `(error ((,class (:foreground ,light-red :weight bold))))
   `(link ((,class (:foreground ,light-blue :underline t))))
   `(link-visited ((,class (:foreground ,violet :underline t))))
   `(trailing-whitespace ((,class (:background ,red))))
   `(line-number ((,class (:foreground ,dim :background ,bg0))))
   `(line-number-current-line
     ((,class (:foreground ,light-blue :background ,bg0 :weight bold))))

   ;; Keep the subdued mode line from the original Selenized Emacs theme.
   `(mode-line ((,class (:foreground ,fg0 :background ,mode-line-bg :weight bold :box nil))))
   `(mode-line-active ((,class (:inherit mode-line))))
   `(mode-line-inactive ((,class (:foreground ,dim :background ,bg0 :box nil))))
   `(mode-line-buffer-id ((,class (:weight bold))))
   `(header-line ((,class (:foreground ,fg0 :background ,bg1 :box nil))))

   ;; Syntax: direct counterparts of the Helix scopes.
   `(font-lock-comment-face ((,class (:foreground ,dim :slant italic))))
   `(font-lock-comment-delimiter-face ((,class (:foreground ,dim :slant italic))))
   `(font-lock-doc-face ((,class (:foreground ,dim :slant italic))))
   `(font-lock-string-face ((,class (:foreground ,cyan))))
   `(font-lock-constant-face ((,class (:foreground ,cyan))))
   `(font-lock-number-face ((,class (:foreground ,cyan))))
   `(font-lock-builtin-face ((,class (:foreground ,cyan :weight bold))))
   `(font-lock-function-name-face ((,class (:foreground ,blue))))
   `(font-lock-function-call-face ((,class (:foreground ,blue))))
   `(font-lock-keyword-face ((,class (:foreground ,green))))
   `(font-lock-preprocessor-face ((,class (:foreground ,orange))))
   `(font-lock-type-face ((,class (:foreground ,violet))))
   `(font-lock-variable-name-face ((,class (:foreground ,fg0))))
   `(font-lock-variable-use-face ((,class (:foreground ,fg0))))
   `(font-lock-property-name-face ((,class (:foreground ,violet))))
   `(font-lock-property-use-face ((,class (:foreground ,violet))))
   `(font-lock-operator-face ((,class (:foreground ,yellow))))
   `(font-lock-punctuation-face ((,class (:foreground ,dim))))
   `(font-lock-bracket-face ((,class (:foreground ,dim))))
   `(font-lock-delimiter-face ((,class (:foreground ,dim))))
   `(font-lock-escape-face ((,class (:foreground ,light-red :weight bold))))
   `(font-lock-misc-punctuation-face ((,class (:foreground ,magenta :weight bold))))
   `(font-lock-warning-face ((,class (:foreground ,light-red :weight bold))))

   ;; Eglot semantic tokens: mirror the corresponding Helix scopes instead
   ;; of relying on Eglot's generic defaults, which can override Tree-sitter.
   `(eglot-semantic-namespace ((,class (:foreground ,violet))))
   `(eglot-semantic-type ((,class (:foreground ,violet))))
   `(eglot-semantic-class ((,class (:foreground ,violet))))
   `(eglot-semantic-enum ((,class (:foreground ,violet))))
   `(eglot-semantic-interface ((,class (:foreground ,violet))))
   `(eglot-semantic-struct ((,class (:foreground ,violet))))
   `(eglot-semantic-typeParameter ((,class (:foreground ,violet))))
   `(eglot-semantic-parameter ((,class (:foreground ,fg0))))
   `(eglot-semantic-variable ((,class (:foreground ,fg0))))
   `(eglot-semantic-property ((,class (:foreground ,violet))))
   `(eglot-semantic-enumMember ((,class (:foreground ,cyan))))
   `(eglot-semantic-event ((,class (:foreground ,fg0))))
   `(eglot-semantic-function ((,class (:foreground ,blue))))
   `(eglot-semantic-method ((,class (:foreground ,blue))))
   `(eglot-semantic-macro ((,class (:foreground ,orange))))
   `(eglot-semantic-keyword ((,class (:foreground ,green))))
   `(eglot-semantic-modifier ((,class (:foreground ,yellow))))
   `(eglot-semantic-comment ((,class (:foreground ,dim :slant italic))))
   `(eglot-semantic-string ((,class (:foreground ,cyan))))
   `(eglot-semantic-number ((,class (:foreground ,cyan))))
   `(eglot-semantic-regexp ((,class (:foreground ,cyan))))
   `(eglot-semantic-operator ((,class (:foreground ,yellow))))
   `(eglot-semantic-decorator ((,class (:foreground ,violet))))
   `(eglot-semantic-declaration ((,class (:foreground unspecified))))
   `(eglot-semantic-definition ((,class (:foreground unspecified))))
   `(eglot-semantic-modification ((,class (:foreground unspecified))))
   `(eglot-semantic-defaultLibrary
     ((,class (:foreground unspecified :weight bold))))

   ;; Search and delimiter matching.
   `(isearch ((,class (:foreground ,bg0 :background ,light-yellow :weight bold))))
   `(lazy-highlight ((,class (:foreground ,fg1 :background ,bg2))))
   `(match ((,class (:foreground ,light-yellow :weight bold :underline t))))
   `(show-paren-match ((,class (:foreground ,light-yellow :weight bold :underline t))))
   `(show-paren-mismatch ((,class (:foreground ,bg0 :background ,light-red :weight bold))))

   ;; Completion and transient menus.
   `(completions-common-part ((,class (:foreground ,light-blue :weight bold))))
   `(completions-first-difference ((,class (:foreground ,light-magenta))))
   `(vertico-current
     ((,class (:foreground ,fg1 :background ,completion-bg :weight bold :extend t))))
   `(corfu-default ((,class (:foreground ,fg0 :background ,bg0))))
   `(corfu-current
     ((,class (:foreground ,fg1 :background ,completion-bg :weight bold))))
   `(corfu-border ((,class (:background ,bg2))))
   `(corfu-annotations ((,class (:foreground ,completion-annotation :slant italic))))
   `(marginalia-documentation
     ((,class (:foreground ,completion-annotation :slant italic))))
   `(marginalia-file-priv-dir ((,class (:foreground ,blue :weight bold))))
   `(which-key-key-face ((,class (:foreground ,light-blue :weight bold))))
   `(which-key-command-description-face ((,class (:foreground ,fg0))))
   `(which-key-group-description-face ((,class (:foreground ,violet))))
   `(which-key-local-map-description-face ((,class (:foreground ,cyan))))

   ;; Diagnostics and diffs.
   `(flymake-note ((,class (:underline (:style wave :color ,dim)))))
   `(flymake-warning ((,class (:underline (:style wave :color ,yellow)))))
   `(flymake-error ((,class (:underline (:style wave :color ,light-red)))))
   `(diff-added ((,class (:foreground ,light-green :background ,bg0))))
   `(diff-removed ((,class (:foreground ,light-red :background ,bg0))))
   `(diff-changed ((,class (:foreground ,yellow :background ,bg0))))
   `(diff-header ((,class (:foreground ,dim :background ,bg1))))
   `(diff-file-header ((,class (:foreground ,blue :background ,bg1 :weight bold))))
   `(diff-refine-added ((,class (:foreground ,bg0 :background ,light-green))))
   `(diff-refine-removed ((,class (:foreground ,bg0 :background ,light-red))))

   ;; Magit and Majutsu.  Override Magit's literal grey/red/green backgrounds
   ;; so section and diff buffers stay within the Selenized palette.
   `(magit-section-highlight ((,class (:background ,bg1 :extend t))))
   `(magit-section-heading
     ((,class (:foreground ,light-yellow :weight bold :extend t))))
   `(magit-section-secondary-heading
     ((,class (:foreground ,light-blue :weight bold :extend t))))
   `(magit-section-heading-selection
     ((,class (:foreground ,light-orange :weight bold :extend t))))
   `(magit-dimmed ((,class (:foreground ,dim))))
   `(magit-hash ((,class (:foreground ,dim))))
   `(magit-tag ((,class (:foreground ,light-yellow))))
   `(magit-branch-local ((,class (:foreground ,light-blue))))
   `(magit-branch-current
     ((,class (:inherit magit-branch-local :weight bold :underline t :box nil))))
   `(magit-branch-remote ((,class (:foreground ,light-green))))
   `(magit-branch-remote-head
     ((,class (:inherit magit-branch-remote :weight bold :underline t :box nil))))
   `(magit-head ((,class (:inherit magit-branch-current))))
   `(magit-refname ((,class (:foreground ,fg0))))
   `(magit-filename ((,class (:foreground ,fg0 :weight normal))))
   `(magit-signature-good ((,class (:foreground ,light-green))))
   `(magit-signature-bad ((,class (:foreground ,light-red :weight bold))))
   `(magit-signature-untrusted ((,class (:foreground ,light-cyan))))
   `(magit-signature-expired ((,class (:foreground ,orange))))
   `(magit-signature-revoked ((,class (:foreground ,light-magenta))))
   `(magit-signature-error ((,class (:foreground ,light-blue))))
   `(magit-log-graph ((,class (:foreground ,dim))))
   `(magit-log-author ((,class (:foreground ,orange))))
   `(magit-log-date ((,class (:foreground ,dim))))
   `(magit-diff-file-heading
     ((,class (:foreground ,blue :background ,bg0 :weight bold :extend t))))
   `(magit-diff-file-heading-highlight
     ((,class (:foreground ,light-blue :background ,bg1 :weight bold :extend t))))
   `(magit-diff-file-heading-selection
     ((,class (:foreground ,light-orange :background ,bg1 :weight bold :extend t))))
   `(magit-diff-hunk-heading
     ((,class (:foreground ,dim :background ,bg1 :extend t))))
   `(magit-diff-hunk-heading-highlight
     ((,class (:foreground ,fg1 :background ,bg2 :weight bold :extend t))))
   `(magit-diff-hunk-heading-selection
     ((,class (:foreground ,light-orange :background ,bg2 :weight bold :extend t))))
   `(magit-diff-lines-heading
     ((,class (:foreground ,bg0 :background ,light-orange :weight bold :extend t))))
   `(magit-diff-context ((,class (:foreground ,dim :background ,bg0 :extend t))))
   `(magit-diff-context-highlight
     ((,class (:foreground ,fg0 :background ,bg1 :extend t))))
   `(magit-diff-removed
     ((,class (:foreground ,light-red :background ,bg0 :extend t))))
   `(magit-diff-removed-highlight
     ((,class (:foreground ,light-red :background ,bg1 :extend t))))
   `(magit-diff-added
     ((,class (:foreground ,light-green :background ,bg0 :extend t))))
   `(magit-diff-added-highlight
     ((,class (:foreground ,light-green :background ,bg1 :extend t))))
   `(magit-diff-base
     ((,class (:foreground ,light-yellow :background ,bg0 :extend t))))
   `(magit-diff-base-highlight
     ((,class (:foreground ,light-yellow :background ,bg1 :extend t))))
   `(majutsu-diff-color-words-focus ((,class (:background ,bg1 :extend t))))
   `(majutsu-annotate-highlight
     ((,class (:foreground ,fg0 :background ,bg1 :extend t))))
   `(majutsu-interactive-selected-hunk
     ((,class (:foreground ,light-green :background ,bg1 :weight bold :extend t))))
   `(majutsu-interactive-selected-region
     ((,class (:foreground ,light-magenta :background ,bg1 :weight bold :extend t))))
   `(majutsu-interactive-selected-file
     ((,class (:foreground ,light-blue :background ,bg1 :weight bold :extend t))))
   `(majutsu-conflict-marker-face
     ((,class (:foreground ,fg1 :background ,bg2 :weight bold :extend t))))
   `(majutsu-conflict-context-face
     ((,class (:foreground ,dim :background ,bg1 :extend t))))
   `(majutsu-conflict-added-face
     ((,class (:foreground ,light-green :background ,bg0 :extend t))))
   `(majutsu-conflict-removed-face
     ((,class (:foreground ,light-red :background ,bg0 :extend t))))
   `(majutsu-conflict-refined-added
     ((,class (:foreground ,bg0 :background ,light-green))))
   `(majutsu-conflict-refined-removed
     ((,class (:foreground ,bg0 :background ,light-red))))

   ;; Dired and compilation.
   `(dired-directory ((,class (:foreground ,blue :weight bold))))
   `(dired-symlink ((,class (:foreground ,cyan))))
   `(dired-marked ((,class (:foreground ,magenta :weight bold))))
   `(dired-flagged ((,class (:foreground ,light-red :weight bold))))
   `(compilation-info ((,class (:foreground ,light-blue))))
   `(compilation-warning ((,class (:foreground ,yellow))))
   `(compilation-error ((,class (:foreground ,light-red))))

   ;; Markup.
   `(org-level-1 ((,class (:foreground ,fg1 :weight bold :height 1.15))))
   `(org-level-2 ((,class (:foreground ,light-blue :weight bold))))
   `(org-level-3 ((,class (:foreground ,violet :weight bold))))
   `(org-level-4 ((,class (:foreground ,cyan :weight bold))))
   `(org-code ((,class (:foreground ,cyan))))
   `(org-verbatim ((,class (:foreground ,light-cyan))))
   `(org-block ((,class (:foreground ,fg0 :background ,bg1))))
   `(org-block-begin-line ((,class (:foreground ,dim :background ,bg1))))
   `(org-block-end-line ((,class (:inherit org-block-begin-line))))
   `(org-link ((,class (:foreground ,light-blue :underline t))))
   `(org-special-keyword ((,class (:foreground ,orange))))
   `(org-meta-line ((,class (:foreground ,dim :slant italic))))
   `(org-todo ((,class (:foreground ,light-red :weight bold))))
   `(org-done ((,class (:foreground ,light-green :weight bold))))

   ;; Terminal ANSI faces.
   `(term-color-black ((,class (:foreground ,bg1 :background ,bg1))))
   `(term-color-red ((,class (:foreground ,red :background ,red))))
   `(term-color-green ((,class (:foreground ,green :background ,green))))
   `(term-color-yellow ((,class (:foreground ,yellow :background ,yellow))))
   `(term-color-blue ((,class (:foreground ,blue :background ,blue))))
   `(term-color-magenta ((,class (:foreground ,magenta :background ,magenta))))
   `(term-color-cyan ((,class (:foreground ,cyan :background ,cyan))))
   `(term-color-white ((,class (:foreground ,fg0 :background ,fg0)))))

  (custom-theme-set-variables
   'selenized-dark
   `(ansi-color-names-vector [,bg1 ,red ,green ,yellow ,blue ,magenta ,cyan ,fg0])))

;; Use ANSI indices in terminal frames so changing the terminal palette also
;; changes Emacs.  Foot's Selenized light and dark variants keep these slots
;; semantically compatible; the exact RGB colors above remain in GUI frames.
(let ((tty '((type tty))))
  (custom-theme-set-faces
   'selenized-terminal
   `(default ((,tty (:foreground "unspecified-fg" :background "unspecified-bg"))))
   `(cursor ((,tty (:background "unspecified-fg"))))
   `(fringe ((,tty (:foreground "color-7" :background "unspecified-bg"))))
   `(vertical-border ((,tty (:foreground "color-8"))))
   `(window-divider ((,tty (:foreground "color-8"))))
   `(minibuffer-prompt ((,tty (:foreground "color-4" :weight bold))))
   `(region ((,tty (:inverse-video t :extend t))))
   `(secondary-selection ((,tty (:inverse-video t :extend t))))
   `(highlight ((,tty (:inverse-video t))))
   `(hl-line ((,tty (:underline t :extend t))))
   `(shadow ((,tty (:foreground "color-7"))))
   `(success ((,tty (:foreground "color-10" :weight bold))))
   `(warning ((,tty (:foreground "color-3" :weight bold))))
   `(error ((,tty (:foreground "color-9" :weight bold))))
   `(link ((,tty (:foreground "color-12" :underline t))))
   `(link-visited ((,tty (:foreground "color-5" :underline t))))
   `(trailing-whitespace ((,tty (:background "color-1"))))
   `(line-number ((,tty (:foreground "color-7" :background "unspecified-bg"))))
   `(line-number-current-line
     ((,tty (:foreground "color-12" :background "unspecified-bg" :weight bold))))

   `(mode-line ((,tty (:foreground "unspecified-bg" :background "unspecified-fg"
                       :weight bold :box nil))))
   `(mode-line-inactive
     ((,tty (:foreground "color-7" :background "unspecified-bg" :box nil))))
   `(header-line ((,tty (:inverse-video t :box nil))))
   `(eglot-mode-line ((,tty (:inherit mode-line :weight bold))))

   `(font-lock-comment-face ((,tty (:foreground "color-7" :slant italic))))
   `(font-lock-comment-delimiter-face ((,tty (:foreground "color-7" :slant italic))))
   `(font-lock-doc-face ((,tty (:foreground "color-7" :slant italic))))
   `(font-lock-string-face ((,tty (:foreground "color-6"))))
   `(font-lock-constant-face ((,tty (:foreground "color-6"))))
   `(font-lock-number-face ((,tty (:foreground "color-6"))))
   `(font-lock-builtin-face ((,tty (:foreground "color-6" :weight bold))))
   `(font-lock-function-name-face ((,tty (:foreground "color-4"))))
   `(font-lock-function-call-face ((,tty (:foreground "color-4"))))
   `(font-lock-keyword-face ((,tty (:foreground "color-2"))))
   `(font-lock-preprocessor-face ((,tty (:foreground "color-3"))))
   `(font-lock-type-face ((,tty (:foreground "color-5"))))
   `(font-lock-variable-name-face ((,tty (:foreground "unspecified-fg"))))
   `(font-lock-variable-use-face ((,tty (:foreground "unspecified-fg"))))
   `(font-lock-property-name-face ((,tty (:foreground "color-5"))))
   `(font-lock-property-use-face ((,tty (:foreground "color-5"))))
   `(font-lock-operator-face ((,tty (:foreground "color-3"))))
   `(font-lock-punctuation-face ((,tty (:foreground "color-7"))))
   `(font-lock-bracket-face ((,tty (:foreground "color-7"))))
   `(font-lock-delimiter-face ((,tty (:foreground "color-7"))))
   `(font-lock-escape-face ((,tty (:foreground "color-9" :weight bold))))
   `(font-lock-misc-punctuation-face ((,tty (:foreground "color-13" :weight bold))))
   `(font-lock-warning-face ((,tty (:foreground "color-9" :weight bold))))

   `(eglot-semantic-namespace ((,tty (:foreground "color-5"))))
   `(eglot-semantic-type ((,tty (:foreground "color-5"))))
   `(eglot-semantic-class ((,tty (:foreground "color-5"))))
   `(eglot-semantic-enum ((,tty (:foreground "color-5"))))
   `(eglot-semantic-interface ((,tty (:foreground "color-5"))))
   `(eglot-semantic-struct ((,tty (:foreground "color-5"))))
   `(eglot-semantic-typeParameter ((,tty (:foreground "color-5"))))
   `(eglot-semantic-parameter ((,tty (:foreground "unspecified-fg"))))
   `(eglot-semantic-variable ((,tty (:foreground "unspecified-fg"))))
   `(eglot-semantic-property ((,tty (:foreground "color-5"))))
   `(eglot-semantic-enumMember ((,tty (:foreground "color-6"))))
   `(eglot-semantic-event ((,tty (:foreground "unspecified-fg"))))
   `(eglot-semantic-function ((,tty (:foreground "color-4"))))
   `(eglot-semantic-method ((,tty (:foreground "color-4"))))
   `(eglot-semantic-macro ((,tty (:foreground "color-3"))))
   `(eglot-semantic-keyword ((,tty (:foreground "color-2"))))
   `(eglot-semantic-modifier ((,tty (:foreground "color-3"))))
   `(eglot-semantic-comment ((,tty (:foreground "color-7" :slant italic))))
   `(eglot-semantic-string ((,tty (:foreground "color-6"))))
   `(eglot-semantic-number ((,tty (:foreground "color-6"))))
   `(eglot-semantic-regexp ((,tty (:foreground "color-6"))))
   `(eglot-semantic-operator ((,tty (:foreground "color-3"))))
   `(eglot-semantic-decorator ((,tty (:foreground "color-5"))))
   `(eglot-semantic-declaration ((,tty (:foreground unspecified))))
   `(eglot-semantic-definition ((,tty (:foreground unspecified))))
   `(eglot-semantic-modification ((,tty (:foreground unspecified))))
   `(eglot-semantic-defaultLibrary
     ((,tty (:foreground unspecified :weight bold))))

   `(isearch ((,tty (:foreground "color-0" :background "color-11" :weight bold))))
   `(lazy-highlight ((,tty (:inverse-video t))))
   `(match ((,tty (:foreground "color-11" :weight bold :underline t))))
   `(show-paren-match ((,tty (:foreground "color-11" :weight bold :underline t))))
   `(show-paren-mismatch ((,tty (:foreground "color-0" :background "color-9" :weight bold))))

   `(completions-common-part ((,tty (:foreground "color-12" :weight bold))))
   `(completions-first-difference ((,tty (:foreground "color-13"))))
   `(vertico-current ((,tty (:inverse-video t :weight bold :extend t))))
   `(corfu-default ((,tty (:foreground "unspecified-fg" :background "unspecified-bg"))))
   `(corfu-current ((,tty (:inverse-video t :weight bold))))
   `(corfu-border ((,tty (:background "color-8"))))
   `(corfu-annotations ((,tty (:foreground "color-7" :slant italic))))
   `(marginalia-documentation ((,tty (:foreground "color-7" :slant italic))))
   `(marginalia-file-priv-dir ((,tty (:foreground "color-4" :weight bold))))
   `(which-key-key-face ((,tty (:foreground "color-12" :weight bold))))
   `(which-key-command-description-face ((,tty (:foreground "unspecified-fg"))))
   `(which-key-group-description-face ((,tty (:foreground "color-5"))))
   `(which-key-local-map-description-face ((,tty (:foreground "color-6"))))

   `(flymake-note ((,tty (:underline (:style wave :color "color-8")))))
   `(flymake-warning ((,tty (:underline (:style wave :color "color-3")))))
   `(flymake-error ((,tty (:underline (:style wave :color "color-9")))))
   `(diff-added ((,tty (:foreground "color-10" :background "unspecified-bg"))))
   `(diff-removed ((,tty (:foreground "color-9" :background "unspecified-bg"))))
   `(diff-changed ((,tty (:foreground "color-3" :background "unspecified-bg"))))
   `(diff-header ((,tty (:foreground "color-7" :inverse-video t))))
   `(diff-file-header ((,tty (:foreground "color-4" :inverse-video t :weight bold))))
   `(diff-refine-added ((,tty (:foreground "color-0" :background "color-10"))))
   `(diff-refine-removed ((,tty (:foreground "color-0" :background "color-9"))))

   ;; Magit and Majutsu.  Use the terminal's Selenized background step instead
   ;; of package-supplied greys; reserve underlining for compact selections.
   `(magit-section-highlight
     ((,tty (:background "color-0" :extend t))))
   `(magit-section-heading
     ((,tty (:foreground "color-11" :weight bold :extend t))))
   `(magit-section-secondary-heading
     ((,tty (:foreground "color-12" :weight bold :extend t))))
   `(magit-section-heading-selection
     ((,tty (:foreground "color-3" :weight bold :underline t :extend t))))
   `(magit-dimmed ((,tty (:foreground "color-7"))))
   `(magit-hash ((,tty (:foreground "color-7"))))
   `(magit-tag ((,tty (:foreground "color-11"))))
   `(magit-branch-local ((,tty (:foreground "color-12"))))
   `(magit-branch-current
     ((,tty (:inherit magit-branch-local :weight bold :underline t :box nil))))
   `(magit-branch-remote ((,tty (:foreground "color-10"))))
   `(magit-branch-remote-head
     ((,tty (:inherit magit-branch-remote :weight bold :underline t :box nil))))
   `(magit-head ((,tty (:inherit magit-branch-current))))
   `(magit-refname ((,tty (:foreground "unspecified-fg"))))
   `(magit-filename ((,tty (:foreground "unspecified-fg" :weight normal))))
   `(magit-signature-good ((,tty (:foreground "color-10"))))
   `(magit-signature-bad ((,tty (:foreground "color-9" :weight bold))))
   `(magit-signature-untrusted ((,tty (:foreground "color-14"))))
   `(magit-signature-expired ((,tty (:foreground "color-3"))))
   `(magit-signature-revoked ((,tty (:foreground "color-13"))))
   `(magit-signature-error ((,tty (:foreground "color-12"))))
   `(magit-log-graph ((,tty (:foreground "color-7"))))
   `(magit-log-author ((,tty (:foreground "color-3"))))
   `(magit-log-date ((,tty (:foreground "color-7"))))
   `(magit-diff-file-heading
     ((,tty (:foreground "color-4" :background "unspecified-bg" :weight bold :extend t))))
   `(magit-diff-file-heading-highlight
     ((,tty (:foreground "color-12" :background "color-0"
                         :weight bold :extend t))))
   `(magit-diff-file-heading-selection
     ((,tty (:foreground "color-3" :background "unspecified-bg"
                         :weight bold :underline t :extend t))))
   `(magit-diff-hunk-heading
     ((,tty (:foreground "color-7" :background "unspecified-bg" :extend t))))
   `(magit-diff-hunk-heading-highlight
     ((,tty (:foreground "unspecified-fg" :background "color-0"
                         :weight bold :extend t))))
   `(magit-diff-hunk-heading-selection
     ((,tty (:foreground "color-3" :background "unspecified-bg"
                         :weight bold :underline t :extend t))))
   `(magit-diff-lines-heading
     ((,tty (:foreground "color-3" :background "unspecified-bg"
                         :weight bold :inverse-video t :extend t))))
   `(magit-diff-context
     ((,tty (:foreground "color-7" :background "unspecified-bg" :extend t))))
   `(magit-diff-context-highlight
     ((,tty (:foreground "unspecified-fg" :background "color-0" :extend t))))
   `(magit-diff-removed
     ((,tty (:foreground "color-9" :background "unspecified-bg" :extend t))))
   `(magit-diff-removed-highlight
     ((,tty (:foreground "color-9" :background "unspecified-bg"
                         :weight bold :extend t))))
   `(magit-diff-added
     ((,tty (:foreground "color-10" :background "unspecified-bg" :extend t))))
   `(magit-diff-added-highlight
     ((,tty (:foreground "color-10" :background "unspecified-bg"
                         :weight bold :extend t))))
   `(magit-diff-base
     ((,tty (:foreground "color-11" :background "unspecified-bg" :extend t))))
   `(magit-diff-base-highlight
     ((,tty (:foreground "color-11" :background "unspecified-bg"
                         :weight bold :extend t))))
   `(majutsu-diff-color-words-focus
     ((,tty (:background "color-0" :extend t))))
   `(majutsu-annotate-highlight
     ((,tty (:background "color-0" :extend t))))
   `(majutsu-interactive-selected-hunk
     ((,tty (:foreground "color-10" :background "unspecified-bg"
                         :weight bold :underline t :extend t))))
   `(majutsu-interactive-selected-region
     ((,tty (:foreground "color-13" :background "unspecified-bg"
                         :weight bold :underline t :extend t))))
   `(majutsu-interactive-selected-file
     ((,tty (:foreground "color-12" :background "unspecified-bg"
                         :weight bold :underline t :extend t))))
   `(majutsu-conflict-marker-face
     ((,tty (:foreground "color-11" :background "unspecified-bg"
                         :weight bold :underline t :extend t))))
   `(majutsu-conflict-context-face
     ((,tty (:foreground "color-7" :background "unspecified-bg" :extend t))))
   `(majutsu-conflict-added-face
     ((,tty (:foreground "color-10" :background "unspecified-bg" :extend t))))
   `(majutsu-conflict-removed-face
     ((,tty (:foreground "color-9" :background "unspecified-bg" :extend t))))
   `(majutsu-conflict-refined-added
     ((,tty (:foreground "color-0" :background "color-10"))))
   `(majutsu-conflict-refined-removed
     ((,tty (:foreground "color-0" :background "color-9"))))

   `(dired-directory ((,tty (:foreground "color-4" :weight bold))))
   `(dired-symlink ((,tty (:foreground "color-6"))))
   `(dired-marked ((,tty (:foreground "color-5" :weight bold))))
   `(dired-flagged ((,tty (:foreground "color-9" :weight bold))))
   `(compilation-info ((,tty (:foreground "color-12"))))
   `(compilation-warning ((,tty (:foreground "color-3"))))
   `(compilation-error ((,tty (:foreground "color-9"))))

   `(org-level-1 ((,tty (:foreground "unspecified-fg" :weight bold :height 1.15))))
   `(org-level-2 ((,tty (:foreground "color-12" :weight bold))))
   `(org-level-3 ((,tty (:foreground "color-5" :weight bold))))
   `(org-level-4 ((,tty (:foreground "color-6" :weight bold))))
   `(org-code ((,tty (:foreground "color-6"))))
   `(org-verbatim ((,tty (:foreground "color-14"))))
   `(org-block ((,tty (:foreground "unspecified-fg" :background "unspecified-bg"))))
   `(org-block-begin-line ((,tty (:foreground "color-8" :inverse-video t))))
   `(org-link ((,tty (:foreground "color-12" :underline t))))
   `(org-special-keyword ((,tty (:foreground "color-3"))))
   `(org-meta-line ((,tty (:foreground "color-7" :slant italic))))
   `(org-todo ((,tty (:foreground "color-9" :weight bold))))
   `(org-done ((,tty (:foreground "color-10" :weight bold))))

   `(term-color-black ((,tty (:foreground "color-0" :background "color-0"))))
   `(term-color-red ((,tty (:foreground "color-1" :background "color-1"))))
   `(term-color-green ((,tty (:foreground "color-2" :background "color-2"))))
   `(term-color-yellow ((,tty (:foreground "color-3" :background "color-3"))))
   `(term-color-blue ((,tty (:foreground "color-4" :background "color-4"))))
   `(term-color-magenta ((,tty (:foreground "color-5" :background "color-5"))))
   `(term-color-cyan ((,tty (:foreground "color-6" :background "color-6"))))
   `(term-color-white ((,tty (:foreground "color-7" :background "color-7"))))
   `(ansi-color-black ((,tty (:foreground "color-0" :background "color-0"))))
   `(ansi-color-red ((,tty (:foreground "color-1" :background "color-1"))))
   `(ansi-color-green ((,tty (:foreground "color-2" :background "color-2"))))
   `(ansi-color-yellow ((,tty (:foreground "color-3" :background "color-3"))))
   `(ansi-color-blue ((,tty (:foreground "color-4" :background "color-4"))))
   `(ansi-color-magenta ((,tty (:foreground "color-5" :background "color-5"))))
   `(ansi-color-cyan ((,tty (:foreground "color-6" :background "color-6"))))
   `(ansi-color-white ((,tty (:foreground "color-7" :background "color-7"))))
   `(ansi-color-bright-black ((,tty (:foreground "color-8" :background "color-8"))))
   `(ansi-color-bright-red ((,tty (:foreground "color-9" :background "color-9"))))
   `(ansi-color-bright-green ((,tty (:foreground "color-10" :background "color-10"))))
   `(ansi-color-bright-yellow ((,tty (:foreground "color-11" :background "color-11"))))
   `(ansi-color-bright-blue ((,tty (:foreground "color-12" :background "color-12"))))
   `(ansi-color-bright-magenta ((,tty (:foreground "color-13" :background "color-13"))))
   `(ansi-color-bright-cyan ((,tty (:foreground "color-14" :background "color-14"))))
   `(ansi-color-bright-white ((,tty (:foreground "color-15" :background "color-15"))))))

(provide-theme 'selenized-terminal)
(provide-theme 'selenized-dark)
;;; selenized-dark-theme.el ends here
