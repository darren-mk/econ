;;; -*- lexical-binding: t; -*-

;; mac:
;; $ brew install rustup
;; $ rustup-init
;; $ rustup component add rust-analyzer

(use-package rustic
  :ensure t
  :hook (rustic-mode . corfu-mode)
  :custom
  (rustic-lsp-client 'eglot)
  (rustic-format-on-save nil)
  (rustic-cargo-use-last-stored-arguments t))
