# THONG TIN SINH VIEN
# Ho va ten: Nguyen Le Hoang Phuc
# MSSV: 2212629
# Lop: L14


# De 4
# Viet chuong trinh MARS MIPS dung chuc nang set seed (syscall 40) theo time (syscall 30) 
# va cac chuc nang phat so ngau nhien de phat ra 3 so ngau nhien fi (0<fi<1000). 
# Luu cac ket qua chay chuong trinh theo 3 dang so le len tap tin SOLE.TXT tren dia thanh 3 dong nhu sau:
# 2 so le: fff.ff 
# 3 so le: fff.fff 
# 4 so le: fff.ffff 


############################# DATA DECLARATION ################################################
	.data
		str_fileName: .asciiz "SOLE.txt"
		str_2sole:  .asciiz "2 so le: "
		str_3sole:  .asciiz "3 so le: "
		str_4sole:  .asciiz "4 so le: "
		str_enter:  .asciiz "\n"
		str_dot:    .asciiz "."
		str_0: .asciiz "0"
		
		buffer: .space 32
		
		int_fileDescriptor: .word 0
		int_0: 	 	.word 0
		int_100: 	.word 100
		int_1000: 	.word 1000
		int_10000: 	.word 10000
		
		float_res: 	.float 0
		float_100000: 	.float 100000.0
		float_1000000: 	.float 1000000.0
		float_10000000: .float 10000000.0
		
	.text
	.globl mainFunction
#============================= END DATA DECLARATION ===========================================#



############################ MACRO DECLARATION ###############################################
	.macro printString (%str)		# In chuoi %str
		li $v0, 4
		la $a0, %str
		syscall
	.end_macro #--------------------------------------------------------------------------
	
	.macro randomFloat			# Random so thuc trong doan [0.0, 1.0]
		li $v0, 43
		syscall
		swc1 $f0, float_res
	.end_macro #--------------------------------------------------------------------------
	
	.macro openFile (%file)			# Mo file
		li $v0, 13
		la $a0, %file
		li $a1, 1
		syscall
	.end_macro #--------------------------------------------------------------------------
	
	.macro writeToFile (%fileDescriptor, %output, %numCharaters)	# Ghi vao file
		li $v0, 15
		move $a0, %fileDescriptor
		la $a1, %output
		move $a2, %numCharaters
		syscall
	.end_macro #--------------------------------------------------------------------------
	
	.macro closeFile (%fileDescriptor)	# Dong file
		li $v0, 16
		move $a0, %fileDescriptor
		syscall
	.end_macro #--------------------------------------------------------------------------
#=============================== END MACRO DECLARATION =======================================#



########################## MAINFUNCTION IMPLEMENTATION #########################################
# Ham su dung register $t0 -> $t9 tuy thuoc ngu canh, se duoc giai thich trong tung dong code
# Ham han che su dung register $s0 -> $s7 (chu yeu dung cho function ben duoi mainFunction)
# $t6: register duy nhat khong thay doi trong toan bo chuong trinh -> luu fileDescriptor trong syscall 15 + 16
mainFunction:
	#------- INPUT ------------------------------------------------------------
	
	#------- PROCESS ----------------------------------------------------------
	li $v0, 30		# lay thoi gian tai 1 thoi diem chay chuong trinh
	syscall
	
	li $v0, 40		# set seed (gieo hat giong) phuj thuoc vao thoi gian
	add $a1, $zero, $a0
	syscall
	
	openFile(str_fileName)	# mo file + bat dau ghi
	move $t6, $v0		# luu fileDescriptor vao $t6
	
	# Vong lap Loop: lap 3 lan -> moi lan random 1 so thuc ~~~~~~~~~~~~~~~~~~~~~
		li $t9, 3				# Khoi tao upperBound (can tren), dai dien la $t9
		li $t8, 0				# Khoi tao bien dem i, dai dien la $t8
	Loop:
		beq $t8, $t9, end_Loop			# Xet dieu kien: neu khong thoa -> thoat Loop	
	
		addi $s7, $t8, 2			# gan option $s7 = i + 2, quy dinh so luong chu so le

		jal choose_print			# Chon + In cau nhac <phu thuoc gia tri $s7>
	
    		randomFloat				# random 1 so thuc + luu vao float_res
		lwc1 $f0, float_res			# $f0 = float_a		(nap float_res vao $f0)
	
		jal choose_f1_t1			# chon gia tri phu hop nap vao $f1 <phu thuoc gia tri $s7>
		mul.s $f2, $f0, $f1			# $f2 = fffff.(ff..ff)
		cvt.w.s $f2, $f2			# chuyen $f2 ve so nguyen
		mfc1 $t0, $f2				# $t0 = fffff

		div $t2, $t0, $t1			# $t2 = fff.ff

		mflo $s0				# $s0 chua phan nguyen
		jal numZero_process1			# In phan nguyen
		li $t5, 1
		writeToFile($t6, str_dot, $t5)
		mfhi $s0				# $s0 chua phan thap phan (phan du)
		jal numZero_process2			# In phan thap phan

		li $t5, 1
		writeToFile($t6, str_enter, $t5)
		
    		addi $t8, $t8, 1			# Giam bien i mot don vi
    		j Loop					# Quay lai vong lap moi
	end_Loop:
	# Ket thuc vong lap Loop ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	closeFile($t6)
	
	#---------- OUTPUT ------------------------------------------------------------


	#---------- TERMINATE PROGRAM -------------------------------------------------
	li $v0, 10
	syscall
	
#============================= END MAINFUNCTION IMPLEMENTATION ==============================#





############################ FUNCTION DECLARATION ############################################

# ----- Function 1: --------------------------------------------------------------------------
# Name: numZero_process1 -> quan ly viec in chu so 0 cho phan nguyen
# Thong so thanh ghi:
#	$a1, $a2: cac chu so dung de in
#	$a0: tham so cho ham <int2str>
# 	$t0: register tam thoi quan ly load/store voi stack
numZero_process1:
# Store hi + lo register vao stack
	addi $sp, $sp, -12
	sw   $ra, 8($sp)
	mfhi $t0
	sw   $t0, 4($sp)
	mflo $t0
	sw   $t0, 0($sp)
	
	# if ($s1 / 100 = 0) {
		div $s1, $s0, 100
		bne $s1, $zero, else1
		addi $s1, $s1, 1
		writeToFile($t6, str_0, $s1)
	# if ($s1 / 10 == 0) { 
		div $s1, $s0, 10
		bne $s1, $zero, else1
		addi $s1, $s1, 1
		writeToFile($t6, str_0, $s1)
	# }
	# }	
	# else {
	else1:
		move $a0, $s0
		jal int2str
	# }
	end_if1:
# Load hi + lo register tu stack 
		lw   $t0, 0($sp)
		mtlo $t0
		lw   $t0, 4($sp)
		mthi $t0
		lw $ra, 8($sp)
		addi $sp, $sp, 12
# return address
	jr $ra



# ----- Function 2: --------------------------------------------------------------------------
# Name: numZero_process2 -> quan ly viec in chu so 0 cho phan thap phan
# Thong so thanh ghi:
#	$s0, $s1, $s6, $s7: cac chu so dung de in
#	$a0: tham so cho ham <int2str>
# 	$t0: register tam thoi quan ly load/store voi stack
numZero_process2:
# Store registers vao stack. 
	addi $sp, $sp, -28
	sw $s0, 24($sp)
	sw $s1, 20($sp)
	sw $s6, 16($sp)
	sw $s7, 12($sp)
	sw $ra, 8($sp)
	mfhi $t0
	sw   $t0, 4($sp)
	mflo $t0
	sw   $t0, 0($sp)
	
# print <phan dinh tri>
	move $a0, $s0
	jal int2str

	subi $s6, $s7, 3
	beqz $s6, if21
	bltz $s6, if22
# if ($s7 == 4) {
#	print: <4 chu so thap phan>
# }
	div $s1, $s0, 1000
	bne $s1, $zero, end_if2
	addi $s1, $s1, 1
	writeToFile($t6, str_0, $s1)
# else if ($s7 == 3) {
# 	print: <3 chu so thap phan>
# }
if21:
	div $s1, $s0, 100
	bne $s1, $zero, end_if2
	addi $s1, $s1, 1
	writeToFile($t6, str_0, $s1)
# else if ($s7 == 2) {
# 	print: <2 chu so thap phan>
# }
if22:	
	div $s1, $s0, 10
	bne $s1, $zero, end_if2
	addi $s1, $s1, 1
	writeToFile($t6, str_0, $s1)	
	
end_if2:
# restore registers tu stack
	lw   $t0, 0($sp)
	mtlo $t0
	lw   $t0, 4($sp)
	mthi $t0
	lw   $ra, 8($sp)
	lw   $s7, 12($sp)
	lw   $s6, 16($sp)
	lw   $s1, 20($sp)
	lw   $s0, 24($sp)
	addi $sp, $sp, 28
# return address
	jr $ra


# ----- Function 3: --------------------------------------------------------------------------
# Name: choose_f1_t1 -> luu gia tri vao f1, t1 (co dieu kien)
# Thong so thanh ghi:
#	$s6, $s7: cac register dung de xet dieu kien
# 	$t0: register tam thoi quan ly load/store voi stack
choose_f1_t1:
# Store registers vao stack. 
	addi $sp, $sp, -8
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	
	subi $s6, $s7, 3
	beqz $s6, else_if2
	bltz $s6, else_if3
# if ($s7 == 4) {
#	load: nap 10,000,000 vao $f1
# }
	lwc1 $f1, float_10000000
	lw $t1, int_10000
	j end_if3
# else if ($s7 == 3) {
# 	load: nap 1,000,000 vao $f1
# }
else_if2:
	lwc1 $f1, float_1000000
	lw $t1, int_1000
	j end_if3
# else if ($s7 == 2) {
# 	load: nap 100,000 vao $f1
# }
else_if3:	
	lwc1 $f1, float_100000	
	lw $t1, int_100
end_if3:

# restore registers tu stack
	lw   $s7, 0($sp)
	lw   $s6, 4($sp)
	addi $sp, $sp, 8
# return address
	jr $ra


# ----- Function 4: --------------------------------------------------------------------------
# Name: choose_print -> in cau nhac <co dieu kien>
# Thong so thanh ghi:
#	$s6, $s7: register xet dieu kien
#	$a0: tham so cho ham <int2str>
# 	$t0: register tam thoi quan ly load/store voi stack
choose_print:
# Store registers vao stack. 
	addi $sp, $sp, -8
	sw $s6, 4($sp)
	sw $s7, 0($sp)
	
	subi $s6, $s7, 3
	beqz $s6, else_if6
	bltz $s6, else_if7
# if ($s7 == 4) {
#	load: nap 10,000 vao $t1
# }
	li $t0, 9
	writeToFile($t6, str_4sole, $t0)
	j end_if5
# else if ($s7 == 3) {
# 	load: nap 1000 vao $t1
# }
else_if6:
	li $t0, 9
	writeToFile($t6, str_3sole, $t0)
	j end_if5
# else if ($s7 == 2) {
# 	load: nap 100 vao $t1
# }
else_if7:
	li $t0, 9
	writeToFile($t6, str_2sole, $t0)
end_if5:
# restore registers tu stack
	lw   $s7, 0($sp)
	lw   $s6, 4($sp)
	addi $sp, $sp, 8
# return address
	jr $ra



# ----- Function 5: --------------------------------------------------------------------------
# Name: int2str -> chuyen doi so nguyen thanh chuoi
# Thong so thanh ghi:
#	$a0: so nguyen can chuyen doi
# 	$a1: dia chi bat dau cua chuoi ket qua <buffer>
int2str:
	addi $sp, $sp, -4       # Dich chuyen con tro stack
    	sw $ra, 0($sp)          # luu return address

	la $a1, buffer

# Giai doan chuyen thanh chuoi
    	li $t1, 10
    	move $t2, $a1 		# Luu dia chi bat dau cua chuoi
convert_digit:
    	div $a0, $t1
    	mfhi $t0
    	addiu $t0, $t0, '0'
    	sb $t0, 0($a1)
    	addiu $a1, $a1, 1
    	mflo $a0
    	bnez $a0, convert_digit

    	sb $zero, 0($a1)	# Ket thuc chuoi

# Giai doan dao nguoc chuoi
    	addiu $a1, $a1, -1 	# Tro den ky tu cuoi cung (khong phai ky tu null)
    	jal reverseString

return:
	lw $ra, 0($sp)          # Khoi phuc return address
    	addi $sp, $sp, 4        # Di chuyen con tro stack tro lai
    	jr $ra
    	
    	
    	
# ----- Function 6: --------------------------------------------------------------------------
# Name: reverseString -> dao nguoc chuoi
# Thong so thanh ghi:
#	$a0: dia chi bat dau chuoi
# 	$a1: dia chi ket thuc chuoi (truoc ki tu null)
reverseString:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, buffer
	addi $sp, $sp, -4
	sw $ra, 0($sp)

# Vong lap dao nguoc chuoi
reverse_loop:
    	lb $t0, 0($a0)      # Lay ky tu dau chuoi
    	lb $t1, 0($a1)      # Lay ky tu cuoi chuoi
    	sb $t0, 0($a1)      # Dat ky tu dao vao cuoi
    	sb $t1, 0($a0)      # Dat ky tu cuoi vao dau
    	
    	jal string_length	
    	
    	addi $a0, $a0, 1   		# Tang dia chi dau tien 1 don vi
    	subi $a1, $a1, 1   		# Giam dia chi cuoi cung 1 don vi
    	bgt $a0, $a1, reverse_loop 	# Lap lai den khi duyet het chuoi
    	
end_reverse:
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
    	jr $ra
    	
    	
# ----- Function 7: --------------------------------------------------------------------------
# Name: string_length -> Tim chieu dai chuoi
# Thong so thanh ghi:
#	$a0: dia chi bat dau chuoi
# 	$v0: ket qua chieu dai chuoi (khong gom ki tu null)
string_length:
	addi $sp, $sp, -16
	sw $s0, 12($sp)
	sw $ra, 8($sp)
	sw $t0, 4($sp)
	sw $t1, 0($sp)
	
    	move $t0, $a0  # Sao chep dia chi chuoi vao $t0
    	li $s0, 0      # Khoi tao bien dem chieu dai

length_loop:
    	lb $t1, 0($t0) 		# Nap ki tu hien tai vao chuoi
    	beqz $t1, end_length 	# Neu la null, ket thuc vong lap
    	addiu $s0, $s0, 1    	# Tang bien dem chieu dai 1 don vi
    	addiu $t0, $t0, 1    	# Tang dia chi chuoi 1 don vi
    	j length_loop        	# Lap lai cho ki tu tiep theo

end_length:
	writeToFile($t6, buffer, $s0)

	lw $t1, 0($sp)
	lw $t0, 4($sp)
	lw $ra, 8($sp)
	lw $s0, 12($sp)
	addi $sp, $sp, 16

    	jr $ra     	
