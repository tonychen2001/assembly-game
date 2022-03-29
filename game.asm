#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Tony Chen, 1005994872, chento24, tonyc.chen@mail.utoronto.ca
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
# - Milestone 2 (choose the one the applies)
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
# - yes, and please share this project github link as well!
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

.eqv	PURPLE_STONE1	0x00d400f9	# Main color of purple stone
.eqv	PURPLE_STONE2	0x00e980fc	# Secondary color of purple stone
.eqv	PURPLE_STONE3	0x00f1befa	# Tertiary color of purple stone
.eqv	PURPLE_LOCATION	0x1000afc8	# Location of purple stone (x: 50, y:47)
.eqv	BLUE_STONE1	0x00304ffe	# Main color of blue stone
.eqv	BLUE_STONE2	0x00859bff	# Secondary color of blue stone
.eqv	BLUE_STONE3	0x00bbc6fc	# Tertiary color of blue stone
.eqv	BLUE_LOCATION	0x10008be4	# Location of blue stone (x: 57, y:11)
.eqv	COL_STONE_LOC	0x1000ba04	# Location of collected stones


.data

# Player info array: 
# [0]: address of top left unit of player hitbox
# [1]: state (0: standing, 1: jumping, 2: falling)
# [2]: duration of current state
# [3]: health (0 - 3)
# [4]: hurt (0: normal, >0: recently hit)
Player:		.word	0x1000ad08, 0, 0, 3, 0
Level:		.word	1

.text 
main:
	# Initialize Game State
init_game:
	jal CLEAR
	# init level
	li $t0, 1
	la $t1, Level
	sw $t0, 0($t1)
	
	# init player
	la $s0, Player
	li $t0, 0x1000ad08
	sw $t0, 0($s0)		# set initial player location in lvl 1
	sw $zero, 4($s0)	# set initial player state to standing
	sw $zero, 8($s0)	# set initial duration of current player state to 0
	li $t0, 3
	sw $t0, 12($s0)		# set initial health of player to 3
	sw $zero, 16($s0)	# set hurt to 0
	
	jal DRAW_HEALTH
	
	jal DRAW_PLAYER
	
	li $a0, PURPLE_STONE1	# pass primary color argument
	li $a1, PURPLE_STONE2	# pass secondary color argument
	li $a2, PURPLE_STONE3	# pass tertiary color argument
	li $a3, PURPLE_LOCATION	# pass address of top left corner of stone hitbox (x: 50, y:47)
	jal DRAW_STONE
	
	li $a0, BLUE_STONE1	# pass primary color argument
	li $a1, BLUE_STONE2	# pass secondary color argument
	li $a2, BLUE_STONE3	# pass tertiary color argument
	li $a3, BLUE_LOCATION	# pass address of top left corner of stone hitbox (x: 57, y:11)
	jal DRAW_STONE
	
	jal DRAW_ENEMY
	
	jal DRAW_LEVEL1

	# Enter the main game loop
game_loop:
	# clear all player character units
	jal CLEAR_PLAYER
	
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened	# handle user input
	# otherwise, no key press
	j update_player_state
	
keypress_happened:
	lw $t2, 4($t9)
	beq $t2, 112, keypress_p
	beq $t2, 119, keypress_w
	beq $t2, 97, keypress_a
	beq $t2, 100, keypress_d
	j update_player_state
	
keypress_p:
	# restart the game
	j init_game
	
keypress_w:
	lw $t0, 4($s0)			# t0 = state of player character
	
	bne $t0, 0, update_player_state	# if currently in the air, ignore jump
	li $t0, 1		
	sw $t0, 4($s0)			# set player state to 1 (jumping)
	li $t0, 0		
	sw $t0, 8($s0)			# set duration of current player state to 0
	
	j update_player_state
	
keypress_a:
	lw $t1, 0($s0)
	li $t2, BASE_ADDRESS
	
	# Determine if player can move left
	sub $t2, $t1, $t2
	srl $t2, $t2, 2			# t2 = unit number of players current location
	li $t3, 64
	div $t2, $t3
	mfhi $t2			# t2 = current players x-coordinate
	
	beq $t2, $zero, update_player_state	# If current player x-coordinate = 0, then do not move left
	
	# If platform to the left of user, do not move left
	li $t2, PLATFORM_COL
	addi $t1, $t1, -4
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	
	# If here, player can move left
	
	# clear all player character units
	#jal CLEAR_PLAYER
	
	# move the character left
	lw $t1, 0($s0)
	addi $t1, $t1, -4
	sw $t1, 0($s0)
	#jal DRAW_PLAYER
	
	j update_player_state
	
keypress_d:
	lw $t1, 0($s0)
	li $t2, BASE_ADDRESS
	
	# Determine if player can move right
	sub $t2, $t1, $t2
	srl $t2, $t2, 2			# t2 = unit number of players current location
	li $t3, 64
	div $t2, $t3
	mfhi $t2			# t2 = current players x-coordinate
	
	li $t3, 59
	beq $t2, $t3, update_player_state	# If current player x-coordinate = 59, then do not move right
	
	# If platform to the right of user, do not move right
	li $t2, PLATFORM_COL
	addi $t1, $t1, 20
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	addi $t1, $t1, NEXT_ROW_OFFSET
	lw $t0, 0($t1)
	beq $t0, $t2, update_player_state
	
	# If here, player can move right
	
	# clear all player character units
	#jal CLEAR_PLAYER
	
	# move the character right
	lw $t1, 0($s0)
	addi $t1, $t1, 4
	sw $t1, 0($s0)
	#jal DRAW_PLAYER
	
	j update_player_state

update_player_state:
	lw $t0, 4($s0)		# t0 = player state
	
	# Check if player is currently in jump state
	li $t1, 1
	beq $t0, $t1, jump_state
	
	# Check if player is currently in falling state
	li $t1, 2
	beq $t0, $t1, fall_state
	
	# otherwise player currently in standing state
	
	# check if player walked off platform
	# set t0 to unit below character
	lw $t0, 0($s0)			
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET

	li $t2, PLATFORM_COL		# t2 = platform color
	
	# if character is on a platform, stay in standing state
	lw $t3, 0($t0)
	beq $t3, $t2, check_collision
	lw $t3, 4($t0)
	beq $t3, $t2, check_collision
	lw $t3, 8($t0)
	beq $t3, $t2, check_collision
	lw $t3, 12($t0)
	beq $t3, $t2, check_collision
	lw $t3, 16($t0)
	beq $t3, $t2, check_collision
	# otherwise character not on a platform, then set to falling state
	j set_fall_state
jump_state:
	# check if collision immediately above player
	lw $t0, 0($s0)			# t0 = player location
	li $t1, NEXT_ROW_OFFSET		# t1 = offset to shift location by 1 row
	li $t5, PLATFORM_COL		# t5 = platform color
	
	sub $t4, $t0, $t1		# t4 = address of row of above player location
	lw $t3, 0($t4)
	beq $t3, $t5, set_fall_state
	lw $t3, 4($t4)
	beq $t3, $t5, set_fall_state
	lw $t3, 8($t4)
	beq $t3, $t5, set_fall_state
	lw $t3, 12($t4)
	beq $t3, $t5, set_fall_state
	lw $t3, 16($t4)
	beq $t3, $t5, set_fall_state
	
	lw $t2, 8($s0)			# t2 = duration of player in current state
	
	# determine speed of jump depending on duration of player in current state
	# speed of jump becomes slower over time to imitate the effect of gravity
	li $t3, 2
	ble $t2, $t3, try_jump3
	li $t3, 5
	ble $t2, $t3, try_jump2
	j jump1
	
try_jump3:
	# try to jump up 3 units, otherwise jump up maximum number of units possible
	
	sub $t4, $t4, $t1		# t4 = address of 2 rows of above current player location
	lw $t3, 0($t4)
	beq $t3, $t5, jump1
	lw $t3, 4($t4)
	beq $t3, $t5, jump1
	lw $t3, 8($t4)
	beq $t3, $t5, jump1
	lw $t3, 12($t4)
	beq $t3, $t5, jump1
	lw $t3, 16($t4)
	beq $t3, $t5, jump1
	
	sub $t4, $t4, $t1		# t4 = address of 3 rows of above current player location
	lw $t3, 0($t4)
	beq $t3, $t5, jump2
	lw $t3, 4($t4)
	beq $t3, $t5, jump2
	lw $t3, 8($t4)
	beq $t3, $t5, jump2
	lw $t3, 12($t4)
	beq $t3, $t5, jump2
	lw $t3, 16($t4)
	beq $t3, $t5, jump2
	
	j jump3	# jump up 3 units


try_jump2:
	# try to jump up 2 units, otherwise jump up maximum number of units possible
	sub $t4, $t4, $t1		# t4 = address of 2 rows of above current player location
	lw $t3, 0($t4)
	beq $t3, $t5, jump1
	lw $t3, 4($t4)
	beq $t3, $t5, jump1
	lw $t3, 8($t4)
	beq $t3, $t5, jump1
	lw $t3, 12($t4)
	beq $t3, $t5, jump1
	lw $t3, 16($t4)
	beq $t3, $t5, jump1
	
	j jump2	# jump up 2 units

jump3:
	#jal CLEAR_PLAYER
	
	lw $t0, 0($s0)
	li $t1, NEXT_ROW_OFFSET
	# set t0 = 3 units above current player location
	sub $t0, $t0, $t1
	sub $t0, $t0, $t1
	sub $t0, $t0, $t1
	
	sw $t0, 0($s0)		# move player location 3 units up
	#jal DRAW_PLAYER
	j end_jump
jump2:
	#jal CLEAR_PLAYER
	
	lw $t0, 0($s0)
	li $t1, NEXT_ROW_OFFSET
	# set t0 = 2 units above current player location
	sub $t0, $t0, $t1
	sub $t0, $t0, $t1
	
	sw $t0, 0($s0)		# move player location 2 units up
	#jal DRAW_PLAYER
	j end_jump
jump1:
	#jal CLEAR_PLAYER
	
	lw $t0, 0($s0)
	li $t1, NEXT_ROW_OFFSET
	# set t0 = 1 unit above current player location
	sub $t0, $t0, $t1
	
	sw $t0, 0($s0)		# move player location 1 unit up
	#jal DRAW_PLAYER
	j end_jump
end_jump:
	lw $t0, 0($s0)
	li $t1, NEXT_ROW_OFFSET
	li $t5, PLATFORM_COL
	
	# set state to falling if collision or duration of jump = 11
	sub $t4, $t0, $t1	# t4 = 1 unit above current player location
	lw $t3, 0($t4)
	beq $t3, $t5, set_fall_state
	lw $t3, 4($t4)
	beq $t3, $t5, set_fall_state
	lw $t3, 8($t4)
	beq $t3, $t5, set_fall_state
	lw $t3, 12($t4)
	beq $t3, $t5, set_fall_state
	lw $t3, 16($t4)
	beq $t3, $t5, set_fall_state
	
	lw $t0, 8($s0)
	li $t1, 11
	beq $t0, $t1, set_fall_state
	
	# increment duration of current state
	addi $t0, $t0, 1
	sw $t0, 8($s0)
	
	j check_collision

set_fall_state:
	# Set the state of the player to falling
	li $t0, 2
	sw $t0, 4($s0)
	sw $zero, 8($s0)
	
	j check_collision

fall_state:
	# check if player standing on platform
	
	lw $t0, 0($s0)			# t0 = current player location
	# set t0 to unit below character			
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET

	li $t2, PLATFORM_COL		# t2 = platform color
	
	# if character is on a platform, set player state to standing
	lw $t3, 0($t0)
	beq $t3, $t2, set_stand_state
	lw $t3, 4($t0)
	beq $t3, $t2, set_stand_state
	lw $t3, 8($t0)
	beq $t3, $t2, set_stand_state
	lw $t3, 12($t0)
	beq $t3, $t2, set_stand_state
	lw $t3, 16($t0)
	beq $t3, $t2, set_stand_state
	
	lw $t1, 8($s0)			# t1 = duration of player in current state
	
	# determine speed of fall depending on duration of player in current state
	# speed of falling becomes faster over time to imitate the effect of gravity
	li $t3, 7
	ble $t1, $t3, fall1

try_fall2:
	# try to fall 2 units, otherwise fall only 1 unit
	
	addi $t0, $t0, NEXT_ROW_OFFSET	# t0 = address of 2 units below characters feet
	lw $t3, 0($t0)
	beq $t3, $t2, fall1
	lw $t3, 4($t0)
	beq $t3, $t2, fall1
	lw $t3, 8($t0)
	beq $t3, $t2, fall1
	lw $t3, 12($t0)
	beq $t3, $t2, fall1
	lw $t3, 16($t0)
	beq $t3, $t2, fall1
	
fall2:
	#jal CLEAR_PLAYER
	
	lw $t0, 0($s0)
	# set t0 to 2 units below current player location			
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	sw $t0, 0($s0)
	
	#jal DRAW_PLAYER
	j end_fall

fall1:
	#jal CLEAR_PLAYER
	
	lw $t0, 0($s0)
	# set t0 to 1 unit below current player location			
	addi $t0, $t0, NEXT_ROW_OFFSET
	sw $t0, 0($s0)
	
	#jal DRAW_PLAYER
	j end_fall
	
end_fall:
	lw $t0, 0($s0)			# t0 = current player location
	# set t0 to unit below character			
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET
	addi $t0, $t0, NEXT_ROW_OFFSET

	li $t2, PLATFORM_COL		# t2 = platform color
	
	# if character is on a platform, set player state to standing
	lw $t3, 0($t0)
	beq $t3, $t2, set_stand_state
	lw $t3, 4($t0)
	beq $t3, $t2, set_stand_state
	lw $t3, 8($t0)
	beq $t3, $t2, set_stand_state
	lw $t3, 12($t0)
	beq $t3, $t2, set_stand_state
	lw $t3, 16($t0)
	beq $t3, $t2, set_stand_state
	
	# increment duration of current state
	lw $t0, 8($s0)
	addi $t0, $t0, 1
	sw $t0, 8($s0)
	
	j check_collision
	
set_stand_state:
	# set the state of the player to standing
	sw $zero, 4($s0)
	sw $zero, 8($s0)
	
	j check_collision

check_collision:
	# Check for player collision with various objects and respond accordingly
	lw $t0, 0($s0)
	
	li $t1, PURPLE_STONE1
	li $t2, BLUE_STONE1
	#li $t3, BLUE_STONE1
	#li $t4, BLUE_STONE1
	#li $t5, BLUE_STONE1
	#li $t6, BLUE_STONE1
	li $t7, 0x00ff1745	# t7 = enemy color
	
	lw $t9, 0($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 4($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 8($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 12($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 16($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	addi $t0, $t0, NEXT_ROW_OFFSET
	lw $t9, 0($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 16($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	addi $t0, $t0, NEXT_ROW_OFFSET
	lw $t9, 0($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 16($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	addi $t0, $t0, NEXT_ROW_OFFSET
	lw $t9, 0($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 16($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	addi $t0, $t0, NEXT_ROW_OFFSET
	lw $t9, 0($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 16($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	addi $t0, $t0, NEXT_ROW_OFFSET
	lw $t9, 0($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 16($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	addi $t0, $t0, NEXT_ROW_OFFSET
	lw $t9, 0($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 16($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	addi $t0, $t0, NEXT_ROW_OFFSET
	lw $t9, 0($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 16($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	addi $t0, $t0, NEXT_ROW_OFFSET
	lw $t9, 0($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 4($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 8($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 12($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	lw $t9, 16($t0)
	beq $t9, $t1, collect_purple
	beq $t9, $t2, collect_blue
	beq $t9, $t7, enemy_collision
	
	j sleep_game_loop
	
collect_purple:
	# Player collected the purple stone so move it to the collected bar
	li $a0, PURPLE_LOCATION
	jal CLEAR_STONE
	
	li $a0, PURPLE_STONE1
	li $a1, PURPLE_STONE2
	li $a2, PURPLE_STONE3
	li $a3, COL_STONE_LOC
	
	jal DRAW_STONE
	
	j sleep_game_loop

collect_blue:
	# Player collected the blue stone so move it to the collected bar
	li $a0, BLUE_LOCATION
	jal CLEAR_STONE
	
	li $a0, BLUE_STONE1
	li $a1, BLUE_STONE2
	li $a2, BLUE_STONE3
	li $a3, COL_STONE_LOC
	addi $a3, $a3, 16
	
	jal DRAW_STONE
	
	j sleep_game_loop

enemy_collision:
	# Collision with enemy drops health by 2 hearts
	
	# lower player health by 2
	lw $t0, 12($s0)
	addi $t0, $t0, -2
	sw $t0, 12($s0)
	
	# TODO: Check health and end game if necessary
	
	jal CLEAR_HEALTH
	jal DRAW_HEALTH
	
	
	# set player hurt indicator to 10 (player will be hurt for 10 cycles)
	li $t0, 10
	sw $t0, 16($s0)
	
	j sleep_game_loop

sleep_game_loop:
	# Draw the player at the current location
	jal DRAW_PLAYER
	
	# Sleep and jump back to start of the main game loop
	li $v0, 32
	li $a0, SLEEP_TIME
	syscall
	j game_loop


END:
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
	la $t4, Player
	addi $t4, $t4, 12
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

# ------------ Clear Health Indicator ------------ #
CLEAR_HEALTH:
	li $t0, BACKGROUND_COL		# t0 = primary health color
	
	# Clear first heart
	li $t3, 0x1000bab8		# address of unit (x: 45, 58)
	sw $t0, 4($t3)
	sw $t0, 12($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 0($t3)
	sw $t0, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	sw $t0, 16($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 0($t3)
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
	
	# Clear second heart
	li $t3, 0x1000bad0		# address of unit (x: 51, 58)
	sw $t0, 4($t3)
	sw $t0, 12($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 0($t3)
	sw $t0, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	sw $t0, 16($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 0($t3)
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
	
	# Clear third heart
	li $t3, 0x1000bae8		# address of unit (x: 57, 58)
	sw $t0, 4($t3)
	sw $t0, 12($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 0($t3)
	sw $t0, 4($t3)
	sw $t0, 8($t3)
	sw $t0, 12($t3)
	sw $t0, 16($t3)
	addi $t3, $t3, NEXT_ROW_OFFSET	# jump to next row
	sw $t0, 0($t3)
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
	

# ------------ Draw Player Character ------------ #
DRAW_PLAYER:

	la $t4, Player
	lw $t5, 16($t4)				# t5 = player hurt indicator
	bne $t5, $zero, draw_player_hurt	# if player hurt, use hurt skin color
	# otherwise, player not hurt so use normal skin color
	li $t0, 0x009675cd			# t0 = primary normal player color (skin)
	j draw_player_end
	
draw_player_hurt:
	li $t0, 0x00c2185c			# t0 = primary hurt player color (skin)
	# decrement the player hurt indicator
	addi $t5, $t5, -1
	sw $t5, 16($t4)

draw_player_end:	
	
	li $t1, 0x00ffeb3b			# t1 = secondary player color (armour)
	li $t2, 0x00795548			# t2 = tertiary player color (clothes)
	li $t3, 0x00ffc107			# t3 = glove color
	
	lw $t4, 0($t4)				# t4 = top left unit of player hitbox
	
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
	
	
# ------------ Clear Player Character ------------ #
CLEAR_PLAYER:
	li $t0, BACKGROUND_COL
	la $t1, Player
	lw $t1, 0($t1)		# t1 = current player loc

	# reset all player units
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	sw $t0, 0($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	sw $t0, 16($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	sw $t0, 0($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	sw $t0, 16($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	sw $t0, 0($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	sw $t0, 16($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	sw $t0, 0($t1)
	sw $t0, 4($t1)
	sw $t0, 8($t1)
	sw $t0, 12($t1)
	sw $t0, 16($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	sw $t0, 4($t1)
	sw $t0, 12($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	sw $t0, 4($t1)
	sw $t0, 12($t1)
	addi $t1, $t1, NEXT_ROW_OFFSET
	sw $t0, 4($t1)
	sw $t0, 12($t1)
	
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
	move $t2, $a2	# t2 = stone teriary color
	move $t3, $a3	# t3 = top left corner of stone
	
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
	
# ------------ Clear Stone Pickups ------------ #
	# a0 = top left corner of stone
CLEAR_STONE:
	move $t0, $a0	# t0 = address top left corner of stone
	li $t1, BACKGROUND_COL
	
	sw $t1, 4($t0)
	addi $t0, $t0, NEXT_ROW_OFFSET
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, NEXT_ROW_OFFSET
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, NEXT_ROW_OFFSET
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	addi $t0, $t0, NEXT_ROW_OFFSET
	sw $t1, 4($t0)
	
	jr $ra
	

# ------------ Draw Level 1 Platforms ------------ #
DRAW_LEVEL1:
	li $t0, PLATFORM_COL	# t0 = platform color
	li $t2, PLATFORM_WIDTH	# t2 = platform width
	
	# Draw the ceiling
	li $t1, BASE_ADDRESS
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
