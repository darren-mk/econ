;;; -*- lexical-binding: t; -*-

(defun kill-all-buffers ()
  (interactive)
  (mapc #'kill-buffer (buffer-list)))

(global-set-key
 (kbd "C-c C-j C-k")
 #'kill-all-buffers)
