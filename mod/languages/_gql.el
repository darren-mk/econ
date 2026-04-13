;;; -*- lexical-binding: t; -*-

;; npm install -g graphql-language-service-cli

(defvar eglot-server-programs)

(use-package graphql-mode
  :ensure t
  :hook ((graphql-mode . eglot-ensure)
         (graphql-mode . corfu-mode))
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '(graphql-mode . ("graphql-lsp" "server" "--method" "stream")))))
