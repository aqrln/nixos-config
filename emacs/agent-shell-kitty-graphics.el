;;; agent-shell-kitty-graphics.el --- Terminal images for Agent Shell -*- lexical-binding: t; -*-

;; Keep Agent Shell's native image properties for parsing, copying, scaling,
;; and graphical frames.  Mirror them with one Kitty Graphics overlay per
;; image and terminal window; streaming must never recreate existing images.

(require 'cl-lib)
(require 'agent-shell-markdown)
(require 'kitty-graphics)

(defgroup agent-shell-kitty-graphics nil
  "Terminal image display for Agent Shell."
  :group 'agent-shell)

(defvar-local agent-shell-kitty-graphics--overlays nil)
(defvar agent-shell-kitty-graphics--buffers nil)
(defvar agent-shell-kitty-graphics--syncing nil)

(defun agent-shell-kitty-graphics--terminal-p (window)
  "Return non-nil if WINDOW belongs to a supported graphics terminal."
  (and kitty-graphics-mode
       (window-live-p window)
       (not (display-graphic-p (window-frame window)))
       (terminal-parameter (frame-terminal (window-frame window))
                           'kitty-graphics-backend)))

(defun agent-shell-kitty-graphics--available-p ()
  "Allow native image properties when Kitty Graphics can display them."
  (and kitty-graphics-mode
       (cl-some (lambda (terminal)
                  (terminal-parameter terminal 'kitty-graphics-backend))
                (terminal-list))))

(defun agent-shell-kitty-graphics--window-pixels (original window dimension)
  "Measure terminal WINDOW in actual pixels for image DIMENSION."
  (if (agent-shell-kitty-graphics--terminal-p window)
      (let ((terminal (frame-terminal (window-frame window))))
        (* (if (eq dimension 'width)
               (window-body-width window)
             (window-body-height window))
           (if (eq dimension 'width)
               (or (terminal-parameter terminal 'kitty-graphics-cell-w) 8)
             (or (terminal-parameter terminal 'kitty-graphics-cell-h) 16))))
    (funcall original window dimension)))

(defun agent-shell-kitty-graphics--remove (overlay)
  "Remove OVERLAY and its terminal placement."
  (kitty-graphics--remove-overlay overlay)
  (setq agent-shell-kitty-graphics--overlays
        (delq overlay agent-shell-kitty-graphics--overlays)))

(defun agent-shell-kitty-graphics--prune ()
  "Remove images whose text or owning window no longer exists."
  (save-restriction
    (widen)
    (dolist (overlay (copy-sequence agent-shell-kitty-graphics--overlays))
      (let ((window (overlay-get overlay 'window))
            (start (overlay-start overlay))
            (end (overlay-end overlay)))
        (unless (and start end (< start end)
                     (agent-shell-kitty-graphics--terminal-p window)
                     (eq (window-buffer window) (current-buffer))
                     (equal (get-text-property start 'display)
                            (overlay-get overlay 'agent-shell-kitty-graphics-image)))
          (agent-shell-kitty-graphics--remove overlay))))))

(defun agent-shell-kitty-graphics--after-change (_beg _end _old-length)
  "Clean up deleted or replaced image spans without scanning the thread."
  (when agent-shell-kitty-graphics--overlays
    (agent-shell-kitty-graphics--prune)))

(defun agent-shell-kitty-graphics--cleanup ()
  "Release terminal image placements owned by this buffer."
  (dolist (overlay (copy-sequence agent-shell-kitty-graphics--overlays))
    (agent-shell-kitty-graphics--remove overlay))
  (setq agent-shell-kitty-graphics--buffers
        (delq (current-buffer) agent-shell-kitty-graphics--buffers)))

(defun agent-shell-kitty-graphics--track-buffer ()
  "Arrange cleanup when image content or the current buffer goes away."
  (cl-pushnew (current-buffer) agent-shell-kitty-graphics--buffers)
  (add-hook 'after-change-functions #'agent-shell-kitty-graphics--after-change nil t)
  (add-hook 'kill-buffer-hook #'agent-shell-kitty-graphics--cleanup nil t)
  (add-hook 'change-major-mode-hook #'agent-shell-kitty-graphics--cleanup nil t))

(defun agent-shell-kitty-graphics--ensure (window start end image)
  "Mirror IMAGE on START through END in terminal WINDOW, reusing its overlay."
  (let* ((terminal (frame-terminal (window-frame window)))
         (cell-width (or (terminal-parameter terminal 'kitty-graphics-cell-w) 8))
         (cell-height (or (terminal-parameter terminal 'kitty-graphics-cell-h) 16))
         (width (image-property image :max-width))
         (height (image-property image :max-height))
         (columns (max 1 (min kitty-graphics-max-width
                              (window-body-width window)
                              (if (numberp width)
                                  (max 1 (floor width cell-width))
                                (window-body-width window)))))
         (rows (max 1 (min kitty-graphics-max-height
                           (1- (window-body-height window))
                           (if (numberp height)
                               (max 1 (floor height cell-height))
                             (window-body-height window)))))
         (key (list image columns rows cell-width cell-height))
         (existing (cl-find-if
                    (lambda (overlay)
                      (and (eq (overlay-get overlay 'window) window)
                           (eq (overlay-start overlay) start)))
                    agent-shell-kitty-graphics--overlays)))
    (if (and existing
             (= (overlay-end existing) end)
             (equal (overlay-get existing 'agent-shell-kitty-graphics-key) key))
        existing
      (when existing
        (agent-shell-kitty-graphics--remove existing))
      (with-selected-window window
        (kitty-graphics--with-terminal terminal
          (when-let* ((overlay (kitty-graphics-display-image
                               (image-property image :file) start end columns rows)))
            ;; A terminal overlay must not hide the native image in a GUI
            ;; window, or reserve the wrong number of cells in another TTY.
            (overlay-put overlay 'window window)
            (overlay-put overlay 'agent-shell-kitty-graphics-image (copy-tree image))
            (overlay-put overlay 'agent-shell-kitty-graphics-key (copy-tree key))
            (push overlay agent-shell-kitty-graphics--overlays)
            overlay))))))

(defun agent-shell-kitty-graphics--sync-window (window &rest _)
  "Materialize native image properties visible in terminal WINDOW."
  (when (agent-shell-kitty-graphics--terminal-p window)
    (with-current-buffer (window-buffer window)
      (when (or (memq (current-buffer) agent-shell-kitty-graphics--buffers)
                (derived-mode-p 'agent-shell-mode 'agent-shell-viewport-view-mode))
        (agent-shell-kitty-graphics--track-buffer)
        (agent-shell-kitty-graphics--prune)
        (save-excursion
          (save-restriction
            (widen)
            (let* ((visible-start (window-start window))
                   (visible-end (or (window-end window t) (point-max)))
                   ;; Include an image whose text span crosses window-start.
                   (position (if (< visible-start (point-max))
                                 (or (previous-single-property-change
                                      (1+ visible-start) 'display nil (point-min))
                                     (point-min))
                               visible-start)))
              (while (< position (min visible-end (point-max)))
                (let* ((image (get-text-property position 'display))
                       (end (next-single-property-change
                             position 'display nil (point-max))))
                  (when (and (eq (car-safe image) 'image)
                             (get-text-property position 'agent-shell-markdown-image)
                             (image-property image :file)
                             (not (invisible-p position)))
                    (agent-shell-kitty-graphics--ensure window position end image))
                  (setq position end))))))))))

(defun agent-shell-kitty-graphics--sync-visible (&rest _)
  "Synchronize visible terminal windows, including newly opened clients."
  (unless agent-shell-kitty-graphics--syncing
    (let ((agent-shell-kitty-graphics--syncing t))
      (dolist (buffer (copy-sequence agent-shell-kitty-graphics--buffers))
        (if (buffer-live-p buffer)
            (with-current-buffer buffer (agent-shell-kitty-graphics--prune))
          (setq agent-shell-kitty-graphics--buffers
                (delq buffer agent-shell-kitty-graphics--buffers))))
      (walk-windows #'agent-shell-kitty-graphics--sync-window nil 'visible))))

(defun agent-shell-kitty-graphics--image-updated (_start _end _image)
  "Materialize a newly rendered or resized image in visible terminals."
  (agent-shell-kitty-graphics--track-buffer)
  (dolist (window (get-buffer-window-list (current-buffer) nil t))
    (agent-shell-kitty-graphics--sync-window window)))

(defun agent-shell-kitty-graphics--screen-position (original overlay &optional window)
  "Respect the window restriction on our terminal OVERLAY."
  (when (or (not (overlay-get overlay 'agent-shell-kitty-graphics-key))
            (eq (overlay-get overlay 'window)
                (or window (get-buffer-window (overlay-buffer overlay)))))
    (funcall original overlay window)))

;;;###autoload
(define-minor-mode agent-shell-kitty-graphics-mode
  "Display Agent Shell's native images through Kitty Graphics in terminals."
  :global t
  (if agent-shell-kitty-graphics-mode
      (progn
        (add-hook 'agent-shell-markdown-image-display-p-functions
                  #'agent-shell-kitty-graphics--available-p)
        (add-hook 'agent-shell-markdown-image-update-functions
                  #'agent-shell-kitty-graphics--image-updated)
        (advice-add 'agent-shell-markdown--window-pixels :around
                    #'agent-shell-kitty-graphics--window-pixels)
        (advice-add 'kitty-graphics--overlay-screen-pos :around
                    #'agent-shell-kitty-graphics--screen-position)
        (advice-add 'kitty-graphics--refresh :before
                    #'agent-shell-kitty-graphics--sync-visible)
        (advice-add 'kitty-graphics--on-buffer-change :after
                    #'agent-shell-kitty-graphics--sync-visible)
        (advice-add 'kitty-graphics--on-window-scroll :before
                    #'agent-shell-kitty-graphics--sync-window)
        (add-hook 'kitty-graphics-mode-hook #'agent-shell-kitty-graphics--sync-visible)
        (agent-shell-kitty-graphics--sync-visible))
    (remove-hook 'agent-shell-markdown-image-display-p-functions
                 #'agent-shell-kitty-graphics--available-p)
    (remove-hook 'agent-shell-markdown-image-update-functions
                 #'agent-shell-kitty-graphics--image-updated)
    (advice-remove 'agent-shell-markdown--window-pixels
                   #'agent-shell-kitty-graphics--window-pixels)
    (advice-remove 'kitty-graphics--overlay-screen-pos
                   #'agent-shell-kitty-graphics--screen-position)
    (advice-remove 'kitty-graphics--refresh #'agent-shell-kitty-graphics--sync-visible)
    (advice-remove 'kitty-graphics--on-buffer-change #'agent-shell-kitty-graphics--sync-visible)
    (advice-remove 'kitty-graphics--on-window-scroll #'agent-shell-kitty-graphics--sync-window)
    (remove-hook 'kitty-graphics-mode-hook #'agent-shell-kitty-graphics--sync-visible)
    (dolist (buffer (copy-sequence agent-shell-kitty-graphics--buffers))
      (when (buffer-live-p buffer)
        (with-current-buffer buffer
          (agent-shell-kitty-graphics--cleanup)
          (remove-hook 'after-change-functions #'agent-shell-kitty-graphics--after-change t)
          (remove-hook 'kill-buffer-hook #'agent-shell-kitty-graphics--cleanup t)
          (remove-hook 'change-major-mode-hook #'agent-shell-kitty-graphics--cleanup t))))))

(provide 'agent-shell-kitty-graphics)
;;; agent-shell-kitty-graphics.el ends here
