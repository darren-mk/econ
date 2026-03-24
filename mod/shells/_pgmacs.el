;;; -*- lexical-binding: t; -*-

(use-package pg
  :vc (:url "https://github.com/emarsden/pg-el/"))

(use-package pgmacs
  :vc (:url "https://github.com/emarsden/pgmacs/")
  :commands (pgmacs-open-string pgmacs-open)
  :custom (pgmacs-row-limit 200))
