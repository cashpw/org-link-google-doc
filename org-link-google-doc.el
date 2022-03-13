;;; org-link-google-doc.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Cash Weaver
;;
;; Author: Cash Weaver <cashbweaver@gmail.com>
;; Maintainer: Cash Weaver <cashbweaver@gmail.com>
;; Created: March 13, 2022
;; Modified: March 13, 2022
;; Version: 0.0.1
;; Homepage: https://github.com/cashweaver/org-link-google-doc
;; Package-Requires: ((emacs "27.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  This library provides an google-doc link in org-mode.
;;
;;; Code:

(require 'ol)
(require 's)

(defcustom org-link-google-doc-url-base
  "https://docs.google.com/document/d"
  "The URL of Google-Doc."
  :group 'org-link-follow
  :type 'string
  :safe #'stringp)

(defun org-link-google-doc--build-uri (google-doc-id)
  "Return a uri for the provided PATH."
  (url-encode-url
   (s-format
    "${base-url}/${google-doc-id}"
    'aget
    `(("base-url" . ,org-link-google-doc-url-base)
      ("google-doc-id" . ,google-doc-id)))))

(defun org-link-google-doc-open (google-doc-id arg)
  "Opens an google-doc type link."
  (let ((uri
         (org-link-google-doc--build-uri
          google-doc-id)))
    (browse-url
     uri
     arg)))

(defun org-link-google-doc-export (google-doc-id desc backend info)
  "Export an google-doc link.

- GOOGLE-DOC-ID: the id of the document.
- DESC: the description of the link, or nil.
- BACKEND: a symbol representing the backend used for export.
- INFO: a a plist containing the export parameters."
  (let ((uri
         (org-link-google-doc--build-uri
          google-doc-id)))
    (pcase backend
      (`md
       (format "[%s](%s)" (or desc uri) uri))
      (`html
       (format "<a href=\"%s\">%s</a>" uri (or desc uri)))
      (`latex
       (if desc (format "\\href{%s}{%s}" uri desc)
         (format "\\url{%s}" uri)))
      (`ascii
       (if (not desc) (format "<%s>" uri)
         (concat (format "[%s]" desc)
                 (and (not (plist-get info :ascii-links-to-notes))
                      (format " (<%s>)" uri)))))
      (`texinfo
       (if (not desc) (format "@uref{%s}" uri)
         (format "@uref{%s, %s}" uri desc)))
      (_ uri))))

(org-link-set-parameters
 "google-doc"
 :follow #'org-link-google-doc-open
 :export #'org-link-google-doc-export)


(provide 'org-link-google-doc)
;;; org-link-google-doc.el ends here
