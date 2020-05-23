;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Randy Ridenour"
      user-mail-address "rlridenour@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Droid Sans Mono Slashed" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-one)
(setq doom-theme 'hc-zenburn)
;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Dropbox/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 tab-width 4                                      ; Set width for tabs
 uniquify-buffer-name-style 'forward)              ; Uniquify buffer names

(setq evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t)                         ; Nobody likes to loose work, I certainly don't

(delete-selection-mode 1)                         ; Replace selection when inserting text
(display-time-mode 1)                             ; Enable time in the mode-line
(display-battery-mode 1)                          ; On laptops it's nice to know how much power you have

;; This asks which buffer to go to when splitting a window. First, go to the window.
(setq evil-vsplit-window-right t
      evil-split-window-below t)

;; Then, pull up ivy

(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (+ivy/switch-buffer))

;; Preview the buffer.

(setq +ivy-buffer-preview t)


;; Set new buffers to org-mode

;; (setq-default major-mode 'org-mode)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;;
(setq default-input-method 'TeX)
(add-hook 'text-mode-hook 'toggle-input-method)
(add-hook 'markdown-mode-hook 'toggle-input-method)
(add-hook 'org-mode-hook 'toggle-input-method)

;;Add custom snippets.
(after! yasnippet
  (setq yas-snippet-dirs (append yas-snippet-dirs
        '("~/.doom.d/snippets"))))



;; Spelling


(setq ispell-program-name "/usr/local/bin/aspell")
(setq ispell-personal-dictionary "/Users/rlridenour/Dropbox/emacs/spelling/.aspell.en.pws")
(setq ispell-silently-savep t)

;; Bookmarks

(load "~/Dropbox/emacs/my-emacs-abbrev")


;; Org Mode

;; Enable ignoring a headline during export.
(require 'ox-extra)
(ox-extras-activate '(ignore-headlines))


(add-hook 'org-mode-hook 'wc-mode)


 (defun flyspell-ignore-tex ()
	(interactive)
	(set (make-variable-buffer-local 'ispell-parser) 'tex))
(add-hook 'org-mode-hook (lambda () (setq ispell-parser 'tex)))
(add-hook 'org-mode-hook 'flyspell-ignore-tex)


;; Use C-c c for Org Capture to ~/Dropbox/notes.org

;;(setq org-default-notes-file (concat org-directory "/notes.org"))
(setq org-capture-templates
	'(("t" "Todo" entry (file+headline "~/Dropbox/org/tasks.org" "Tasks")
	   "* TODO %?\n  %i\n  %a")
	  ("j" "Journal" entry (file+datetree "~/Dropbox/org/journal.org")
	   "* %?\nEntered on %U\n  %i\n  %a")))
(define-key global-map "\C-cc" 'org-capture)

(use-package org-ref
	:after org
	:init
	(setq org-ref-completion-library 'org-ref-ivy-cite
		  org-ref-default-bibliography '("~/Dropbox/bibtex/randybib.bib")))

(use-package deft
:bind ("<f9>" . deft)
:commands (deft)
  :config (setq deft-directory "~/Dropbox/org/notes")
          (setq deft-extensions '("org"))
          (setq deft-default-extension "org")
          (setq deft-org-mode-title-prefix t)
          (setq deft-use-filter-string-for-filename t)
          (setq deft-file-naming-rules
                '((noslash . "-")
                  (nospace . "-")
                  (case-fn . downcase)))
          (setq deft-text-mode 'org-mode))

;;LaTeX
(setq reftex-default-bibliography "~/Dropbox/bibtex/randybib.bib")
(setq org-latex-pdf-process (list "latexmk -shell-escape -f -pdf -quiet -interaction=nonstopmode %f"))
(setq ivy-re-builders-alist
      '((ivy-bibtex . ivy--regex-ignore-order)
        (t . ivy--regex-plus)))

;; (setq bibtex-completion-bibliography
;;       '("~/Dropbox/bibtex/randybib.bib"))



;; Configure AucTeX
;; Configure Biber
;; Allow AucTeX to use biber as well as/instead of bibtex.

  ;; Biber under AUCTeX
  (defun TeX-run-Biber (name command file)
	"Create a process for NAME using COMMAND to format FILE with Biber."
	(let ((process (TeX-run-command name command file)))
	  (setq TeX-sentinel-function 'TeX-Biber-sentinel)
	  (if TeX-process-asynchronous
		  process
		(TeX-synchronous-sentinel name file process))))

  (defun TeX-Biber-sentinel (process name)
	"Cleanup TeX output buffer after running Biber."
	(goto-char (point-max))
	(cond
	 ;; Check whether Biber reports any warnings or errors.
	 ((re-search-backward (concat
						   "^(There \\(?:was\\|were\\) \\([0-9]+\\) "
						   "\\(warnings?\\|error messages?\\))") nil t)
	  ;; Tell the user their number so that she sees whether the
	  ;; situation is getting better or worse.
	  (message (concat "Biber finished with %s %s. "
					   "Type `%s' to display output.")
			   (match-string 1) (match-string 2)
			   (substitute-command-keys
				"\\\\[TeX-recenter-output-buffer]")))
	 (t
	  (message (concat "Biber finished successfully. "
					   "Run LaTeX again to get citations right."))))
	(setq TeX-command-next TeX-command-default))

  (eval-after-load "tex"
	'(add-to-list 'TeX-command-list '("Biber" "biber %s" TeX-run-Biber nil t :help "Run Biber"))
	)

  (defun tex-clean ()
	(interactive)
	(shell-command "latexmk -c"))


  (defun tex-clean-all ()
	(interactive)
	(shell-command "latexmk -C"))

  (defun bibtex-completion-format-citation-orgref (keys)
	"Formatter for org-ref citations."
	(let* ((prenote  (if bibtex-completion-cite-prompt-for-optional-arguments (read-from-minibuffer "Prenote: ") ""))
		   (postnote (if bibtex-completion-cite-prompt-for-optional-arguments (read-from-minibuffer "Postnote: ") "")))
	  (if (and (string= "" prenote) (string= "" postnote))
		  (format "[[%s]]" (s-join "; " (--map (concat "autocite:" it) keys)))
		(format "[[%s][%s::%s]]"  (s-join "; " (--map (concat "autocite:" it) keys)) prenote postnote))))

(use-package ivy-bibtex
	;; :bind ("s-4" . ivy-bibtex)
	:after (ivy)
	:config
	(setq bibtex-completion-bibliography '("~/Dropbox/bibtex/randybib.bib"))
	(setq reftex-default-bibliography '("~/Dropbox/bibtex/randybib.bib"))
	(setq bibtex-completion-pdf-field "File")
	(setq ivy-bibtex-default-action 'ivy-bibtex-insert-citation)
	(setq bibtex-completion-format-citation-functions
		  '((org-mode      . bibtex-completion-format-citation-orgref)
			(latex-mode    . bibtex-completion-format-citation-cite)
			;; (markdown-mode    . bibtex-completion-format-citation-cite)
			(markdown-mode . bibtex-completion-format-citation-pandoc-citeproc)
			(default       . bibtex-completion-format-citation-default))))
