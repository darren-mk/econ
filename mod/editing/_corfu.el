;;; -*- lexical-binding: t; -*-

(defvar savehist-additional-variables)

(use-package corfu
  :ensure t
  :config
  (setq corfu-min-width 25
        corfu-max-width 100
        corfu-count 20
        corfu-auto t
        corfu-cycle t
        corfu-separator ?\s
        corfu-preview-current t
        corfu-scroll-margin 4
        tab-always-indent 'complete)
  (corfu-popupinfo-mode 1)
  (corfu-history-mode 1)
  (with-eval-after-load 'savehist
    (add-to-list 'savehist-additional-variables 'corfu-history)))
