;;; dape-rust-tests.el --- Rust test preset checks -*- lexical-binding: t; -*-

;; emacs --batch -q -l emacs/tests/dape-rust-tests.el -f ert-run-tests-batch-and-exit
(require 'ert)
(require 'dape)
(require 'use-package)

(with-temp-buffer
  (insert-file-contents
   (expand-file-name "../init.el" (file-name-directory load-file-name)))
  (dolist (name '(my/dape-rust-test-artifacts
                  my/dape-rust-test-select
                  my/dape-rust-test-prepare))
    (goto-char (point-min))
    (search-forward (format "(defun %s" name))
    (goto-char (match-beginning 0))
    (eval (read (current-buffer)) t))
  (goto-char (point-min))
  (search-forward "(use-package dape")
  (goto-char (match-beginning 0))
  (eval (read (current-buffer)) t))

(defconst my/dape-rust-test-output
  (concat
   "Compiling workspace\n"
   "{not a Cargo message}\n"
   "{\"reason\":\"compiler-artifact\",\"profile\":{\"test\":false},\"executable\":\"/tmp/ordinary-bin\"}\n"
   "{\"reason\":\"compiler-artifact\",\"profile\":{\"test\":true},\"executable\":null}\n"
   "{\"reason\":\"compiler-artifact\",\"profile\":{\"test\":true},\"executable\":\"/tmp/custom target/unit-123\",\"manifest_path\":\"/tmp/member/Cargo.toml\"}\n"
   "{\"reason\":\"compiler-artifact\",\"profile\":{\"test\":true},\"executable\":\"/tmp/custom target/integration-456\",\"manifest_path\":\"/tmp/member/Cargo.toml\"}\n"
   "{\"reason\":\"build-finished\",\"success\":true}\n"))

(ert-deftest my/dape-rust-artifacts-use-cargo-output ()
  (with-temp-buffer
    (insert my/dape-rust-test-output)
    (should (equal (mapcar (lambda (a) (alist-get 'executable a))
                          (my/dape-rust-test-artifacts))
                   '("/tmp/custom target/unit-123"
                     "/tmp/custom target/integration-456")))))

(ert-deftest my/dape-rust-build-before-selection ()
  (let ((build-buffer (generate-new-buffer " *rust-test-build*"))
        (dape-start-hook nil)
        (dape-compile-hook nil)
        (dape-default-config-functions nil)
        (dape--connections nil)
        (dape--connection-selected nil)
        (dape-compile-function
         (lambda (command)
           (should (string-match-p "cargo test --no-run" command))
           (should (string-match-p "--message-format=json" command))))
        launched prompts)
    (unwind-protect
        (cl-letf (((symbol-function 'compilation-find-buffer)
                   (lambda (&rest _) build-buffer))
                  ((symbol-function 'dape--create-connection)
                   (lambda (config &rest _)
                     (setq launched config)
                     'test-connection))
                  ((symbol-function 'dape--start-debugging) #'ignore)
                  ((symbol-function 'completing-read)
                   (lambda (prompt &rest _)
                     (push prompt prompts)
                     (if (equal prompt "Test executable: ")
                         "custom target/integration-456"
                       "tests::ignored_case")))
                  ((symbol-function 'process-file)
                   (lambda (program _in _out _display &rest args)
                     (should (equal program "/tmp/custom target/integration-456"))
                     (should (equal args '("--list" "--format=terse")))
                     (should (equal default-directory "/tmp/member/"))
                     (should (equal (getenv "DAPE_TEST_ENV") "dev-flake"))
                     (should (equal (car exec-path) "/tmp/dev-flake/bin"))
                     (insert "tests::ignored_case: test\nbench: benchmark\n")
                     0)))
          (with-current-buffer build-buffer
            (compilation-mode)
            (setq-local process-environment
                        (cons "DAPE_TEST_ENV=dev-flake" process-environment))
            (setq-local exec-path (cons "/tmp/dev-flake/bin" exec-path)))
          (let ((config (copy-tree (alist-get 'rust-gdb-test dape-configs))))
            (setf (plist-get config 'ensure) nil
                  (plist-get config 'command-cwd) "/tmp/")
            (dape config))
          ;; No executable lookup or picker before a successful build.
          (should-not launched)
          (should-not prompts)
          (with-current-buffer build-buffer
            (let ((inhibit-read-only t))
              (insert my/dape-rust-test-output))
            (run-hook-with-args 'compilation-finish-functions
                                build-buffer "finished\n"))
          (should (equal (plist-get launched :program)
                         "/tmp/custom target/integration-456"))
          (should (equal (plist-get launched :cwd) "/tmp/member/"))
          (should (equal (plist-get launched :args)
                         ["--nocapture" "--test-threads=1"
                          "tests::ignored_case" "--exact" "--include-ignored"]))
          (should-not (plist-get launched 'fn)))
      (kill-buffer build-buffer))))

(ert-deftest my/dape-rust-all-tests-and-empty-output ()
  (with-temp-buffer
    (let ((build-buffer (current-buffer)))
      (cl-letf (((symbol-function 'compilation-find-buffer)
                 (lambda (&rest _) build-buffer))
                ((symbol-function 'process-file)
                 (lambda (&rest _) (insert "some_test: test\n") 0))
                ((symbol-function 'completing-read)
                 (lambda (prompt &rest _)
                   (if (equal prompt "Test executable: ")
                       "custom target/unit-123"
                     "<all tests>"))))
        (should-error (my/dape-rust-test-select '(command-cwd "/tmp/"))
                      :type 'user-error)
        (insert my/dape-rust-test-output)
        (let ((config (my/dape-rust-test-select
                       '(command-cwd "/tmp/" :args ["--nocapture"]))))
          (should (equal (plist-get config :args) ["--nocapture"])))))))

(ert-deftest my/dape-rust-failed-build-does-not-select ()
  (with-temp-buffer
    (let ((build-buffer (current-buffer))
          (dape-default-config-functions nil)
          (dape-compile-function #'ignore))
      (cl-letf (((symbol-function 'compilation-find-buffer)
                 (lambda (&rest _) build-buffer))
                ((symbol-function 'my/dape-rust-test-select)
                 (lambda (&rest _) (ert-fail "Selected tests after failed build"))))
        (let ((config (copy-tree (alist-get 'rust-gdb-test dape-configs))))
          (setf (plist-get config 'ensure) nil
                (plist-get config 'command-cwd) "/tmp/")
          (dape config))
        ;; Cargo can emit some artifacts before another target fails.
        (insert my/dape-rust-test-output)
        (run-hook-with-args 'compilation-finish-functions
                            build-buffer "exited abnormally with code 101\n")))))

;;; dape-rust-tests.el ends here
