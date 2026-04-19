;;; -*- lexical-binding: t; -*-

;; brew install --cask temurin@21
;; brew install clojure/tools/clojure
;; brew install clojure-lsp

(defvar eglot-server-programs)

(defun my-project-find-clj-root (dir)
  (when-let ((root (or (locate-dominating-file dir "deps.edn")
                       (locate-dominating-file dir "project.clj"))))
    (cons 'transient root)))

(add-to-list 'project-find-functions #'my-project-find-clj-root)

(declare-function eglot-format-buffer "eglot")

(use-package clojure-mode
  :ensure t
  :mode (("\\.edn\\'"   . clojure-mode)
         ("\\.clj\\'"   . clojure-mode)
         ("\\.cljc\\'"  . clojurec-mode)
         ("\\.cljs\\'"  . clojurescript-mode))
  :hook ((clojure-mode       . paredit-mode)
         (clojurescript-mode . paredit-mode)
         (clojurec-mode      . paredit-mode)
         (clojure-mode       . eglot-ensure)
         (clojurescript-mode . eglot-ensure)
         (clojurec-mode      . eglot-ensure)
         (clojure-mode       . corfu-mode)
         (clojurescript-mode . corfu-mode)
         (clojurec-mode      . corfu-mode)
         (clojure-mode       . my-clj-format-on-save)
         (clojurescript-mode . my-clj-format-on-save)
         (clojurec-mode      . my-clj-format-on-save))
  :init
  (defun my-clj-format-on-save ()
    (add-hook 'before-save-hook #'eglot-format-buffer nil t))
  :config
  (define-key paredit-mode-map (kbd "M-?") nil)
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((clojure-mode clojurescript-mode clojurec-mode)
		   . ("clojure-lsp")))))

(use-package cider
  :ensure t
  :after clojure-mode
  :hook ((clojure-mode . cider-mode)
         (cider-repl-mode . paredit-mode))
  :custom
  (cider-save-file-on-load t)
  (cider-repl-display-help-banner nil))
