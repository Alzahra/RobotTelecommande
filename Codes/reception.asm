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

    __CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_OFF & _XT_OSC

; '__CONFIG' précise les paramètres encodés dans le processeur au moment de
; la programmation. Les définitions sont dans le fichier include.
; Voici les valeurs et leurs définitions :
;    _CP_ON                Code protection ON : impossible de relire
;    _CP_OFF                Code protection OFF
;    _PWRTE_ON            Timer reset sur power on en service
;    _PWRTE_OFF            Timer reset hors-service
;    _WDT_ON                Watch-dog en service
;    _WDT_OFF          	   Watch-dog hors service
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

INTERMASK    EQU    H'90'   	; Masque d'interruption
                                ; Interruptions sur RB0


;*********************************************************************
;                   DECLARATIONS DE VARIABLES                        *
;*********************************************************************

    CBLOCK 0x00C                   ; début de la zone variables
    w_temp :1                    ; Zone de 1 byte
    status_temp : 1                ; zone de 1 byte
    cmpt1                      ; compteur de boucles 1
    ;cmpt2 : 1                     ; compteur de boucles 2
    ;cmpt3 : 1                     ; compteur de boucles 3
    ;cmpt4 : 1                     ; compteur pour nb message
	nbfront 
	bouclea
	;temp 					;compteur pour le tempo
    ENDC                        ; Fin de la zone                        

;**********************************************************************
;                      DEMARRAGE SUR RESET                            *
;**********************************************************************

    org 0x000                     ; Adresse de départ après reset
      goto    init                ; Adresse 0: initialiser

;**********************************************************************
;                     ROUTINE INTERRUPTION                            *
;**********************************************************************
	
   ;sauvegarder registres       
   ;---------------------  
   ORG 0x004    ; adresse d'interruption  
   movwf  	w_temp    ; sauver registre W  
   swapf 	STATUS,w  ; swap status avec résultat dans w  
   movwf 	status_temp  ; sauver status swappé 
   
   incf		nbfront,1
   ;bsf		PORTB,2
   bcf  	INTCON,INTF  ; effacer flag interupt RB0   
   
      ;restaurer registres            
   swapf 	status_temp,w ; swap ancien status, résultat dans w  
   movwf  	STATUS   ; restaurer status  
   swapf  	w_temp,f  ; Inversion L et H de l'ancien W                          
      				; sans modifier Z  
   swapf  	w_temp,w  ; Ré-inversion de L et H dans W        
     				 ; W restauré sans modifier status  
   retfie      ; return from interrupt 
;*********************************************************************
;                       INITIALISATIONS                              *
;*********************************************************************

init
    bcf     STATUS,RP0            ; sélectionner banque 0
    clrf    PORTA                ; Sorties portA à 0
    clrf    PORTB                ; sorties portB à 0
    
    bsf     STATUS,RP0            ; sélectionner banque 1
    bcf     TRISA,0                ;sortie
    bcf     TRISA,1                ;sortie
    bcf     TRISA,2                ;sortie
    bsf     TRISB,0                ;entrée
    ;bcf 	TRISB,2					;sortie
    
    bcf     STATUS,RP0            ; sélectionner banque 0
	clrf 	INTCON 				; tout a zerro (interuptions)
	bsf		INTCON,INTE 		; interruption sur RB0 (4)
	clrf 	nbfront				 ; Le message est vide de base
    goto start

;*********************************************************************
; 						SOUS-ROUTINE DE TEMPORISATION *
;*********************************************************************
;---------------------------------------------------------------------
; Cette sous-routine introduit un retard de 500.000 µs.
; Elle ne reçoit aucun paramètre et n'en retourne aucun
;---------------------------------------------------------------------
tempo
    movlw 	250             ; pour 249*2 + 250
    movwf 	cmpt1        ; initialiser compteur3
boucle1
    nop                 
    decfsz 	cmpt1 , f     ; décrémenter compteur1
    goto 	boucle1         ; si pas 0, boucler
    return                 ; retour de la sous-routine

;*********************************************************************
;                      PROGRAMME PRINCIPAL                           *
;*********************************************************************
 
start
	clrf    PORTA 
	bsf 	INTCON,GIE ;activation interruption
	;call tempo
	movlw 	0
	movwf	nbfront
	;movlw 	5				;pour écouter nos 12 fronts max au moins
	;movwf 	temp


attente
   	btfsc 	nbfront,0
   	goto 	attente2
   	goto 	attente	
  
attente2
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms
	call tempo
	call tempo 
	call tempo 
	call tempo  ;2ms 
	call tempo
	call tempo
	call tempo
	;call tempo
	;decfsz 	temp,f
	;goto 	attente2
	goto 	traitement
 		
traitement   
	bcf 	INTCON,GIE
	movlw 	3
	subwf 	nbfront,1 ;nbfront - W
	decfsz 	nbfront, f; nbfront - 4 
	goto 	reculer
	goto 	avancer1

avancer1
	movlw 	5				;pour écouter nos 12 fronts max au moins
	movwf 	bouclea

avancer2
	bsf PORTA, 0
	nop
	nop
	bcf PORTA, 1
	nop
	nop
	bcf PORTA, 2
	nop
	nop
	decfsz 	bouclea,f
	goto 	avancer2
	;call tempo
	;call tempo
	goto start
	
reculer
	movlw 	1
	subwf 	nbfront,1
	decfsz 	nbfront,f ;nbfront - 6
	goto 	gauche
	goto 	reculer1
	
reculer1
	movlw 	5				;pour écouter nos 12 fronts max au moins
	movwf 	bouclea
reculer2
	bcf PORTA, 0
	nop
	nop
	bsf PORTA, 1
	nop
	nop
	bcf PORTA, 2
	nop
	nop
	decfsz 	bouclea,f
	goto 	reculer2
	;call tempo
	;call tempo
	goto start

gauche
	movlw 	1
	subwf 	nbfront,1
	decfsz 	nbfront,f ;nbfront - 8
	goto 	droite
	goto 	gauche1	

gauche1
	movlw 	5				;pour écouter nos 12 fronts max au moins
	movwf 	bouclea

gauche2
	bsf PORTA, 0
	nop
	nop	
	bsf PORTA, 1
	nop
	nop	
	bcf PORTA, 2
	nop
	nop	
	decfsz 	bouclea,f
	goto 	gauche2
	;call tempo	
	;call tempo
	goto start

droite
	movlw 	1
	subwf 	nbfront,1
	decfsz 	nbfront,f ;nbfront -10
	goto 	stop
	goto 	droite1
	
droite1
	movlw 	5				;pour écouter nos 12 fronts max au moins
	movwf 	bouclea
droite2
	bcf PORTA, 0
	nop
	nop
	bcf PORTA, 1
	nop
	nop
	bsf PORTA, 2
	nop
	nop
	decfsz 	bouclea,f
	goto 	droite2
	;call tempo
	;call tempo
	goto start

stop				
	movlw 	5
	subwf 	nbfront,1
	;movlw	1
	;subwf 	nbfront,1
	;decfsz 	nbfront,f ;nbfront - 15
	btfsc	nbfront,0
	goto 	start
	goto 	stop2

stop2	
	bsf PORTA, 0
	nop
	nop
	bcf PORTA, 1
	nop
	nop
	bsf PORTA, 2
	nop
	nop
	call tempo
	call tempo
	goto start
	END                ; directive fin de programme
