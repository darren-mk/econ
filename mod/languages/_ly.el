;;; -*- lexical-binding: t; -*-

;; brew install lilypond

;; LilyPond mode
(add-to-list 'load-path "/opt/homebrew/share/emacs/site-lisp/lilypond/")
(autoload 'lilypond-mode "lilypond-mode" "LilyPond Editing Mode" t)
(add-to-list 'auto-mode-alist '("\\.ly\\'" . lilypond-mode))
(add-hook 'lilypond-mode-hook (lambda () (turn-on-font-lock)))

;; auto compilation at save
(add-hook 'lilypond-mode-hook
          (lambda ()
            (add-hook 'after-save-hook
                      (lambda ()
                        (when (eq major-mode 'lilypond-mode)
                          (lilypond-command-lilypond)))
                      nil t)))
