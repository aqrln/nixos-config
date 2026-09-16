;;; gptel-agent-tests.el --- Subagent buffer lifetime regression -*- lexical-binding: t; -*-

;; emacs --batch -l emacs/tests/gptel-agent-tests.el -f ert-run-tests-batch-and-exit
(require 'ert)
(require 'gptel-agent)
(require 'gptel-openai-oauth)

(with-temp-buffer
  (insert-file-contents
   (expand-file-name "../init.el" (file-name-directory load-file-name)))
  (dolist (name '(my/gptel-oauth-buffered-request
                  my/gptel-agent-task-in-request-buffer))
    (goto-char (point-min))
    (search-forward (format "(defun %s" name))
    (goto-char (match-beginning 0))
    (eval (read (current-buffer)) t)))
(advice-add 'gptel-request :around #'my/gptel-oauth-buffered-request)
(advice-add 'gptel-agent--task :around #'my/gptel-agent-task-in-request-buffer)
(gptel-agent-update)

(ert-deftest my/gptel-agent-survives-tool-inspection-close ()
  (save-window-excursion
    (let ((parent (generate-new-buffer " *test-gptel-parent*"))
          (gptel-backend (gptel-make-openai-oauth "Test subscription"))
          (gptel-model 'gpt-6-astra)
          (request (symbol-function 'gptel-request))
          child)
      (unwind-protect
          (with-current-buffer parent
            (insert "Test prompt\n")
            (let* ((tool (gptel-get-tool "Agent"))
                   (args '(:subagent_type "introspector"
                           :description "Test task" :prompt "Test prompt"))
                   (calls (list (list tool args #'ignore)))
                   (info (list :buffer parent :position (point-marker)
                               :backend gptel-backend
                               :tool-use (list (list :name "Agent" :args args)))))
              (setq-local gptel--fsm-last (gptel-make-fsm :info info))
              (gptel--inspect-tool-calls calls info)
              (with-current-buffer "*gptel-tool-calls*"
                ;; Exercise the actual accept-and-close flow, without a network call.
                (cl-letf (((symbol-function 'gptel-request)
                           (lambda (prompt &rest request-args)
                             (setq child
                                   (apply request prompt
                                          (plist-put request-args :dry-run t))))))
                  (gptel--inspect-accept-tool-calls)))
              (should-not (get-buffer "*gptel-tool-calls*"))
              (let* ((child-info (gptel-fsm-info child))
                     (overlay (plist-get child-info :context)))
                (should (eq (plist-get child-info :buffer) parent))
                (should (eq (marker-buffer (plist-get child-info :position)) parent))
                (should (eq (overlay-buffer overlay) parent))
                (should (eq t (plist-get (plist-get child-info :data) :stream)))
                ;; A subsequent tool turn must still be able to enter its buffer.
                (with-current-buffer (plist-get child-info :buffer)
                  (should (buffer-live-p (current-buffer)))))))
        (when (get-buffer "*gptel-tool-calls*")
          (kill-buffer "*gptel-tool-calls*"))
        (kill-buffer parent)))))

;;; gptel-agent-tests.el ends here
