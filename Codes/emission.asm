;**********************************************************************
;   Ce fichier est la base de départ pour une programmation avec      *
;   le PIC 16F84. Il contient  les informations de  base pour         *
;   démarrer.                                                         *  
;                                                                     *
;   Si les interruptions ne sont pas utilisées, supprimez les lignes  *
;   entre ORG 0x004 et l'étiquette init. De plus, les variables       *
;   w_temp et status_temp peuvent être supprimées.                    *
;                                                                     *
;**********************************************************************
;                                                                     *
;    NOM:                                                             *
;    Date:                                                            *
;    Version:                                                         *
;    Circuit:                                                         *
;    Auteur:                                                          *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Fichier requis: P16F84.inc                                       *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;                                                                     *
;                                                                     *
;                                                                     *
;**********************************************************************


    LIST      p=16F84             ; Définition de processeur
    #include <p16F84.inc>         ; Définitions des constantes
    radix dec                     ; on travaille en décimal par défaut

    __CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC

; '__CONFIG' précise les paramètres encodés dans le processeur au moment de
; la programmation. Les définitions sont dans le fichier include.
; Voici les valeurs et leurs définitions :
;    _CP_ON                Code protection ON : impossible de relire
;    _CP_OFF                Code protection OFF
;    _PWRTE_ON            Timer reset sur power on en service
;    _PWRTE_OFF            Timer reset hors-service
;    _WDT_ON                Watch-dog en service
;    _WDT_OFF            Watch-dog hors service
;    _LP_OSC                Oscillateur quartz basse vitesse
;    _XT_OSC                Oscillateur quartz moyenne vitesse
;    _HS_OSC                Oscillateur quartz grande vitesse
;    _RC_OSC                Oscillateur à réseau RC

;*********************************************************************
;                              ASSIGNATIONS                          *
;*********************************************************************

OPTIONVAL    EQU    H'40'            ; Valeur registre option
                                ; Résistance pull-up ON
                                ; Interrupt flanc montant RB0
                                ; Préscaler timer à 2 (exemple)

INTERMASK    EQU    H'90'         ; Masque d'interruption
                                ; Interruptions sur RB0 (exemple)


;*********************************************************************
;                   DECLARATIONS DE VARIABLES                        *
;*********************************************************************

;exemples
;---------
    CBLOCK 0x00C                   ; début de la zone variables
    w_temp :1                    ; Zone de 1 byte
    status_temp : 1                ; zone de 1 byte
    cmpt1                     ; compteur de boucles 1
    cmpt2                      ; compteur de boucles 2
    cmpt3                     ; compteur de boucles 3
    cmpt4                     ; compteur pour nb message
	nbfront 
    ENDC                        ; Fin de la zone                        

;**********************************************************************
;                      DEMARRAGE SUR RESET                            *
;**********************************************************************

    org 0x000                     ; Adresse de départ après reset
      goto    init                ; Adresse 0: initialiser

;**********************************************************************
;                     ROUTINE INTERRUPTION                            *
;**********************************************************************



;*********************************************************************
;                       INITIALISATIONS                              *
;*********************************************************************

init
    bcf        STATUS,RP0            ; sélectionner banque 0
    clrf    	PORTA                ; Sorties portA à 0
    clrf    	PORTB                ; sorties portB à 0
    bsf        STATUS,RP0            ; sélectionner banque 1
    bsf        TRISA,0                ;entrée
    bsf        TRISA,1                ;entrée
    bsf        TRISA,2                ;entrée
    bcf        TRISB,7                ;sortie
    bcf        STATUS,RP0            ; sélectionner banque 0
    goto start



;*********************************************************************
; SOUS-ROUTINE DE TEMPORISATION *
;*********************************************************************
;-------------------------------------------------------------------
; Cette sous-routine introduit un retard de 500 µs. = 0.5ms = 166
; Elle ne reçoit aucun paramètre et n'en retourne aucun
;---------------------------------------------------------------------
tempo 	;0.5ms
	movlw 166
	movwf cmpt4
boucle4
	nop							
	decfsz	cmpt4,f	
	goto boucle4
	return

tempo2 ;0.5s
	movlw	2					; pour 2 boucles
	movwf	cmpt3				; initialiser compteur3
boucle3
	clrf	cmpt2				; effacer compteur2
boucle2
	clrf	cmpt1				; effacer compteur1
boucle1
	nop							; perdre 1 cycle
	decfsz	cmpt1,f				; décrémenter compteur1
	goto	boucle1				; si pas 0, boucler	
	decfsz	cmpt2,f 			; si 0, décrémenter compteur 2
	goto	boucle2				; si cmpt2 pas 0, recommencer boucle1
	decfsz	cmpt3,f				; si 0, décrémenter compteur 3
	goto	boucle3				; si cmpt3 pas 0, recommencer boucle2
	return						; retour de la sous-routine


;*********************************************************************
;                      PROGRAMME PRINCIPAL                           *
;*********************************************************************

start
	btfss PORTA, 0    ;RA0 = 1
	goto reculer_droite   ;RA0 = 0
	goto avancer_gauche_stop

reculer_droite       ; RA0 = 0
	btfss PORTA, 1  ;  RA1 = 1
	goto droite ;RA1 = 0
	goto reculer

avancer_gauche_stop   ;RA0=1
	btfss PORTA, 1    
	goto avancer_stop   ;RA1 = 0
	goto gauche ;RA1 = 1 

avancer_stop  ; RA0 = 1 RA1 = 0
	;call tempo
	btfss PORTA, 2   ;RA2 = 1
	goto avancer_front   ;RA2 = 0
	goto stop_front

droite   ;RA0 = 0 RA1 = 0
	btfss PORTA, 2    ; RA2 = 1
	goto start
	goto droite_front

reculer    ;RA0 = 0 RA1 = 1
	btfss PORTA, 2    ; RA2 = 1
	goto reculer_front
	goto start

gauche     ;RA0 = 1 RA1 = 1
	btfss PORTA, 2    ;RA2 = 1
	goto gauche_front ;RA2=0
	goto start
	

gauche_front
	;On envoie 16 fronts (16 bits)
	;RB7 a 8 bits à 1
	movlw 8
	movwf nbfront
envoie_front4
	bsf PORTB, 7   ; RB7 = 1
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	bcf PORTB, 7   ; RB7 = 0
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	decfsz nbfront, f
	goto envoie_front4
	goto temporisation

avancer_front
	;On envoie 8 fronts (8 bits)
	;RB7 a 4 bits à 1
	movlw 4
	movwf nbfront
envoie_front1
	bsf PORTB, 7   ; RB7 = 1
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	bcf PORTB, 7   ; RB7 = 0
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	decfsz nbfront, f
	goto envoie_front1
	goto temporisation

reculer_front
	;On envoie 12 fronts (12 bits)
	;RB7 a 6 bits à 1
	movlw 6
	movwf nbfront
envoie_front2
	bsf PORTB, 7   ; RB7 = 1
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	bcf PORTB, 7   ; RB7 = 0
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	decfsz nbfront, f
	goto envoie_front2
	goto temporisation

droite_front
	;On envoie 20 bits
	;RB7 a 10 bits à 1
	movlw 10 
	movwf nbfront
envoie_front3
	bsf PORTB, 7   ; RB7 = 1
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	bcf PORTB, 7   ; RB7 = 0
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	decfsz nbfront, f
	goto envoie_front3
	goto temporisation

stop_front
	;On envoie 30 fronts
	;RB7 a 15 bits à 1
	movlw 15
	movwf nbfront
envoie_front5
	bsf PORTB, 7   ; RB7 = 1
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	bcf PORTB, 7   ; RB7 = 0
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	decfsz nbfront, f
	goto envoie_front5
	goto temporisation

temporisation
	call tempo2
	;call tempo2 
	;call tempo2
	call tempo2 ; 2secondes
	goto start
        
      END                ; directive fin de programme
