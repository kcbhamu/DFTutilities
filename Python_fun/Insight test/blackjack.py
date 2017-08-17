# This is a blackjack code
import random

game_odds=input('gaming oddds? (Press enter to use default value=1.5 ) ')
tot_deck=input('how many decks? (Press enter to use default value=4) ')

if len(game_odds) == 0 :
	game_odds=1.5
else :
	game_odds=float(game_odds)

if len(tot_deck) == 0 :
	tot_deck=4
else :
	tot_deck=int(tot_deck)

# Define functions =================================================================================
# calculate total point
def point_counter(inp_cards):
	tot_point=[0,0]
	for n in range(len(inp_cards)):
		if inp_cards[n] >= 10:
			tot_point[0]=tot_point[0]+10
			tot_point[1]=tot_point[1]+10
		elif inp_cards[n] == 1:
			tot_point[0]=tot_point[0]+1
			tot_point[1]=tot_point[1]+11
		else :
			tot_point[0]=tot_point[0]+inp_cards[n]
			tot_point[1]=tot_point[1]+inp_cards[n]
	tot_point.sort()
	return tot_point

# number 1~13 to card symbol converter
def num2sym(inp_cards):
	sym_cards=[]
	for n in range(len(inp_cards)):
		if inp_cards[n] == 11:
			sym_cards=sym_cards+['J']
		elif inp_cards[n] == 12:
			sym_cards=sym_cards+['Q']
		elif inp_cards[n] == 13:
			sym_cards=sym_cards+['K']
		elif inp_cards[n] == 1:
			sym_cards=sym_cards+['A']
		else :
			sym_cards=sym_cards+[str(inp_cards[n])]
	return sym_cards

# Define class =====================================================================================	
class player:
	def set_player(self,chip,bet,card=[]):
		self.chip=chip
		self.bet=bet
		self.card=card
	def point(self):
		tot_point=point_counter(self.card)
		return tot_point

class dealer:
	def set_dealer(self,card=[]):
		self.card=card
	def point(self):
		tot_point=point_counter(self.card)
		return tot_point
		
class referee:	
	def check_card(self,dealer,player):
		self.dealer_card=dealer.card
		self.player_card=player.card
		self.dealer_point=dealer.point()
		self.player_point=player.point()
	def tell_info(self):
		print('  ')
		print('Dealer Card:',num2sym([self.dealer_card[0]]))
		print('Your card:', num2sym(self.player_card),' , ','your point=',self.player_point[0],' / ',self.player_point[1])
	def declare_winner(self):
		fin_point=[0,0]
		if self.dealer_point[1] <= 21:
			fin_point[0]=self.dealer_point[1]
		elif self.dealer_point[0] <= 21  :
			fin_point[0]=self.dealer_point[0]
		
		if self.player_point[1] <= 21:
			fin_point[1]=self.player_point[1]
		elif self.player_point[0] <= 21  :
			fin_point[1]=self.player_point[0]
		
		print('')
		print('----- Result -----')
		print('Dealer Card: ' , num2sym(self.dealer_card),' , ','Dealer Point (0=bursting!): ', fin_point[0])
		print('Player Card: ' , num2sym(self.player_card),' , ','Player Point (0=bursting!): ', fin_point[1])
		
		if fin_point[0] > fin_point[1] :
			winner=0 # dealer
			print('=> Dealer Wins! You lose your bets!')
		elif fin_point[1] > fin_point[0] :
			winner=1 # player
			print('=> Player Wins! You earn the gaming odds times your bets!')
		else :
			winner=-1 # tie
			print('=> Tie! Take your chips back!')
		return winner

# ==================================================================================================
# Shuffle Cards
player=player()
dealer=dealer()
referee=referee()
deck=list(range(1,14))*4*tot_deck; random.shuffle(deck)
card_count=-1
player.set_player(100,0)
new_round='y'

while new_round=='y' :
	# set bet
	print('============ Game Start! =================')
	print('Your total chips= ', player.chip)
	player.bet=int(input('How many chips to bet? (at least 1 chip, integer only!) '))
	if (player.bet < 1) or (player.bet > player.chip)  :
		print('Error! Reset Your Bet to 1')
		player.bet=1
		
	# assign first hand
	dealer.card=[deck[card_count+1],deck[card_count+2]]
	player.card=[deck[card_count+3],deck[card_count+4]]
	#info_teller(dealer.card,player.card)
	referee.check_card(dealer,player)
	referee.tell_info()
	card_count=card_count+3
	
	# player's hitting and standing
	while 1==1 :
		player_hitting=(input('Do you want more card? (y/n)  '))
		if player_hitting == 'y' :
			card_count=card_count+1
			player.card=player.card+[deck[card_count]]
			referee.check_card(dealer,player)
			referee.tell_info()
			player_point=player.point()
			if player_point[0] > 21 :
				print('busting!')
				break	
		elif player_hitting == 'n' :
			break	

	# dealer's hitting and standing
	while  1==1 :
		dealer_point=dealer.point()
		if dealer_point[1] < 17:
			dealer_hitting=1
		elif (dealer_point[1] > 21) and (dealer_point[0] <17):
			dealer_hitting=1
		else :
			break
		if dealer_hitting==1 :
			card_count=card_count+1
			dealer.card=dealer.card+[deck[card_count]]
			
	# declare winner & recalculate chips
	referee.check_card(dealer,player)
	winner=referee.declare_winner()	
	if winner==0 : # dealer wins
		player.chip=player.chip-player.bet
	elif winner==1 : # player wins
		player.chip=player.chip+0.5*player.bet
	print('=> Your new total chips is: ',player.chip)
	
	# New Game
	print('')
	new_round=input('Want to have a new game? (y/n) ')
	print('')
	
	if (player.chip <= 0) :
		print('Sorry! You get bankruptcy! Please get out!')
		break




