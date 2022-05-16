

ORG 100H


JMP start


newline EQU 0AH   ; \n
cret    EQU 0DH   ; \r
 
 
; String to be operated on
string1 DB 'Oh hi there! this is an encrypted message', cret, newline, '$' ;'$' indicates the end of the string


; Just for reference ------------->  'abcdefghijklmnopqrstuvwxyz'
encrypt_table_lower DB 97 dup (' '), 'qwertyuiopasdfghjklzxcvbnm'  
decrypt_table_lower DB 97 dup (' '), 'kxvmcnophqrszyijadlegwbuft'  
; We leave 97(61H) blank spaces before the start of the table
; as the ASCII value of 'a' = 61H
                                   
encrypt_table_upper DB 65 dup (' '), 'QWERTYUIOPASDFGHJKLZXCVBNM'  
decrypt_table_upper DB 65 dup (' '), 'KXVMCNOPHQRSZYIJADLEGWBUFT'
; We leave 65(41H) blank spaces before the start of the table
; as the ASCII value of 'A' = 41H


start:

; Encrypt:
LEA     SI, string1
CALL    encrypt

; Display result on the screen:
LEA     DX, string1
MOV     AH, 09          ; value of AH is adjusted as operation of int 21H depends on its value
INT     21H             ; at AH=09, int 21H outputs string at DS:DX

; Decrypt:
LEA     SI, string1
CALL    decrypt

; Display result on the screen:
LEA     DX, string1
MOV     AH, 09          ; value of AH is adjusted as operation of int 21H depends on its value
INT     21H             ; at AH=09, int 21H outputs string at DS:DX

; Wait for any key...
MOV     AH, 0
INT     16H


RET



;   si - address of string to encrypt
encrypt PROC NEAR

enc_next_char:
	
	MOV     AL, [SI] 
	CMP     AL, ' '       ;<--- Beginning of space check
	JNE     cont_enc          ; Since this was a college assignment, One of my requirements was to omit spaces in my result
	CALL    omit_spaces       ; so you can just remove this section if you do not wish to do that
    JMP     enc_next_char ;<--- End of space check
    	
cont_enc:	
	CMP     AL, '$'      ; End of string?
	JE      end_of_string_enc
	CMP     AL, 'a'
	JB      check_upper_enc
	CMP     AL, 'z'
	JA      skip_enc
	LEA     BX, encrypt_table_lower 
	JMP     op_enc
check_upper_enc:
    CMP     AL, 'A'
    JB      skip_enc
    CMP     AL, 'Z'
    JA      skip_enc
    LEA     BX, encrypt_table_upper	
op_enc:		
	XLATB
	MOV     [SI], AL
skip_enc:
	INC     SI	
	JMP     enc_next_char

end_of_string_enc:


RET
encrypt ENDP
   
   
   
   
;   si - address of string to encrypt
decrypt PROC NEAR

dec_next_char:
	
	MOV     AL, [SI] 
	CMP     AL, ' '       ;<--- Beginning of space check
	JNE     cont_dec          ; Since this was a college assignment, One of my requirements was to omit spaces in my result
	CALL    omit_spaces       ; so you can just remove this section if you do not wish to do that
    JMP     dec_next_char ;<--- End of space check
    	
cont_dec:	
	CMP     AL, '$'      ; End of string?
	JE      end_of_string_dec
	CMP     AL, 'a'
	JB      check_upper_dec
	CMP     AL, 'z'
	JA      skip_dec
	LEA     BX, decrypt_table_lower 
	JMP     op_dec
check_upper_dec:
    CMP     AL, 'A'
    JB      skip_dec
    CMP     AL, 'Z'
    JA      skip_dec
    LEA     BX, decrypt_table_upper	
op_dec:		
	XLATB
	MOV     [SI], AL
skip_dec:
	INC     SI	
	JMP     dec_next_char

end_of_string_dec:


RET
decrypt ENDP

      

; Subroutine to send space to the end of the string (after '$')
omit_spaces PROC NEAR    
    PUSH    SI
    PUSH    BX             ; The reason I send the space after the '$'
    MOV     BX, SI         ; is to handle several consecutive spaces without
	DEC     SI             ; entering an inifnite loop as opposed to just swapping
omit_spaces_loop:          ; the ' ' character with the following character
    INC     SI              
    INC     BX
    MOV     AL, [BX]
    MOV     [BX], ' '
    MOV     [SI], AL
    CMP     [SI], '$'
    JNE     omit_spaces_loop
    POP     BX
    POP     SI
    
    RET
omit_spaces ENDP
        

end
       