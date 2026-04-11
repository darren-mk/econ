;;; -*- lexical-binding: t; -*-

(use-package haskell-mode
  :defer t :ensure t
  :hook ((haskell-mode . eglot-ensure)
         (haskell-mode . interactive-haskell-mode))
  :bind (:map haskell-mode-map
              ("C-c C-c" . haskell-compile))
  :custom
  (haskell-process-suggest-remove-import-lines t)
  (haskell-process-auto-import-loaded-modules t)
  (haskell-process-log t)
  (haskell-process-type 'cabal-repl))
