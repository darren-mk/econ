;;; -*- lexical-binding: t; -*-

(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook #'enable-paredit-mode)
(setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))
