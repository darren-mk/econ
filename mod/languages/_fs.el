;;; -*- lexical-binding: t; -*-

;; Fedora:
;; dnf install dotnet-sdk-8.0
;; dotnet tool install -g fsautocomplete
;; dotnet tool install -g fantomas
;; export PATH="$HOME/.dotnet/tools:$PATH"

;; macOS:
;; brew install --cask dotnet-sdk
;; dotnet tool install -g fantomas

;; Suppress byte-compiler warnings for variables defined in other packages
(defvar eglot-server-programs)
(defvar fsharp-interactive-command)
(defvar savehist-additional-variables)

(add-to-list
 'exec-path
 (expand-file-name "~/.dotnet/tools"))

(setenv "PATH"
        (concat (expand-file-name "~/.dotnet/tools:")
                (getenv "PATH")))

(with-eval-after-load 'eglot
  (setf (alist-get 'fsharp-mode eglot-server-programs)
        (list (expand-file-name "~/.dotnet/tools/fsautocomplete"))))

(defun set-indentation ()
  (setq-local
   tab-width 4
   indent-tabs-mode nil
   fsharp-indent-offset 4))

(defun insert-fact-attr ()
  "insert [<Fact>] at point"
  (interactive) (insert "[<Fact>]"))

(use-package fsharp-mode
  :ensure t
  :mode (("\\.fs[iylx]?\\'" . fsharp-mode))
  :hook ((fsharp-mode . set-indentation)
         (fsharp-mode . eglot-ensure))
  :config (setq fsharp-interactive-command "dotnet fsi")
  :bind (:map fsharp-mode-map ("C-c f" . insert-fact-attr)))

(use-package eglot-fsharp
  :ensure t
  :after (fsharp-mode eglot)
  :init
  ;; If fsautocomplete isn't on PATH, set it explicitly:
  ;; (setenv "PATH" (concat (expand-file-name "~/.dotnet/tools:") (getenv "PATH")))
  ;; (add-to-list 'exec-path (expand-file-name "~/.dotnet/tools"))
  :config
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider))
  ;; Analyzers and Linter add significant overhead — disable until needed
  (setq eglot-workspace-configuration
        '(:FSharp
          (:AutomaticWorkspaceInit t
           :EnableAnalyzers :json-false
           :KeywordsAutocomplete true
           :Linter (:Enabled :json-false)))))

(defun dk/fantomas-format-buffer ()
  "Format current buffer with fantomas asynchronously.
Runs fantomas on a temp file to respect fantomas-config.json in project root."
  (interactive)
  (let* ((buf (current-buffer))
         (fname (buffer-file-name))
         (tmp (make-temp-file "fantomas-" nil (and fname (file-name-extension fname t))))
         (tick (buffer-modified-tick buf)))
    (write-region (point-min) (point-max) tmp nil 'silent)
    (make-process
     :name "fantomas"
     :command (list "fantomas" tmp)
     :noquery t
     :sentinel
     (lambda (proc _event)
       (when (eq (process-status proc) 'exit)
         (if (zerop (process-exit-status proc))
             (when (buffer-live-p buf)
               (with-current-buffer buf
                 (when (= tick (buffer-modified-tick buf))
                   (let ((pos (point)))
                     (replace-buffer-contents
                      (find-file-noselect tmp t))
                     (goto-char pos)))))
           (message "fantomas: formatting failed (exit %d)" (process-exit-status proc)))
         (ignore-errors (delete-file tmp)))))))

(use-package corfu
  :ensure t
  :init (global-corfu-mode)
  :config
  (setq corfu-min-width 25
        corfu-max-width 100
        corfu-count 20
        corfu-auto t
        corfu-cycle t
        corfu-separator ?\s
        corfu-preview-current t
        corfu-scroll-margin 4
        tab-always-indent 'complete)
  (corfu-popupinfo-mode 1)
  (corfu-history-mode 1)
  (with-eval-after-load 'savehist
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after (marginalia)
  :config
  (nerd-icons-completion-marginalia-setup)
  (nerd-icons-completion-mode 1))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config (add-to-list
           'corfu-margin-formatters
           #'nerd-icons-corfu-formatter))

(use-package orderless
  :ensure t
  :init (setq completion-styles '(orderless basic)
              completion-category-defaults nil
              completion-category-overrides '((file (styles basic partial-completion)))))

;;; --- Minimal dotnet test helpers for F#/xUnit/Expecto ----------------------

(require 'project) ;; built-in

(defun dk--project-root ()
  (or (when-let* ((pr (project-current)))
        (project-root pr))
      (locate-dominating-file default-directory ".git")
      default-directory))

(defun dk--nearest-fsproj ()
  "Find the nearest *.fsproj by walking up."
  (let* ((root (dk--project-root))
         (dir  default-directory)
         (done nil)
         match)
    (while (and (not done) dir (file-in-directory-p dir root))
      (setq match (car (directory-files dir t ".*\\.fsproj\\'")))
      (if match
          (setq done t)
        (setq dir (let ((p (directory-file-name (file-name-directory dir))))
                    (unless (equal p dir) p)))))
    (or match
        ;; fallback: any fsproj in project root
        (car (directory-files (or root default-directory) t ".*\\.fsproj\\'"))
        (user-error "No .fsproj found"))))

(defun dk/dotnet-test-all ()
  "Run all tests in the current project (solution-aware)."
  (interactive)
  (let* ((default-directory (dk--project-root)))
    (compile "dotnet test -v minimal")))

(defun dk/dotnet-test-project ()
  "Run tests for the nearest .fsproj only."
  (interactive)
  (let* ((proj (dk--nearest-fsproj))
         (cmd  (format "dotnet test -v minimal %s" (shell-quote-argument proj))))
    (compile cmd)))

(defun dk--xunit-name-at-point ()
  "Best-effort grab the xUnit test name at point (F#).
   Looks for `[<Fact>]`/`[<Theory>]` above and returns the `let name`."
  (save-excursion
    (let ((case-fold-search t)
          name)
      (when (re-search-backward "\\[<\\(Fact\\|Theory\\)[^>]*>\\]" nil t)
        (when (re-search-forward "^[ \t]*let[ \t]+\\([^ \t(=]+\\)" nil t)
          (setq name (match-string 1))))
      name)))

(defun dk/dotnet-test-at-point ()
  "Run only the test at point (xUnit/F#).
Uses xUnit filter on DisplayName (works well when function name is unique)."
  (interactive)
  (let* ((proj (dk--nearest-fsproj))
         (name (dk--xunit-name-at-point)))
    (unless name
      (user-error "Could not determine test name at point (need [<Fact>] or [<Theory>] above a `let name`)"))
    (let ((cmd (format "dotnet test %s --filter \"DisplayName~%s\" -v minimal"
                       (shell-quote-argument proj)
                       name)))
      (compile cmd))))

(defun dk/dotnet-test-watch ()
  "Auto-rerun tests on file changes."
  (interactive)
  (let* ((proj (dk--nearest-fsproj))
         (cmd  (format "dotnet watch --project %s test -v minimal"
                       (shell-quote-argument proj))))
    (compile cmd)))

;; Handy keybindings (change to taste)
(with-eval-after-load 'fsharp-mode
  (define-key fsharp-mode-map (kbd "C-c t a") #'dk/dotnet-test-all)
  (define-key fsharp-mode-map (kbd "C-c t p") #'dk/dotnet-test-project)
  (define-key fsharp-mode-map (kbd "C-c c") #'dk/dotnet-test-at-point)
  (define-key fsharp-mode-map (kbd "C-c t w") #'dk/dotnet-test-watch))
