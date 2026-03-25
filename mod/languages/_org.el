;;; -*- lexical-binding: t; -*-

(use-package org
  :hook ((org-mode . visual-line-mode)
         (org-mode . variable-pitch-mode)
         (org-mode . my/org-mode-setup))
  :config
  (defun my/org-mode-setup ()
    "Personal tweaks for Org buffers."
    (setq-local line-spacing 0.15)
    (setq org-pretty-entities t
          org-hide-emphasis-markers t
          org-image-actual-width '(400))
    (set-face-attribute 'org-code nil :inherit '(fixed-pitch))
    (set-face-attribute 'org-verbatim nil :inherit '(fixed-pitch))
    (set-face-attribute 'org-block nil :inherit '(fixed-pitch))
    (set-face-attribute 'org-block-begin-line nil :inherit '(fixed-pitch))
    (set-face-attribute 'org-block-end-line nil :inherit '(fixed-pitch))
    (set-face-attribute 'org-table nil :inherit '(fixed-pitch))
    (set-face-attribute 'org-formula nil :inherit '(fixed-pitch))
    (set-face-attribute 'org-meta-line nil :inherit '(fixed-pitch))
    (set-face-attribute 'org-document-info-keyword nil :inherit '(fixed-pitch))))
