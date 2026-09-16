;;; gptel-oauth-tests.el --- Subscription streaming regressions -*- lexical-binding: t; -*-

;; emacs --batch -l emacs/tests/gptel-oauth-tests.el -f ert-run-tests-batch-and-exit
(require 'ert)
(require 'gptel)
(require 'gptel-openai-oauth)
(require 'gptel-transient)

;; Load just the workaround, without applying the rest of the user config.
(with-temp-buffer
  (insert-file-contents
   (expand-file-name "../init.el" (file-name-directory load-file-name)))
  (search-forward "(defun my/gptel-oauth-buffered-request")
  (goto-char (match-beginning 0))
  (eval (read (current-buffer)) t))
(advice-add 'gptel-request :around #'my/gptel-oauth-buffered-request)

(ert-deftest my/gptel-oauth-echo-and-kill-ring-stream ()
  (dolist (destination '("e" "k"))
    (with-temp-buffer
      (let ((gptel-backend (gptel-make-openai-oauth "Test subscription"))
            (gptel-model 'gpt-6-astra)
            (gptel-prompt-transform-functions nil)
            (kill-ring nil)
            messages)
        (insert "Test prompt")
        (let* ((fsm (gptel--suffix-send (list destination "I")))
               (info (gptel-fsm-info fsm))
               (callback (plist-get info :callback)))
          (should (eq t (plist-get info :stream)))
          (should (eq t (plist-get (plist-get info :data) :stream)))
          (cl-letf (((symbol-function 'message)
                     (lambda (format-string &rest args)
                       (push (apply #'format format-string args) messages))))
            (funcall callback "Hello " info)
            (funcall callback "world" info)
            (should-not messages)
            (should-not kill-ring)
            (funcall callback t info)
            (should (= 1 (length messages)))
            (if (equal destination "k")
                (should (equal kill-ring '("Hello world")))
              (should (equal messages '("Test subscription response: Hello world"))))))))))

(ert-deftest my/gptel-oauth-buffered-events-and-turns ()
  (with-temp-buffer
    (let* ((gptel-backend (gptel-make-openai-oauth "Test subscription"))
           (gptel-model 'gpt-6-astra)
           events
           (fsm (gptel-request "Test" :dry-run t
                  :callback (lambda (response _info) (push response events))))
           (info (gptel-fsm-info fsm))
           (callback (plist-get info :callback)))
      (funcall callback '(reasoning . "Think ") info)
      (funcall callback '(reasoning . "first") info)
      (funcall callback '(reasoning . t) info)
      (funcall callback "First" info)
      (funcall callback t info)
      (funcall callback '(tool-call . (test-tool)) info)
      (funcall callback "Second" info)
      (funcall callback t info)
      (should (equal (nreverse events)
                     '((reasoning . "Think first") "First"
                       (tool-call . (test-tool)) "Second")))
      (setq events nil)
      (funcall callback "Incomplete" info)
      (funcall callback nil info)
      (funcall callback 'abort info)
      (should (equal (nreverse events) '(nil abort))))))

(ert-deftest my/gptel-oauth-leaves-streaming-callbacks-alone ()
  (with-temp-buffer
    (let* ((gptel-backend (gptel-make-openai-oauth "Test subscription"))
           (gptel-model 'gpt-6-astra)
           (callback #'ignore)
           (fsm (gptel-request "Test" :stream t :dry-run t :callback callback)))
      (should (eq callback (plist-get (gptel-fsm-info fsm) :callback))))))

(ert-deftest my/gptel-oauth-leaves-other-backends-alone ()
  (with-temp-buffer
    (let* ((gptel-backend (gptel-make-openai "Test API"))
           (gptel-model 'gpt-4o-mini)
           (callback #'ignore)
           (fsm (gptel-request "Test" :dry-run t :callback callback))
           (info (gptel-fsm-info fsm)))
      (should-not (plist-get info :stream))
      (should (eq callback (plist-get info :callback))))))

;;; gptel-oauth-tests.el ends here
