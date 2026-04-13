;;; -*- lexical-binding: t; -*-

;; brew install pyright

(defvar eglot-server-programs)

(use-package python
  :hook ((python-mode . eglot-ensure)
         (python-mode . corfu-mode))
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '(python-mode . ("pyright-langserver" "--stdio")))))

(use-package pytest
  :ensure t
  :bind (("C-c t t" . pytest-one)
         ("C-c t f" . pytest-file)
         ("C-c t p" . pytest))
  :config (setq pytest-cmd-flags "-q"))
