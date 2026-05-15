;;; -*- lexical-binding: t; -*-

;; npm install -g typescript-language-server typescript

(defvar eglot-server-programs)

(dolist (grammar '((javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
                   (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript"
                                  nil "typescript/src"))
                   (tsx . ("https://github.com/tree-sitter/tree-sitter-typescript"
                           nil "tsx/src"))))
  (add-to-list 'treesit-language-source-alist grammar)
  (unless (treesit-language-available-p (car grammar))
    (treesit-install-language-grammar (car grammar))))

(add-to-list 'major-mode-remap-alist '(js-mode . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js-ts-mode))

(add-hook 'js-ts-mode-hook #'eglot-ensure)
(add-hook 'js-ts-mode-hook #'corfu-mode)
(setq js-indent-level 2)

(use-package typescript-ts-mode
  :mode ("\\.ts\\'" "\\.tsx\\'")
  :hook ((typescript-ts-mode . eglot-ensure)
         (typescript-ts-mode . corfu-mode)
         (tsx-ts-mode . eglot-ensure)
         (tsx-ts-mode . corfu-mode))
  :custom (typescript-ts-mode-indent-offset 2)
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((js-ts-mode typescript-ts-mode tsx-ts-mode)
		   . ("typescript-language-server" "--stdio")))))
