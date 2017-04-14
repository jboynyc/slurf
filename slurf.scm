(use ostatus
     atom
     html-parser)

(define (format-entry date title link content)
  (format "[~A: ~A] ~A\n~A\n" date title link content))

(define (text-links links)
  (map link-uri (map car (map (lambda [a] (filter (lambda [link] (equal? (link-type link) "text/html")) a)) links))))

(define (main input)
  (let* [[given-handle (car input)]
         [atom-feed (get-user-feed given-handle)]
         [entries (reverse (feed-entries atom-feed))]
         [contents (map (lambda [i] (if i (content-text i) ""))
                        (map entry-content entries))]
         [plain-contents (map html-strip contents)]
         [titles (map title-text (map entry-title entries))]
         [dates (map entry-published entries)]
         [uris (text-links (map entry-links entries))]]
    (map print
         (map (lambda [i] (apply format-entry i))
              (map list dates titles uris plain-contents)))))

(cond-expand
  ((and chicken compiling)
   (main (command-line-arguments)))
  (else #f))
