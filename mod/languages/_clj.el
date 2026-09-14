;;; -*- lexical-binding: t; -*-

;; brew install --cask temurin@21
;; brew install clojure/tools/clojure
;; brew install clojure-lsp
;; brew install borkdude/brew/babashka

(defvar my-clj-project-files
  '("deps.edn" "project.clj" "bb.edn" "shadow-cljs.edn")
  "Build files that mark the root of a Clojure/Babashka project.")

(defun my-clj-project-root (&optional dir)
  "Return the Clojure project root above DIR, or nil."
  (let ((dir (or dir default-directory)))
    (seq-some (lambda (f) (locate-dominating-file dir f))
              my-clj-project-files)))

(defun my-project-find-clj-root (dir)
  (when-let ((root (my-clj-project-root dir)))
    (cons 'transient root)))

(add-to-list 'project-find-functions #'my-project-find-clj-root)

;; clojure-lsp needs a project to index; a lone `foo.bb' script has none,
;; so skip lsp there instead of being prompted for a root every time.
(defun my-clj-lsp-maybe ()
  (when (my-clj-project-root)
    (lsp-deferred)))

(use-package lsp-mode
  :ensure t
  :hook ((clojure-mode       . my-clj-lsp-maybe)
         (clojurescript-mode . my-clj-lsp-maybe)
         (clojurec-mode      . my-clj-lsp-maybe))
  :custom
  (lsp-headerline-breadcrumb-enable t)
  (lsp-lens-enable t)
  :commands (lsp lsp-deferred))

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-sideline-enable t))

(declare-function lsp-format-buffer "lsp-mode")
(declare-function lsp-workspaces "lsp-mode")

(use-package clojure-mode
  :ensure t
  :mode (("\\.edn\\'"   . clojure-mode)
         ("\\.clj\\'"   . clojure-mode)
         ("\\.bb\\'"    . clojure-mode)
         ("\\.cljc\\'"  . clojurec-mode)
         ("\\.cljs\\'"  . clojurescript-mode))
  :interpreter ("bb" . clojure-mode)
  :hook ((clojure-mode       . paredit-mode)
         (clojurescript-mode . paredit-mode)
         (clojurec-mode      . paredit-mode)
         (clojure-mode       . corfu-mode)
         (clojurescript-mode . corfu-mode)
         (clojurec-mode      . corfu-mode)
         (clojure-mode       . my-clj-format-on-save)
         (clojurescript-mode . my-clj-format-on-save)
         (clojurec-mode      . my-clj-format-on-save))
  :init
  (defun my-clj-format-on-save ()
    (add-hook 'before-save-hook #'my-clj-format-buffer nil t))
  (defun my-clj-format-buffer ()
    (when (and (fboundp 'lsp-workspaces) (lsp-workspaces))
      (lsp-format-buffer)))
  :config
  (define-key paredit-mode-map (kbd "M-?") nil))

(use-package cider
  :ensure t
  :after clojure-mode
  :hook ((clojure-mode . cider-mode)
         (cider-repl-mode . paredit-mode))
  :custom
  (cider-save-file-on-load t)
  (cider-repl-display-help-banner nil)
  (cider-babashka-command "bb")
  (cider-babashka-parameters "nrepl-server localhost:0")
  :config
  ;; `cider-jack-in' picks babashka automatically when bb.edn is present.
  ;; This is for standalone scripts that have no bb.edn next to them.
  (defun my-cider-jack-in-babashka ()
    "Start a Babashka nREPL server and connect, project or not."
    (interactive)
    (let ((cider-allow-jack-in-without-project t))
      (cider-jack-in-clj '(:project-type babashka))))
  (define-key clojure-mode-map (kbd "C-c M-b") #'my-cider-jack-in-babashka))
