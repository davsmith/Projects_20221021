# Create the superclass
class Monster(object):
    # Set up the class attribute, the same for all instances
    eats = 'food'

    # Define the __init__ method
    def __init__(self, name):
        # Set up an instance attribute, different for each instance
        self.name = name
        print('In the init method!')
        
    # Define a method for speaking behavior
    def speak(self):
        print(self.name + ' speaks')

    # Define a method for eating behavior
    def eat(self, meal):
        if meal == self.eats:
                print('Yum! I love ' + meal + '!')
        else:
                print(meal + '? Blech!  I wanted ' + self.eats + '!')

# # Create an instance of MonsterFood
my_monster = Monster('Spooky Snack')

# Call the methods on the new instance
# my_monster.speak()
# my_monster.eat('food')

# Create a subclass of Monster
class FrankenBurger(Monster):
        eats = 'hamburger patties'
        def speak(self):
            print('My name is ' + self.name + 'Burger')

my_frankenburger = FrankenBurger('Veggiesaurus')
my_frankenburger.speak()
my_frankenburger.eat('pickles')
my_frankenburger.eat('hamburger patties')

# Create a subclass of Monster
class CrummyMummy(Monster):
        eats = 'chocolate chips'
        def speak(self):
            print('My name is ' + self.name + 'Mummy')

my_mummy = CrummyMummy('Wrap')
my_mummy.speak()
my_mummy.eat('chocolate chips')

# Create a subclass of Monster
class WereWatermelon(Monster):
        eats = 'watermelon juice'
        def speak(self):
            print('My name is Were' + self.name)
my_melon = WereWatermelon('Seedy')
my_melon.speak()
my_melon.eat('chocolate chips')
my_melon.eat('watermelon juice')

monster_selection = input('What kind of monster to you want to create?  Select: frankenburger, crummymummy, or watermelon. ')
monster_name = input('What do you want to name your monster? ')
monster_meal = input('What will you feed your monster? ')
print
if monster_selection == 'frankenburger':
    monster_type = FrankenBurger
elif monster_selection == 'crummymummy':
    monster_type = CrummyMummy
elif monster_selection == 'werewatermelon':
    monster_type = WereWatermelon
else:
    monster_type = Monster

my_monster = monster_type(monster_name)
my_monster.speak()
my_monster.eat(monster_meal)