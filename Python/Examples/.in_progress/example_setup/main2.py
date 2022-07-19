import requests

response = requests.get('https://randomuser.me/api/?results=5')
data = response.json()

for user in data['results']:
    print(user['name']['first'])