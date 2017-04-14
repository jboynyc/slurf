(module ostatus
         [get-user-feed]

(import scheme
        chicken
        data-structures
        srfi-1
        srfi-13)
(use atom
     http-client
     uri-common
     ssax
     txpath
     irregex
     medea)

(define (parse-xml)
  (ssax:xml->sxml
    (current-input-port)
    '()))

(define (handle-to-acct-uri handle)
  (string-append "acct:" handle))

(define (insert-resource-into-template uri resource)
  (irregex-replace "{.*}" uri (uri-encode-string resource)))

(define (get-host-meta host)
  ;; Returns web host metadata (rfc6415).
  (let [[uri (make-uri #:scheme 'https
                       #:host host
                       #:path '(/ ".well-known" "host-meta") )]]
    (with-input-from-request
      uri
      #f
      parse-xml)))

(define (get-lrdd meta)
  ;; Returns WebFinger endpoint from host metadata.
  (car ((txpath "//x:XRD/x:Link[@rel='lrdd'][1]/@template/text()"
                '((x . "http://docs.oasis-open.org/ns/xri/xrd-1.0")))
        meta)))

(define (host-from-handle handle)
  (let [[split-string (string-split handle "@")]]
    (cadr split-string)))

(define (webfinger uri)
  (with-input-from-request
    uri
    #f 
    read-json))

(define (get-atom-uri webfinger-data)
  (let [[links (vector->list (alist-ref 'links webfinger-data))]]
    (alist-ref 'href
               (car (filter (lambda [e] (equal? (alist-ref 'rel e) "http://schemas.google.com/g/2010#updates-from")) links)))))

(define (fetch-atom-feed uri)
  (with-input-from-request
    uri
    #f
    (lambda [] (read-atom-feed (current-input-port)))))

(define (get-user-feed given-handle)
  (let* [[handle (string-trim-both given-handle)]
         [host (host-from-handle handle)]
         [resource (handle-to-acct-uri handle)]
         [host-meta (get-host-meta host)]
         [webfinger-uri (get-lrdd host-meta)]
         [webfinger-endpoint (insert-resource-into-template webfinger-uri resource)]
         [webfinger-data (webfinger webfinger-endpoint)]
         [atom-uri (get-atom-uri webfinger-data)]]
    (fetch-atom-feed atom-uri)))
)
