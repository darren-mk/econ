;;; -*- lexical-binding: t; -*-

;; npm install -g typescript-language-server typescript

(defvar eglot-server-programs)

(use-package js
  :hook ((js-mode . eglot-ensure)
         (js-mode . corfu-mode))
  :custom (js-indent-level 2)
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '(js-mode . ("typescript-language-server" "--stdio")))))
