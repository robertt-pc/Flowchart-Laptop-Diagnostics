
; Sistema Experto : Laptop Won't Power On



;Equipo: 

;Creador: Roberto Pérez Castillo 

; DEFTEMPLATES (Plantillas de Hechos)
; deftemplate nodo:  sirve para rastrear el estado actual del diagnóstico. 

(deftemplate nodo
   (slot nombre (type SYMBOL)))

; Inicio del diagrama

(defrule inicio
   =>
   (printout t "--- Sistema Experto : Laptop Won't Power On ---" crlf)
   (assert (nodo (nombre evaluar-led-on))))

; Sirve para evaluar el nodo principal superior: "Laptop power LED on?"

(defrule evaluar-led-on
   ?f <- (nodo (nombre evaluar-led-on))
   =>
   (retract ?f)
   (printout t "1. ¿El LED de encendido de la laptop esta encendido? (si/no): ")
   (if (eq (read) si)
      then (assert (nodo (nombre wiggling-cord)))
      else (assert (nodo (nombre hard-reset)))))

; RAMA DERECHA


; ADICIÓN 1: HARD RESET

(defrule hard-reset
   ?f <- (nodo (nombre hard-reset))
   =>
   (retract ?f)
   (printout t "[ADICION 1] ¿Realizaste un drenado de energia (Hard Reset) de 60 seg? (si/no): ")
   (if (eq (read) si)
      then (assert (nodo (nombre dc-voltage)))
      else (printout t "-> DIAGNOSTICO: Realiza el Hard Reset para desbloquear el EC." crlf)))

; Sirve para comprobar la salida de voltaje del adaptador de corriente.

(defrule dc-voltage
   ?f <- (nodo (nombre dc-voltage))
   =>
   (retract ?f)
   (printout t "¿El voltaje DC es correcto en la salida del adaptador? (si/no): ")
   (if (eq (read) si)
      then (assert (nodo (nombre dc-connector-loose)))
      else (assert (nodo (nombre live-ac)))))

; Sirve para verificar daño físico en el puerto de carga interno.

(defrule dc-connector-loose
   ?f <- (nodo (nombre dc-connector-loose))
   =>
   (retract ?f)
   (printout t "¿El conector DC se siente suelto dentro de la laptop? (si/no): ")
   (if (eq (read) si)
      then (printout t "-> DIAGNOSTICO: Soldar un nuevo conector en la placa." crlf)
      else (assert (nodo (nombre battery-removed)))))

; Sirve para asegurar que la toma de corriente de la pared funciona.

(defrule live-ac
   ?f <- (nodo (nombre live-ac))
   =>
   (retract ?f)
   (printout t "¿La toma de corriente de la pared tiene energia? (si/no): ")
   (if (eq (read) si)
      then (assert (nodo (nombre usb-c-pd)))
      else (printout t "-> DIAGNOSTICO: Use un enchufe que funcione." crlf)))


; ADICIÓN 3: PROTOCOLO USB-C 
; Sirve para diagnosticar fallos de negociación digital de energía en cargadores modernos sin necesidad de cortar cables.


(defrule usb-c-pd
   ?f <- (nodo (nombre usb-c-pd))
   =>
   (retract ?f)
   (printout t "[ADICION 3] ¿Has probado conectar un cargador USB-C diferente (PD)? (si/no): ")
   (if (eq (read) si)
      then (printout t "-> DIAGNOSTICO: Fallo en el puerto USB-C (requiere soldadura)." crlf)
      else (printout t "-> DIAGNOSTICO: Reemplazar cargador (Fallo de chip de negociacion)." crlf)))


; RAMA IZQUIERDA


; Sirve para diagnosticar falsos contactos en la entrada de energía (rama izquierda).

(defrule wiggling-cord
   ?f <- (nodo (nombre wiggling-cord))
   =>
   (retract ?f)
   (printout t "¿El LED parpadea si mueves el cable de energia? (si/no): ")
   (if (eq (read) si)
      then (assert (nodo (nombre internal-jack)))
      else (assert (nodo (nombre beeps-led)))))

; Sirve para decidir si cambiar el puerto o el cable cuando hay falso contacto.

(defrule internal-jack
   ?f <- (nodo (nombre internal-jack))
   =>
   (retract ?f)
   (printout t "¿El jack de poder interno esta suelto? (si/no): ")
   (if (eq (read) si)
      then (printout t "-> DIAGNOSTICO: Reemplazar el jack interno." crlf)
      else (printout t "-> DIAGNOSTICO: Reemplazar el cable de salida AC." crlf)))

; ADICIÓN 2: CÓDIGOS LED
; Sirve para diagnosticar fallos de POST (Power-On Self-Test) considerando que los equipos modernos ya no utilizan bocinas, sino patrones de luces.

(defrule beeps-led
   ?f <- (nodo (nombre beeps-led))
   =>
   (retract ?f)
   (printout t "[ADICION 2] ¿Hay pitidos multiples o parpadeos LED repetitivos? (si/no): ")
   (if (eq (read) si)
      then (printout t "-> DIAGNOSTICO: Error de POST. Reasiente la RAM o verifique el codigo del fabricante." crlf)
      else (assert (nodo (nombre unplugged)))))

; Sirve para aislar fallas causadas por periféricos externos USB defectuosos.

(defrule unplugged
   ?f <- (nodo (nombre unplugged))
   =>
   (retract ?f)
   (printout t "¿Inicia si desconectas todos los perifericos externos? (si/no): ")
   (if (eq (read) si)
      then (printout t "-> DIAGNOSTICO: Un dispositivo USB externo causa corto." crlf)
      else (assert (nodo (nombre hear-fan)))))

; Sirve para comprobar si la tarjeta madre está arrancando correctamente a pesar de que no hay video.

(defrule hear-fan
   ?f <- (nodo (nombre hear-fan))
   =>
   (retract ?f)
   (printout t "¿Escucha el ventilador o el disco girar? (si/no): ")
   (if (eq (read) si)
      then (printout t "-> DIAGNOSTICO: Fallo de pantalla/video (Display failure)." crlf)
      else (assert (nodo (nombre momentary-life)))))

; Sirve para detectar cortos circuitos inmediatos al presionar encendido.
(defrule momentary-life
   ?f <- (nodo (nombre momentary-life))
   =>
   (retract ?f)
   (printout t "¿Muestra señales de vida momentaneas y se apaga? (si/no): ")
   (if (eq (read) si)
      then (assert (nodo (nombre battery-removed)))
      else (assert (nodo (nombre action-switch)))))

; Sirve para descartar que una batería en cortocircuito impida el encendido.

(defrule battery-removed
   ?f <- (nodo (nombre battery-removed))
   =>
   (retract ?f)
   (printout t "¿La laptop enciende con la bateria removida? (si/no): ")
   (if (eq (read) si)
      then (printout t "-> DIAGNOSTICO: La bateria esta en corto. Reemplácela." crlf)
      else (assert (nodo (nombre stripped-down)))))

; Sirve para diagnosticar falla mecánica en el botón físico de encendido.
(defrule action-switch
   ?f <- (nodo (nombre action-switch))
   =>
   (retract ?f)
   (printout t "¿Siente el clic fisico en el interruptor de encendido? (si/no): ")
   (if (eq (read) si)
      then (assert (nodo (nombre redo-connections)))
      else (printout t "-> DIAGNOSTICO: Falla mecanica del interruptor." crlf)))

; Sirve para comprobar si re-asentar los cables flex internos soluciona el problema.
(defrule redo-connections
   ?f <- (nodo (nombre redo-connections))
   =>
   (retract ?f)
   (printout t "¿Reconectar cables internos soluciono el problema? (si/no): ")
   (if (eq (read) si)
      then (printout t "-> DIAGNOSTICO: ¡Problema resuelto (Lucky)!" crlf)
      else (assert (nodo (nombre stripped-down)))))

; Sirve para aislar componentes internos (RAM, Discos) que causen cortocircuito.

(defrule stripped-down
   ?f <- (nodo (nombre stripped-down))
   =>
   (retract ?f)
   (printout t "¿Enciende al dejarla solo con lo basico (motherboard+CPU+1 RAM)? (si/no): ")
   (if (eq (read) si)
      then (printout t "-> DIAGNOSTICO: Un componente interno secundario falla." crlf)
      else (printout t "-> DIAGNOSTICO: Falla de placa base (Board level failure)." crlf)))