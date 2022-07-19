class Purchase:
    def __init__(self, basket, buyer):
        self.basket = list(basket)
        self.buyer = buyer

    def __len__(self):
        return len(self.basket)


purchase = Purchase(['pen', 'book', 'pencil'], 'Python')
print(len(purchase))
