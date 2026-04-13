;;; -*- lexical-binding: t; -*-

;; brew install sql-language-server

(defvar eglot-server-programs)

(use-package sql
  :hook ((sql-mode . eglot-ensure)
         (sql-mode . corfu-mode))
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '(sql-mode . ("sql-language-server" "up" "--method" "stdio")))))
