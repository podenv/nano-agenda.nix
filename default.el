(require 'nano)
(require 'nano-agenda)

;; Configure where tasks are written
(setq org-capture-templates
      '(
        ("t" "todo" entry (file+headline "~/org/projects.org" "Inbox")
         "* TODO %?\n/Entered on/ %U\n")
        ))

;; Define a new helper function
(defun tc/org-capture-todo ()
  "Directly capture a todo."
  (interactive)
  (org-capture nil "t"))

;; Press F5 to capture a task (same key as quicksave in KSP)
(define-key global-map (kbd "<f5>") 'tc/org-capture-todo)

;; Keep track of when the task was completed
(setq org-log-done 'time)

;; Tell org-agenda where are the org files
(setq org-agenda-files '("~/org"))
