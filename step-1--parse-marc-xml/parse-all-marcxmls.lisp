#!/usr/local/bin/lispscript

(use-xml-namespace  "http://www.loc.gov/MARC21/slim")

(load "xwalks.lisp")


(defmacro with-get-all (someval listofunctions &body body)
  (let ((dalist (mapcar (lambda (x) `(,x (,x ,someval))) listofunctions)))
    `(let ,dalist
       (let ((everything! (list ,@listofunctions)))
         ,@body))))


(defmacro defmarcxmlfield (thename theplain thegame &rest therest)
  (with-gensyms (tmp cc tmp2)
    `(let ((,cc (xpath-compile ,theplain)))
       (defun ,thename (adoc)
         (let ((it!
                 « (xpath adoc ,cc ,@therest :all nil :text t :compiled-p t)
                      or do (return-from ,thename nil) »))
           #? ,thegame)))))

; --------------------------------------------------------------- ;

(defmarcxmlfield leader             "leader" it!)
(defmarcxmlfield oh08       		    "controlfield[@tag='008']" it!)
(defmarcxmlfield oh09       		    "controlfield[@tag='009']" it!)
(defmarcxmlfield barcode    		    "datafield[@tag='876']/subfield[@code='p']" it!)
(defmarcxmlfield title      		    "datafield[@tag='245']/subfield[@code='a']" it!)
(defmarcxmlfield scsbid     		    "controlfield[@tag='001']" it!)
(defmarcxmlfield author     		    "datafield[@tag='100']/subfield[@code='a']" it!)
(defmarcxmlfield lccall1    		    "datafield[@tag='050']/subfield[@code='a']" it!)
(defmarcxmlfield lccall2    		    "datafield[@tag='090']/subfield[@code='a']" it!)
(defmarcxmlfield localcallnum       "datafield[@tag='852']/subfield[@code='h']" it!)
(defmarcxmlfield sharedp            "datafield[@tag='876']/subfield[@code='x']" it!)


(defmarcxmlfield dateoflastxaction
  "controlfield[@tag='005']"
  (let ((yr (subseq it! 0 4))
        (mn (subseq it! 4 6))
        (dy (subseq it! 6 8)))
    (delim (list yr mn dy) :sep #\-)))

(defmarcxmlfield lccn
  "datafield[@tag='010']/subfield[@code='a']"
  (parse-integer (~ra it! •\D• "")))

(defmarcxmlfield isbn
  "datafield[@tag='020']/subfield[@code='a']"
  (-<> it!
       (mapcar (lambda (x) (~ra x •^(\d+[Xx]?).*$• •\1•)) <>)
       (remove-duplicates <> :test #'equalp)
       (delim <> :sep #\;))
  :text t :all t)

(defmarcxmlfield issn
  "datafield[@tag='022']/subfield[@code='a']"
  (-<> it!
       (mapcar (lambda (x) (~ra x •^(\d+[Xx]?).*$• •\1•)) <>)
       (remove-duplicates <> :test #'equalp)
       (delim <> :sep #\;))
  :text t :all t)

(defmarcxmlfield oclc
  "datafield[@tag='035']/subfield[@code='a']"
  (let ((res (remove-if-not (lambda (x) (~m x •^.OCoLC.•)) it!)))
    (when res (-<> res
                   (mapcar (lambda (x) (~r x •^\D+• "")) <>)
                   (remove-if-not (lambda (x) (~m x •^\d+$•)) <>)
                   (mapcar #'parse-integer <>)
                   (remove-duplicates <> :test #'eql)
                   (delim <> :sep #\;))))
  :text t :all t)

(defun lccall (something) (aif (lccall1 something) it! (lccall2 something)))

(defmarcxmlfield pubsubplace
  "datafield[@tag='260']/subfield[@code='a']"
  (-<> it!
       (mapcar (lambda (x) (~ra x •\s*[,:\.\]]+\s*$• "")) <>)
       (mapcar (lambda (x) (~ra x •^\[• "")) <>)
       (delim <> :sep #\;))
  :text t :all t)

(defmarcxmlfield topicalterms
  "datafield[@tag='650']/subfield[@code='a']"
  (delim (remove-duplicates it! :test #'equal) :sep #\;)
  :all t :text t)

;;; repeated :(
(defmarcxmlfield language
  "controlfield[@tag='008']"
  (subseq it! 35 38))

(defmarcxmlfield pubdate
  "controlfield[@tag='008']"
  (parse-integer (subseq it! 7 11)))

(defmarcxmlfield recordtype
  "leader"
  (-<> (subseq it! 6 7)
       (string-upcase <>)
       (find-symbol <>)
       {+record-type-xwalk+ <>}))

(defmarcxmlfield biblevel
  "leader"
  (-<> (subseq it! 7 8)
       (string-upcase <>)
       (find-symbol <>)
       {+bib-level-xwalk+ <>}))

(defmarcxmlfield pubplace
  "controlfield[@tag='008']"
  (subseq it! 15 18))


; --------------------------------------------------------------- ;


« (defvar /thedir/ Ø (cadr (cmdargs)))
    or die "no directory of xml files given" »

(defvar /allfiles/ (zsh (fn "find ~A -maxdepth 1 -type f | ack xml" /thedir/) :split t))
(defvar /intotal/ (length /allfiles/))


(defparameter /doc/ nil)


(defun get-item-info (node)
  (let ((barcodes (xpath node "datafield[@tag='876']/subfield[@code='p']" :all t :text t))
        (vol      (xpath node "datafield[@tag='876']/subfield[@code='3']" :all t :text t)))
    (if (not (= (length barcodes) (length vol)))
      (loop for i in barcodes collect (list i NIL))
      (loop for i in barcodes
            for j in vol
            collect (list i (if (string= j "") NIL j))))))



(ft "~A~%" (delim (list "barcode" "vol" "numitems" "scsbid" "sharedp"
                        "language" "pubdate" "biblevel" "recordtype"
                        "oclc" "lccn" "isbn" "issn" "lccall" "localcallnum"
                        "oh09" "pubplace" "pubsubplace" "leader" "oh08"
                        "dateoflastxaction" "title" "author"
                        "topicalterms")))



(for-each/list /allfiles/
  (progress index! /intotal/)
  (info "parsing file ~A~%" value!)
  (with-time
    (setq /doc/ (xml-parse-file value!))
    (info "parsing took ~A~%" (time-for-humans time!)))
  (with-time
    (for-each/list (xpath /doc/ "/collection/record")
      ; (when (> index! 30) (die "limit reached"))
      (let ((item-info (get-item-info value!)))
        (with-get-all value!
          (scsbid sharedp language pubdate biblevel recordtype oclc lccn
           isbn issn lccall localcallnum oh09 pubplace pubsubplace leader
           oh08 dateoflastxaction title author topicalterms)
          (for-each/list item-info
            (ft "~A~C~A~C~A~C" (car value!) #\Tab (cadr value!) #\Tab
                               (length item-info) #\Tab)
            (ft "~A~%" (delim everything!))
            ))))
      (info "finished conversion in ~A~%~%" (time-for-humans time!)))
    (gc :full t))


