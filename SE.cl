(defparameter *questions* '(
    (Q1 "Quelle apparence de biere preferez-vous ? (0 : blonde, 1 : brune, 2 : ambree, 3 : rouge, 4 : orange)" COULEUR ((0 blonde)(1 brune)(2 ambree)(3 rouge)(4 orange)))
    (Q2 "Quel degre d'alcool voulez-vous ? (entrez un nombre entre 0 et 12)" DEGRE)
    (Q3 "Quelle amertume voulez-vous dans votre biere ? (0 : moyenne, 1 : forte)" AMERTUME ((0 moyenne)(1 forte)))
    (Q4 "Preferez-vous une biere servie en bouteille (0) ou en pression (1) ?" SERVIE ((0 bouteille)(1 pression)))
    (Q5 "Preferez-vous une biere speciale (0) ou une biere d'abbaye (1) ?" TYPE ((0 speciale)(1 abbaye)))
    (Q6 "Quel est le prix ideal de cette biere pour vous ? (entrez un nombre entre 0.5 et 3)" PRIX)
    (Q7 "Preferez-vous un arome d'agrumes (0) ou d'epices (1) dans votre biere?" AROME ((0 agrumes)(1 epices)))
    (Q8 "Preferez-vous une biere canadienne (0) ou americaine (1)" REGION ((0 canada)(1 usa)))
    (Q9 "Preferez-vous une biere anglaise (0) ou belge (1)" REGION ((0 gb)(1 belgique)))
    (Q10 "Preferez-vous un arome de fruits blancs (0), d'agrumes (1) ou de caramel (2) dans votre biere?" AROME ((0 fruit_blanc)(1 agrumes)(2 caramel)))
    (Q11 "Preferez-vous un arome de cerise (0) ou de peche (1) dans votre biere?" AROME ((0 cerise)(1 peche)))
))

(defparameter *bdf* NIL)

(defun getQuestion (premisseConnu varInconnue)
    (cond
        ((and (eq varInconnue 'REGION) (equal premisseConnu '(eq FAMILLE ipa))) (return-from getQuestion (nth 7 *questions*)))
        ((and (eq varInconnue 'REGION) (equal premisseConnu '(eq STYLE light_strong_ale))) (return-from getQuestion (nth 8 *questions*)))
        ((and (eq varInconnue 'AROME) (equal premisseConnu '(eq FAMILLE wheat_beer))) (return-from getQuestion (nth 9 *questions*)))
        ((and (eq varInconnue 'AROME) (equal premisseConnu '(eq STYLE fruit_beer))) (return-from getQuestion (nth 10 *questions*)))
        (T (dolist (q *questions*)
            (if (eq (getVariable q) varInconnue) (return-from getQuestion q))
        ))
    )
)

(defun getVariable (qst)
    (nth 2 qst)
)

(defun responsePossible (question)
    (nth 3 question)
)

(defun getPremisses (rule)
    (car rule)
)

(defun getConclusion (rule)
    (cadr rule)
)

(defun askQuestion (premisseConnu premisseInconnu)
    (let ((varInconnue) (question) (response NIL) (rPossible))
        (if   (and (null premisseConnu) (null premisseInconnu)) (setq varinconnue 'COULEUR) (setq varinconnue (cadr premisseinconnu)))
        (setq question (getquestion premisseconnu varinconnue))
        (setq rPossible (responsepossible question))
        (format t "~%~S~%> " (cadr question))
        (clear-input)
        (setq response (read))
        (format T "~d~%" response)
        (clear-input)
        (cond 
            ((eq varinconnue 'DEGRE)
                (if (or (< response 0) (> response 12)) (return-from askQuestion (askquestion premisseconnu premisseinconnu)))
                (push (list varinconnue response) *bdf*)
            )
            ((eq varinconnue 'PRIX)
                (if (or (< response 0.5) (> response 3)) (return-from askQuestion (askquestion premisseconnu premisseinconnu)))
                (push (list varinconnue response) *bdf*)
            )
            (T
                (if (or (< response 0) (>= response (length rpossible))) (return-from askQuestion (askquestion premisseconnu premisseinconnu)))
                (push (list varinconnue (cadr (nth response rpossible))) *bdf*)
            )
        )
    )
)

(defun trueRule (but)
;; renvoie T si but par exemple (eq COULEUR blonde) est vrai dans *bdf*
    (let ((value (cadr (assoc (cadr but) *bdf*))))
        (if value (funcall (car but) value (caddr but)) NIL)
    )
)

(defparameter *rulesbase* '(
    (((eq COULEUR blonde)(> DEGRE 5))(eq FAMILLE blonde))
    (((eq COULEUR blonde)(<= DEGRE 5))(eq FAMILLE wheat_beer))
    (((eq COULEUR ambree))(eq FAMILLE ipa))
    (((eq COULEUR brune)(<= DEGRE 8))(eq FAMILLE dubel))
    (((eq COULEUR brune)(> DEGRE 8))(eq FAMILLE strong_ale))

    (((eq FAMILLE ipa)(eq REGION canada))(eq STYLE canadian_ipa))
    (((eq FAMILLE ipa)(eq REGION usa))(eq STYLE american_ipa))
    (((eq STYLE canadian_ipa))(eq BEER "Castor"))
    (((eq STYLE american_ipa))(eq BEER "Lagunitas"))

    (((eq FAMILLE wheat_beer)(eq AROME fruit_blanc))(eq BEER "Baptist blanche"))
    (((eq FAMILLE wheat_beer)(eq AROME agrumes))(eq BEER "Azimuth"))
    (((eq FAMILLE wheat_beer)(eq AROME caramel))(eq BEER "Paillette"))

    (((eq FAMILLE dubel)(eq AMERTUME moyenne))(eq BEER "Chimay rouge"))
    (((eq FAMILLE dubel)(eq AMERTUME forte))(eq BEER "St Feuillien brune"))

    (((eq FAMILLE blonde)(< DEGRE 9))(eq STYLE pale_ale))
    (((eq FAMILLE blonde)(>= DEGRE 9))(eq STYLE tripel))
    (((eq STYLE pale_ale)(eq SERVIE pression))(eq TYPE pale_ale_pression))
    (((eq STYLE pale_ale)(eq SERVIE bouteille))(eq TYPE pale_ale_bouteille))
    (((eq TYPE pale_ale_pression)(eq AROME agrumes))(eq BEER "Cuvee des trolls"))
    (((eq TYPE pale_ale_pression)(eq AROME epices))(eq BEER "Delirium Tremens"))
    (((eq TYPE pale_ale_bouteille)(eq AROME agrumes))(eq BEER "Chouffe"))
    (((eq TYPE pale_ale_bouteille)(eq AROME epices))(eq BEER "Duvel"))
    (((eq STYLE tripel)(eq TYPE speciale))(eq STYLE2 special_tripel))
    (((eq STYLE tripel)(eq TYPE abbaye))(eq BEER "Val dieu"))
    (((eq STYLE2 special_tripel)(< PRIX 1.7))(eq BEER "Queue de charrue"))
    (((eq STYLE2 special_tripel)(>= PRIX 1.7)(eq AROME epices))(eq BEER "Carolus Tripel"))
    (((eq STYLE2 special_tripel)(>= PRIX 1.7)(eq AROME agrumes))(eq BEER "Tripel Karmeliet"))

    (((eq FAMILLE strong_ale)(eq AMERTUME forte))(eq STYLE dark_strong_ale))
    (((eq FAMILLE strong_ale)(eq AMERTUME moyenne))(eq STYLE light_strong_ale))
    (((eq STYLE dark_strong_ale)(< PRIX 2))(eq BEER "Chimay bleue"))
    (((eq STYLE dark_strong_ale)(>= PRIX 2))(eq BEER "Gulden Draak"))
    (((eq STYLE light_strong_ale)(eq REGION gb))(eq BEER "Barbar"))
    (((eq STYLE light_strong_ale)(eq REGION belgique))(eq BEER "Kwak"))

    (((eq COULEUR rouge))(eq STYLE fruit_beer))
    (((eq COULEUR orange))(eq STYLE fruit_beer))
    (((eq STYLE fruit_beer)(eq AROME cerise))(eq BEER "Kasteel rouge"))
    (((eq STYLE fruit_beer)(eq AROME peche))(eq BEER "Peche mel Bush"))
))


(defun affichagebeer ()
    (let ((beer (cadr (assoc 'BEER *bdf*))))
        (format t "~%La bi??re la plus adapt??e pour vous au pic est la ~S" beer)
    )
)

(defun chainageAvant ()
    (if (NULL *bdf*) (progn (askQuestion NIL NIL) (setq new_fact 1)))
    (loop while (= new_fact 1) do
        (setq new_fact 0)
        (dolist (rule *rulesbase*)
            (setq applicable 1)
            (dolist (premisse (getPremisses rule))
                (if (not (trueRule premisse))
                    (setq applicable 0)
                )
            )
            (if (and (= applicable 1) (not (trueRule (getConclusion rule)))) 
                (progn (push (cdr (getConclusion rule)) *bdf*) (setq new_fact 1)))
        )
    )
    (if (assoc 'BEER *bdf*)
        (progn (affichagebeer) (return-from chainageAvant))
    )
    (dolist (rule *rulesbase*)
        (let ((p (getpremisses rule)))
            (if (or (= (length p) 2) (= (length p) 3))
                (if (and (trueRule (nth 0 p)) (not (assoc (cadr (nth 1 p)) *bdf*)))
                    (progn (setq new_fact 1) (askQuestion (nth 0 p) (nth 1 p)) (return-from nil))
                )
            )
            (if (= (length p) 3)
                (if (and (trueRule (nth 0 p)) (not (assoc (cadr (nth 2 p)) *bdf*)))
                    (progn (setq new_fact 1) (askQuestion (nth 0 p) (nth 2 p)) (return-from nil))
                )
            )
        )
    )
    (if (assoc 'BEER *bdf*)
        (affichagebeer)
        (chainageavant)
    )
)


(defun parcours ()
    (defparameter *bdf* NIL)
    (defparameter new_fact 0)
    (defparameter applicable  1)
    (chainageavant)
)
