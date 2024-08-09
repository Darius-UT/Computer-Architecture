	.data
		int_arr: .word 0, 0, 0, 0, 0
			 .word 0, 0, 0, 0, 0
		int_N: 	.word 10
		stored_values: .space 20
		filename: .asciiz "INT10.BIN"
		buffer: .space 41  # Space for 10 integers (4 bytes each)
		str_comma: .asciiz ", "
		str_enter: .asciiz "\n"
		str_colons: .asciiz ": "
		str_step: .asciiz "Step "
		str_out: .asciiz "Sorted Array: "
	.text
	.globl mainFunction
	
# macro:
	.macro printInteger (%integer)
		addi $v0, $zero, 1
		move $a0, %integer
		syscall
	.end_macro
	
	.macro printString (%str)
		addi $v0, $zero, 4
		la $a0, %str
		syscall
	.end_macro


mainFunction:

	jal open_file
	jal read_data_from_file
	jal close_file	    	
	jal convert_data_from_file_to_arr		
	la $a0, int_arr
	lw $a1, int_N
	jal selectionSort
	printString(str_enter)
	printString(str_out)
	la $a0, int_arr
	jal printArr
# Xuat

# Ket thuc
	li $v0, 10
	syscall
	
################## Swap Function #######################################################################
# Function:
# $a0: dia chi dau tien cua mang
# $a2: chi so phan tu can swap1
# $a3: chi so phan tu can swap2
swap:
	mul $a2, $a2, 4		# Lay index1
	mul $a3, $a3, 4		# Lay index2
	
	add $t1, $a0, $a2	# Di chuyen den dia chi co index1
	add $t2, $a0, $a3	# Di chuyen den dia chi co index2
	
	lw $t3, 0($t1)		# Lay phan tu tai dia chi co index1
	lw $t4, 0($t2)		# Lay phan tu tai dia chi co index2
	
	sw $t3, 0($t2)		# Gan arr[index2] = arr[index1]
	sw $t4, 0($t1)		# Gan arr[index1] = arr[index2]
	
	jr $ra			# Ket thuc swap



################# Selection Sort Function ##############################################################
# Chuc nang: thuc hien sap xep cac phan tu trong mang theo giai thuat selection sort
# Cac thong so thanh ghi:
# 	$a0 = address(int_arr[0]): dia chi phan tu dau tien cua mang
# 	$a1 = int_N		: so phan tu cua mang (trong bai tap nay thi $a1 = 10)

# 	$t0 = i
# 	$t1 = j
# 	$t2 = min
# 	$t3 = addresss(arr[min])
# 	$t4 = address(arr[j])
# 	$t5 = int_N - 1
# 	$t6 = tmp (set less than)
# 	$t7 = count (so step dung de printArr)
# 	$t8 = $a0 (bien tam luu tru $a0)

# 	$s3 = arr[min]
# 	$s4 = arr[j]

selectionSort:
# Store cac preserved registers vao stack
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $s4, 4($sp)
	sw $s3, 0($sp)
# Bat dau ham:	
	li $t7, 0			# Khoi tao bien count = 0 (duoc dung khi printArr)
	addi $t5, $a1, -1		# $t5 = N - 1 (Upperbound cua vong lap for_i)
	li $t0, 0			# Khoi tao bien dem i = 0
for_i: 
	beq $t0, $t5, end_for_i		# Neu i == N - 1 thi ket thuc vong lap
	move $t2, $t0			# Gan min = i
	
	addi $t1, $t0, 1		# Khoi tao bien dem j = i + 1
	for_j:
		beq $t1, $a1, end_for_j		# Neu j == N thi thoat vong lap for_j
						# Nguoc lai:
		mul $t3, $t2, 4			
		add $t3, $a0, $t3
		lw $s3, 0($t3)			# Load phan tu arr[min]
		
		mul $t4, $t1, 4			
		add $t4, $a0, $t4
		lw $s4, 0($t4)			# Load phan tu arr[j]
		# if (arr[i] < arr[min]):
			slt $t6, $s4, $s3		# Neu arr[j] < arr[min] thi: min = j
			beqz $t6, end_if		# Nguoc lai: nhay den end_if
			move $t2, $t1
		end_if:
		
		addi $t1, $t1, 1		# j++ -> Tang bien dem 1 don vi
		j for_j				# Nhay ve for_j tim phan tu nho nhat trong mang
	end_for_j:
	
	beq $t2, $t0, here		# Neu min == i thi khong swap + khong in. Nguoc lai:
	move $a2, $t2			# Truyen tham so $a2 = min = $t2
	move $a3, $t0			# Truyen tham so $a3 = i = $t0
	jal swap			# swap ( arr[min], arr[i] )
	
	move $t8, $a0
	printString(str_step)
	addi $t7, $t7, 1
	printInteger($t7)
	printString(str_colons)
	la $a0, int_arr
	jal printArr
	printString(str_enter)
	move $a0, $t8
	
here:
	addi $t0, $t0, 1		# i++ -> Tang bien dem 1 don vi
	j for_i				# Nhay ve for_i tiep tuc sort cac phan tu con lai
	
end_for_i:
# Restore cac registers tu stack
	lw $s3, 0($sp)
	lw $s4, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
# return address
	jr $ra
	
################### Print Function #################################################################
# Chuc nang: in ra tat ca cac phan tu trong mang hien tai
# Thong so thanh ghi:	
# 	$a0 = address(int_arr[0])
# 	$a1 = int_N

# 	$t0 = i
# 	$t1 = address(arr[i])
# 	$t2 = arr[i]

printArr:
	addi $sp, $sp, -12
	sw $t0, 8($sp)
	sw $t1, 4($sp)
	sw $t2, 0($sp)
	
	move $t1, $a0		# register dung de duyet qua mang
	li $t0, 0		# Khoi tao bien diem i = 0
# In phan tu dau tien: 
	lw $t2, 0($t1)		# Load arr[0]
	printInteger($t2)	# In arr[0]
	addi $t0, $t0, 1	# i++ -> Tang bien dem 1 don vi
	addi $t1, $t1, 4	# $t4 += 4 -> chuyen con tro den vi tri phan tu tiep theo
# In cac phan tu con lai:
traverse:
	beq $t0, $a1, end_traverse	# Neu i == N thi thoat vong lap traverse. Neu khong thi:
	lw $t2, 0($t1)			# Nap phan tu arr[i]
	printString(str_comma)		# In dau phay ", "
	printInteger($t2)		# In phan tu arr[i]
	addi $t0, $t0, 1		# i++ -> Tang bien dem i 1 don vi
	addi $t1, $t1, 4		# $t1 += 4 -> chuyen con tro den vi tri phan tu tiep theo
	j traverse			# Nhay ve vong lap traverse duyet toan bo phan tu
end_traverse:
	lw $t2, 0($sp)
	lw $t1, 4($sp)
	lw $t0, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra				# Ket thuc ham printArr + return address


################### INPUT PROCESS #################################################################
open_file:
	la $a0, filename
    	li $a1, 0  	# Read mode
    	li $v0, 13
    	syscall
    	move $s6, $v0  	# Save the file descriptor
    	
    	jr $ra
    	
close_file:
	move $a0, $s6
    	li $v0, 16
    	syscall
    	
    	jr $ra
    	
read_data_from_file:
    	la $a1, buffer
    	li $a2, 40  # Number of bytes to read
    	move $a0, $s6
    	li $v0, 14
    	syscall
    	
    	jr $ra
    	
convert_data_from_file_to_arr:
	la $t0, buffer  		# Load the address of the buffer into $t0
	li $t2, 32
	li $t3, 0
	la $t4, stored_values
	la $t9, int_arr
	loop:
        	lb $t1, 0($t0)  	# Load a byte from the buffer
        	beqz $t1, is_space  	# Exit the loop if the byte is zero (end of string)
        	beq $t1, $t2, is_space
	        addi $t3,$t3,1
    		sb $t1, 0($t4)
	    	addiu $t4, $t4, 1
        	addi $t0, $t0, 1
        	j loop   
    		is_space:	
			li,$s7,0
			la $t4,stored_values 
			clear_loop:
				lb $t5, 0($t4)
				sub $t5, $t5, '0'
				li $t6,0
				li $t7,1
				add $t6,$t6,$t3
				subi $t6,$t6,1
			pow_loop:
				beqz $t6,end_loop2
				mul $t7,$t7,10
				subi $t6,$t6,1	
				j pow_loop
			end_loop2:
				mul $t5,$t5,$t7
				add $s7,$s7,$t5
				addiu $t4, $t4,1
				add $t3,$t3,-1
				bnez $t3,clear_loop
    	
	li	$v0, 1		# Load 4=print_string into $v0
	li	$a0, 0
	add $a0,$a0,$s7		# Load address of newline into $a0
	syscall			# Output the newline
	
	sw $s7, 0($t9)
	addiu $t9,$t9,4
		
	li	$v0, 4		# Load 4=print_string into $v0
	la	$a0, str_comma	# Load address of newline into $a0
	syscall			# Output the newline
	la $t4,stored_values 
    	addi $t0, $t0, 1
    	beqz $t1,end_loop
   	j loop

    	end_loop:
    	li	$v0, 4		# Load 4=print_string into $v0
	la	$a0, str_enter	# Load address of newline into $a0
	syscall    
   	jr $ra	

