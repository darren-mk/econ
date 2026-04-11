;;; -*- lexical-binding: t; -*-

(add-hook 'dired-mode-hook
	        (lambda ()
	          (dired-hide-details-mode)))
