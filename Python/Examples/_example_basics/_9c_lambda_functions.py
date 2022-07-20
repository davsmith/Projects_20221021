''' Functions - Part C: Lambda functions () '''

# A lambda function is a small anonymous function.
# A lambda function can take any number of arguments,
#  but can only have one expression.
get_sum = lambda num1, num2: num1 + num2

print(get_sum(10, 3))
print(get_sum(get_sum(5, 2), 3))