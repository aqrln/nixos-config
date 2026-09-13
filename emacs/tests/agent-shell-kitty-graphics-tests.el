;;; agent-shell-kitty-graphics-tests.el --- Integration regressions -*- lexical-binding: t; -*-

;; Run with the configured Emacs package after rebuilding:
;; emacs --batch --eval '(package-initialize)' \
;;   -l emacs/tests/agent-shell-kitty-graphics-tests.el \
;;   -f ert-run-tests-batch-and-exit

(require 'ert)
(require 'cl-lib)
(require 'agent-shell-kitty-graphics)

(defvar as-kg-test-file nil)
(defvar as-kg-test-dimension-calls 0)

(defmacro as-kg-test-with-terminal (&rest body)
  "Run BODY with real image overlays and mocked terminal transport."
  (declare (indent 0))
  `(let* ((terminal (frame-terminal))
          (old-parameters (mapcar (lambda (key) (cons key (terminal-parameter terminal key)))
                                 '(kitty-graphics-backend kitty-graphics-cell-w kitty-graphics-cell-h)))
          (as-kg-test-file (make-temp-file "agent-shell-image-" nil ".png"))
          (as-kg-test-dimension-calls 0)
          (kitty-graphics-mode t)
          (kitty-graphics--active-backend 'kitty)
          (kitty-graphics--image-cache (make-hash-table :test 'equal))
          (kitty-graphics--cache-lru nil)
          (agent-shell-kitty-graphics--buffers nil))
     (unwind-protect
         (save-window-excursion
           (set-terminal-parameter terminal 'kitty-graphics-backend 'kitty)
           (set-terminal-parameter terminal 'kitty-graphics-cell-w 8)
           (set-terminal-parameter terminal 'kitty-graphics-cell-h 16)
           (with-temp-file as-kg-test-file
             (set-buffer-multibyte nil)
             (insert (base64-decode-string
                      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=")))
           (cl-letf (((symbol-function 'kitty-graphics--schedule-refresh) #'ignore)
                     ((symbol-function 'kitty-graphics--image-pixel-size)
                      (lambda (_) (cl-incf as-kg-test-dimension-calls) '(64 . 32)))
                     ((symbol-function 'kitty-graphics--backend-fn)
                      (lambda (_) (lambda (&rest _) t))))
             (agent-shell-kitty-graphics-mode 1)
             (with-temp-buffer
               (switch-to-buffer (current-buffer))
               ,@body)))
       (agent-shell-kitty-graphics-mode -1)
       (dolist (entry old-parameters)
         (set-terminal-parameter terminal (car entry) (cdr entry)))
       (delete-file as-kg-test-file))))

(defun as-kg-test-render (&rest args)
  (apply #'agent-shell-markdown-replace-markup :highlight-blocks nil args))

(defun as-kg-test-images ()
  (seq-filter (lambda (overlay) (overlay-buffer overlay))
              agent-shell-kitty-graphics--overlays))

(ert-deftest as-kg-native-image-and-markdown-copy ()
  (as-kg-test-with-terminal
    (let ((source (format "**Hello**\n![image](%s)\n" as-kg-test-file)))
      (insert source)
      (as-kg-test-render :complete t)
      (should (= (length (as-kg-test-images)) 1))
      (let* ((overlay (car (as-kg-test-images)))
             (start (overlay-start overlay))
             (image (get-text-property start 'display)))
        (should (eq (car image) 'image))
        (should (equal (image-property image :file) as-kg-test-file))
        (should (eq (overlay-get overlay 'window) (selected-window))))
      (should (equal (agent-shell-markdown-reconstruct (point-min) (point-max)) source)))))

(ert-deftest as-kg-streaming-reuses-two-images ()
  (as-kg-test-with-terminal
    (insert (format "![one](%s)\n![two](%s)\n" as-kg-test-file as-kg-test-file))
    (as-kg-test-render)
    (let ((original-overlays (copy-sequence (as-kg-test-images))))
      (dotimes (_ 300)
        (goto-char (point-max))
        (insert "some **streaming** text\n")
        (as-kg-test-render)
        (agent-shell-kitty-graphics--sync-visible))
      (should (= (length (as-kg-test-images)) 2))
      (should (= as-kg-test-dimension-calls 2))
      (should (equal original-overlays (as-kg-test-images))))))

(ert-deftest as-kg-defers-incomplete-images-and-honors-attributes ()
  (as-kg-test-with-terminal
    (insert (format "![image](%s)" as-kg-test-file))
    (as-kg-test-render)
    (should-not (as-kg-test-images))
    (goto-char (point-max))
    (insert "{width=32px}\n")
    (as-kg-test-render)
    (should (= (length (as-kg-test-images)) 1))
    (should (= (overlay-get (car (as-kg-test-images)) 'kitty-graphics-cols) 4))))

(ert-deftest as-kg-final-image-without-newline ()
  (as-kg-test-with-terminal
    (insert (format "![image](%s)" as-kg-test-file))
    (as-kg-test-render :complete t)
    (should (= (length (as-kg-test-images)) 1))))

(ert-deftest as-kg-code-and-disabled-images-are-not-rendered ()
  (as-kg-test-with-terminal
    (insert (format "`![inline](%s)`\n\n```text\n![fenced](%s)\n```\n"
                    as-kg-test-file as-kg-test-file))
    (as-kg-test-render :complete t)
    (should-not (as-kg-test-images))
    (erase-buffer)
    (insert (format "![image](%s)\n" as-kg-test-file))
    (as-kg-test-render :render-images nil :complete t)
    (should-not (as-kg-test-images))))

(ert-deftest as-kg-bare-file-path ()
  (as-kg-test-with-terminal
    (insert as-kg-test-file "\n")
    (as-kg-test-render :complete t)
    (should (= (length (as-kg-test-images)) 1))
    (dotimes (_ 3) (as-kg-test-render :force t))
    (should (= (length (as-kg-test-images)) 1))))

(ert-deftest as-kg-deletion-releases-overlay ()
  (as-kg-test-with-terminal
    (insert (format "![image](%s)\n" as-kg-test-file))
    (as-kg-test-render :complete t)
    (let ((overlay (car (as-kg-test-images))))
      (erase-buffer)
      (should-not (overlay-buffer overlay))
      (should-not (as-kg-test-images))
      (should-not kitty-graphics--overlays))))

(ert-deftest as-kg-image-resize-replaces-one-overlay ()
  (as-kg-test-with-terminal
    (insert (format "![image](%s)\n" as-kg-test-file))
    (as-kg-test-render :complete t)
    (let* ((overlay (car (as-kg-test-images)))
           (start (overlay-start overlay))
           (end (overlay-end overlay)))
      (agent-shell-markdown--resize-image start end 24 640)
      (should-not (overlay-buffer overlay))
      (should (= (length (as-kg-test-images)) 1))
      (should (= (overlay-get (car (as-kg-test-images)) 'kitty-graphics-cols) 3)))))

(ert-deftest as-kg-terminal-pixel-dimensions ()
  (as-kg-test-with-terminal
    (should (= (agent-shell-markdown--window-pixels (selected-window) 'width)
               (* 8 (window-body-width))))
    (should (= (agent-shell-markdown--window-pixels (selected-window) 'height)
               (* 16 (window-body-height))))))

(ert-deftest as-kg-separate-terminal-windows ()
  (as-kg-test-with-terminal
    (delete-other-windows)
    (let* ((first (selected-window))
           (second (split-window-right)))
      (set-window-buffer second (current-buffer))
      (insert (format "![image](%s)\n" as-kg-test-file))
      (as-kg-test-render :complete t)
      (should (= (length (as-kg-test-images)) 2))
      (let ((overlay (cl-find first (as-kg-test-images)
                              :key (lambda (ov) (overlay-get ov 'window)))))
        (should (agent-shell-kitty-graphics--screen-position
                 (lambda (&rest _) 'visible) overlay first))
        (should-not (agent-shell-kitty-graphics--screen-position
                     (lambda (&rest _) 'visible) overlay second)))
      (delete-window second)
      (agent-shell-kitty-graphics--sync-visible)
      (should (= (length (as-kg-test-images)) 1)))))

(ert-deftest as-kg-gui-retains-native-image-without-terminal-overlay ()
  (as-kg-test-with-terminal
    (cl-letf (((symbol-function 'display-graphic-p) (lambda (&rest _) t))
              ((symbol-function 'image-flush) #'ignore))
      (insert (format "![image](%s)\n" as-kg-test-file))
      (as-kg-test-render :complete t)
      (should (eq (car-safe (get-text-property (point-min) 'display)) 'image))
      (should-not (as-kg-test-images)))))

(ert-deftest as-kg-unavailable-terminal-keeps-text ()
  (as-kg-test-with-terminal
    (let ((kitty-graphics-mode nil))
      (insert (format "![image](%s)\n" as-kg-test-file))
      (as-kg-test-render :complete t)
      (should-not (get-text-property (point-min) 'display))
      (should-not (as-kg-test-images)))))

(ert-deftest as-kg-sixel-reuses-image-placements ()
  (as-kg-test-with-terminal
    (set-terminal-parameter (frame-terminal) 'kitty-graphics-backend 'sixel)
    (insert (format "![one](%s)\n![two](%s)\n" as-kg-test-file as-kg-test-file))
    (as-kg-test-render :complete t)
    (dotimes (_ 20) (agent-shell-kitty-graphics--sync-visible))
    (should (= (length (as-kg-test-images)) 2))
    (should (= as-kg-test-dimension-calls 2))))

(ert-deftest as-kg-hidden-images-are-materialized-when-shown ()
  (as-kg-test-with-terminal
    (let ((buffer (current-buffer)))
      (set-window-buffer (selected-window) (get-buffer-create " *as-kg-other*"))
      (unwind-protect
          (progn
            (with-current-buffer buffer
              (insert (format "![image](%s)\n" as-kg-test-file))
              (as-kg-test-render :complete t)
              (should-not (as-kg-test-images))
              (should (= as-kg-test-dimension-calls 0)))
            (set-window-buffer (selected-window) buffer)
            (with-current-buffer buffer
              (agent-shell-kitty-graphics--sync-visible)
              (should (= (length (as-kg-test-images)) 1))))
        (kill-buffer " *as-kg-other*")))))

(ert-deftest as-kg-copied-native-image-keeps-terminal-support ()
  (as-kg-test-with-terminal
    (insert (format "![image](%s)\n" as-kg-test-file))
    (as-kg-test-render :complete t)
    (let ((content (buffer-string)))
      (with-temp-buffer
        (setq major-mode 'agent-shell-viewport-view-mode)
        (insert content)
        (switch-to-buffer (current-buffer))
        (agent-shell-kitty-graphics--sync-visible)
        (should (= (length (as-kg-test-images)) 1))))))

(ert-deftest as-kg-remote-image-uses-upstream-cache ()
  (as-kg-test-with-terminal
    (let ((calls 0))
      (cl-letf (((symbol-function 'agent-shell-markdown--fetch-remote-image)
                 (lambda (_url cache)
                   (should (equal cache "/tmp/test-image-cache"))
                   (cl-incf calls)
                   as-kg-test-file)))
        (insert "![remote](https://example.invalid/test.png)\n")
        (as-kg-test-render :complete t :image-cache-directory "/tmp/test-image-cache")
        (as-kg-test-render :force t :image-cache-directory "/tmp/test-image-cache")
        (should (= calls 1))
        (should (= (length (as-kg-test-images)) 1))))))

(provide 'agent-shell-kitty-graphics-tests)
