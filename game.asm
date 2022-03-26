#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.eqv	SLEEP_TIME	40		# Sleep time (ms)
.eqv	BASE_ADDRESS	0x10008000	# Address of the first unit of the frame
.eqv	BACKGROUND_COL	0x00000000	# Background color of game
.eqv	PLATFORM_COL	0x00bf360c	# RGB color of platform
.eqv	PLATFORM_WIDTH	3
.eqv	NEXT_ROW_OFFSET	0x00000100	# offset to get to the address of the next row in the frame

.data

Health:	.word		3
Level:	.word		1

 
.text 
main:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display 
	li $t1, 0xff0000   # $t1 stores the red colour code 
	li $t2, 0x00ff00   # $t2 stores the green colour code 
	li $t3, 0x0000ff   # $t3 stores the blue colour code 
  
	sw $t1, 0($t0)  # paint the first (top-left) unit red.  
	sw $t2, 4($t0)  # paint the second unit on the first row green. Why $t0+4? 
	sw $t3, 256($t0)   # paint the first unit on the second row blue. Why +256?
	
	jal CLEAR

	# Initialize Game State
	
	# init level
	li $t0, 1
	la $t1, Level
	sw $t0, 0($t1)
	# init health
	li $t0, 3
	la $t1, Health
	sw $t0, 0($t1)
	
	jal DRAW_HEALTH
	
	jal DRAW_PLAYER
	
	li $a0, 0x00d400f9	# pass primary color argument
	li $a1, 0x00e980fc	# pass secondary color argument
	li $a2, 0x00f1befa	# pass tertiary color argument
	li $a3, 0x1000afc8	# pass address of top left corner of stone hitbox (x: 50, y:47)
	jal DRAW_STONE
	
	li $a0, 0x00304ffe	# pass primary color argument
	li $a1, 0x00859bff	# pass secondary color argument
	li $a2, 0x00bbc6fc	# pass tertiary color argument
	li $a3, 0x10008be4	# pass address of top left corner of stone hitbox (x: 50, y:47)
	jal DRAW_STONE
	
	jal DRAW_ENEMY
	
	jal DRAW_LEVEL1
 
	li $v0, 10 # terminate the program gracefully 
	syscall 


# ------------ Clear the Screen ------------ #
CLEAR:
	li $t0, BACKGROUND_COL
	li $t1, BASE_ADDRESS	# address of first unit in the first row
	li $t2, 64		# number of rows to clear
	li $t3, 0		# t3 counts the current row number
	# loop to clear reset all 64 rows of the frame
clear_start:
	bge $t3, $t2, end_clear
	sw $t0, 0($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	sw $t0, 16($t1)
	sw $t0, 20($t1)
	sw $t0, 24($t1)
	sw $t0, 28($t1)
	sw $t0, 32($t1)
	sw $t0, 36($t1)
	sw $t0, 40($t1)
	sw $t0, 44($t1)
	sw $t0, 48($t1)
	sw $t0, 52($t1)
	sw $t0, 56($t1)
	sw $t0, 60($t1)
	sw $t0, 64($t1)
	sw $t0, 68($t1)
	sw $t0, 72($t1)
	sw $t0, 76($t1)
	sw $t0, 80($t1)
	sw $t0, 84($t1)
	sw $t0, 88($t1)
	sw $t0, 92($t1)
	sw $t0, 96($t1)
	sw $t0, 100($t1)
	sw $t0, 104($t1)
	sw $t0, 108($t1)
	sw $t0, 112($t1)
	sw $t0, 116($t1)
	sw $t0, 120($t1)
	sw $t0, 124($t1)
	sw $t0, 128($t1)
	sw $t0, 132($t1)
	sw $t0, 136($t1)
	sw $t0, 140($t1)
	sw $t0, 144($t1)
	sw $t0, 148($t1)
	sw $t0, 152($t1)
	sw $t0, 156($t1)
	sw $t0, 160($t1)
	sw $t0, 164($t1)
	sw $t0, 168($t1)
	sw $t0, 172($t1)
	sw $t0, 176($t1)
	sw $t0, 180($t1)
	sw $t0, 184($t1)
	sw $t0, 188($t1)
	sw $t0, 192($t1)
	sw $t0, 196($t1)
	sw $t0, 200($t1)
	sw $t0, 204($t1)
	sw $t0, 208($t1)
	sw $t0, 212($t1)
	sw $t0, 216($t1)
	sw $t0, 220($t1)
	sw $t0, 224($t1)
	sw $t0, 228($t1)
	sw $t0, 232($t1)
	sw $t0, 236($t1)
	sw $t0, 240($t1)
	sw $t0, 244($t1)
	sw $t0, 248($t1)
	sw $t0, 252($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET	# jump to next row
	addi $t3, $t3, 1		# increment row counter
	j clear_start
end_clear:
	jr $ra

# ------------ Draw Health Indicator ------------ #
DRAW_HEALTH:
	li $t0, 0x00e91e62		# t0 = primary health color
	li $t1, 0x00f05289		# t1 = secondary health color
	li $t2, 0x00fcabc7		# t3 = tertiary health color
	
	# store the current health in t4
	la $t4, Health
	lw $t4, 0($t4)
	
	li $t5, 1
	blt $t4, $t5, END_HEALTH	# if health < 1, don't draw first heart
	
	# Draw first heart
	li $t3, 0x1000bab8		# address of unit (x: 45, 58)
	sw $t1, 4($t3)
	sw $t0, 12($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t1, 0($t3)
	sw $t2, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	sw $t0, 16($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t1, 0($t3)
	sw $t0, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	sw $t0, 16($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 8($t3)
	
	li $t5, 2
	blt $t4, $t5, END_HEALTH	# if health < 2, don't draw second heart
	
	# Draw second heart
	li $t3, 0x1000bad0		# address of unit (x: 51, 58)
	sw $t1, 4($t3)
	sw $t0, 12($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t1, 0($t3)
	sw $t2, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	sw $t0, 16($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t1, 0($t3)
	sw $t0, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	sw $t0, 16($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 8($t3)
	
	li $t5, 3
	blt $t4, $t5, END_HEALTH	# if health < 3, don't draw third heart
	
	# Draw third heart
	li $t3, 0x1000bae8		# address of unit (x: 57, 58)
	sw $t1, 4($t3)
	sw $t0, 12($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t1, 0($t3)
	sw $t2, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	sw $t0, 16($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t1, 0($t3)
	sw $t0, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	sw $t0, 16($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 8($t3)
	
END_HEALTH:
	jr $ra


# ------------ Draw Player Character ------------ #
DRAW_PLAYER:
	li $t0, 0x009675cd	# t0 = primary player color (skin)
	li $t1, 0x00ffeb3b	# t1 = secondary player color (armour)
	li $t2, 0x00795548	# t2 = tertiary player color (clothes)
	li $t3, 0x00ffc107	# t3 = glove color
	
	li $t4,	0x1000ad08	# t4 = top left unit of player hitbox
	sw $t0, 4($t4)
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t0, 4($t4)
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t1, 0($t4)
	sw $t1, 4($t4)
	sw $t0, 8($t4)
	sw $t1, 12($t4)
	sw $t1, 16($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t0, 0($t4)
	sw $t1, 4($t4)
	sw $t1, 8($t4)
	sw $t1, 12($t4)
	sw $t0, 16($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t0, 0($t4)
	sw $t2, 4($t4)
	sw $t2, 8($t4)
	sw $t2, 12($t4)
	sw $t3, 16($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t0, 0($t4)
	sw $t2, 4($t4)
	sw $t2, 8($t4)
	sw $t2, 12($t4)
	sw $t3, 16($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t2, 4($t4)
	sw $t2, 12($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t1, 4($t4)
	sw $t1, 12($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t2, 4($t4)
	sw $t2, 12($t4)
	
	jr $ra
	
# ------------ Draw Enemy Character ------------ #
DRAW_ENEMY:
	li $t0, 0x00ff1745	# t0 = primary player color
	li $t1, 0x00ffc107	# t1 = secondary player color
	li $t2, 0x0000bbd4	# t2 = tertiary player color
	
	li $t4,	0x10009d08	# t4 = top left unit of enemy hitbox	(x: 10, y: 29)
	sw $t0, 4($t4)
	sw $t1, 8($t4)
	sw $t0, 12($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t0, 4($t4)
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t0, 0($t4)
	sw $t0, 4($t4)
	sw $t2, 8($t4)
	sw $t0, 12($t4)
	sw $t0, 16($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t1, 0($t4)
	sw $t0, 4($t4)
	sw $t0, 8($t4)
	sw $t0, 12($t4)
	sw $t1, 16($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t0, 4($t4)
	sw $t0, 12($t4)
	addi $t4, $t4, NEXT_ROW_OFFSET
	sw $t2, 4($t4)
	sw $t2, 12($t4)
	
	jr $ra


# ------------ Draw Stone Pickups ------------ #
	# a0 = stone primary color
	# a1 = stone secondary color
	# a2 = stone teriary color
	# a3 = top left corner of stone
DRAW_STONE:
	move $t0, $a0	# t0 = stone primary color
	move $t1, $a1	# t1 = stone secondary color
	move $t2, $a2	#
	move $t3, $a3
	
	sw $t0, 4($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET
	sw $t0, 0($t3)
	sw $t2, 4($t3)
	sw $t0, 8($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET
	sw $t0, 0($t3)
	sw $t1, 4($t3)
	sw $t0, 8($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET
	sw $t0, 0($t3)
	sw $t1, 4($t3)
	sw $t0, 8($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET
	sw $t0, 4($t3)
	
	jr $ra
	

# ------------ Draw Level 1 Platforms ------------ #
DRAW_LEVEL1:
	li $t0, PLATFORM_COL	# t0 = platform color
	li $t2, PLATFORM_WIDTH	# t2 = platform width
	
	# Draw the first platform in level 1
	li $t1, 0x1000b600	# address of top left corner of 1st platform (x: 0, y: 54)
	li $t3, 0		# counter for the platform row
lvl1_1:
	bge $t3, $t2, end_lvl1_1
	sw $t0, 0($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	sw $t0, 16($t1)
	sw $t0, 20($t1)
	sw $t0, 24($t1)
	sw $t0, 28($t1)
	sw $t0, 32($t1)
	sw $t0, 36($t1)
	sw $t0, 40($t1)
	sw $t0, 44($t1)
	sw $t0, 48($t1)
	sw $t0, 52($t1)
	sw $t0, 56($t1)
	sw $t0, 60($t1)
	sw $t0, 64($t1)
	sw $t0, 68($t1)
	sw $t0, 72($t1)
	sw $t0, 76($t1)
	sw $t0, 80($t1)
	sw $t0, 84($t1)
	sw $t0, 88($t1)
	sw $t0, 92($t1)
	sw $t0, 96($t1)
	sw $t0, 100($t1)
	sw $t0, 104($t1)
	sw $t0, 108($t1)
	sw $t0, 112($t1)
	sw $t0, 116($t1)
	sw $t0, 120($t1)
	sw $t0, 124($t1)
	sw $t0, 128($t1)
	sw $t0, 132($t1)
	sw $t0, 136($t1)
	sw $t0, 140($t1)
	sw $t0, 144($t1)
	sw $t0, 148($t1)
	sw $t0, 152($t1)
	sw $t0, 156($t1)
	sw $t0, 160($t1)
	sw $t0, 164($t1)
	sw $t0, 168($t1)
	sw $t0, 172($t1)
	sw $t0, 176($t1)
	sw $t0, 180($t1)
	sw $t0, 184($t1)
	sw $t0, 188($t1)
	sw $t0, 192($t1)
	sw $t0, 196($t1)
	sw $t0, 200($t1)
	sw $t0, 204($t1)
	sw $t0, 208($t1)
	sw $t0, 212($t1)
	sw $t0, 216($t1)
	sw $t0, 220($t1)
	sw $t0, 224($t1)
	sw $t0, 228($t1)
	sw $t0, 232($t1)
	sw $t0, 236($t1)
	sw $t0, 240($t1)
	sw $t0, 244($t1)
	sw $t0, 248($t1)
	sw $t0, 252($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	addi $t3, $t3, 1
	j lvl1_1
end_lvl1_1:

	# Draw the third platform in level 1
	li $t1, 0x1000a400	# address of top left corner of 2nd platform (x: 0, y: 36)
	li $t3, 0		# counter for the platform row
lvl1_2:
	bge $t3, $t2, end_lvl1_2
	sw $t0, 0($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	sw $t0, 16($t1)
	sw $t0, 20($t1)
	sw $t0, 24($t1)
	sw $t0, 28($t1)
	sw $t0, 32($t1)
	sw $t0, 36($t1)
	sw $t0, 40($t1)
	sw $t0, 44($t1)
	sw $t0, 48($t1)
	sw $t0, 52($t1)
	sw $t0, 56($t1)
	sw $t0, 60($t1)
	sw $t0, 64($t1)
	sw $t0, 68($t1)
	sw $t0, 72($t1)
	sw $t0, 76($t1)
	sw $t0, 80($t1)
	sw $t0, 84($t1)
	sw $t0, 88($t1)
	sw $t0, 92($t1)
	sw $t0, 96($t1)
	sw $t0, 100($t1)
	sw $t0, 104($t1)
	sw $t0, 108($t1)
	sw $t0, 112($t1)
	sw $t0, 116($t1)
	sw $t0, 120($t1)
	sw $t0, 124($t1)
	sw $t0, 128($t1)
	sw $t0, 132($t1)
	sw $t0, 136($t1)
	sw $t0, 140($t1)
	sw $t0, 144($t1)
	sw $t0, 148($t1)
	sw $t0, 152($t1)
	sw $t0, 156($t1)
	sw $t0, 160($t1)
	sw $t0, 164($t1)
	sw $t0, 168($t1)
	sw $t0, 172($t1)
	sw $t0, 176($t1)
	sw $t0, 180($t1)
	sw $t0, 184($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	addi $t3, $t3, 1
	j lvl1_2
end_lvl1_2:

# Draw the third platform in level 1
	li $t1, 0x10009250	# address of top left corner of 3rd platform (x: 20, y: 18)
	li $t3, 0		# counter for the platform row
lvl1_3:
	bge $t3, $t2, end_lvl1_3
	sw $t0, 0($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	sw $t0, 16($t1)
	sw $t0, 20($t1)
	sw $t0, 24($t1)
	sw $t0, 28($t1)
	sw $t0, 32($t1)
	sw $t0, 36($t1)
	sw $t0, 40($t1)
	sw $t0, 44($t1)
	sw $t0, 48($t1)
	sw $t0, 52($t1)
	sw $t0, 56($t1)
	sw $t0, 60($t1)
	sw $t0, 64($t1)
	sw $t0, 68($t1)
	sw $t0, 72($t1)
	sw $t0, 76($t1)
	sw $t0, 80($t1)
	sw $t0, 84($t1)
	sw $t0, 88($t1)
	sw $t0, 92($t1)
	sw $t0, 96($t1)
	sw $t0, 100($t1)
	sw $t0, 104($t1)
	sw $t0, 108($t1)
	sw $t0, 112($t1)
	sw $t0, 116($t1)
	sw $t0, 120($t1)
	sw $t0, 124($t1)
	sw $t0, 128($t1)
	sw $t0, 132($t1)
	sw $t0, 136($t1)
	sw $t0, 140($t1)
	sw $t0, 144($t1)
	sw $t0, 148($t1)
	sw $t0, 152($t1)
	sw $t0, 156($t1)
	sw $t0, 160($t1)
	sw $t0, 164($t1)
	sw $t0, 168($t1)
	sw $t0, 172($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	addi $t3, $t3, 1
	j lvl1_3
end_lvl1_3:

	jr $ra
