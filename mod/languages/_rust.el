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
  (rustic-cargo-use-last-stored-arguments t)
  :config
  (defun dk/rustic-cargo-test-ignored ()
    "Run the test at point with --ignored --nocapture flags."
    (interactive)
    (compile "cargo test -- --ignored --nocapture"))
  :bind (:map rustic-mode-map
              ("C-c C-c C-i" . dk/rustic-cargo-test-ignored)))
