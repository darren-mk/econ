;;; -*- lexical-binding: t; -*-

(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind ("C-c SPC" . claude-code-ide-menu)
  :config (claude-code-ide-emacs-tools-setup))
