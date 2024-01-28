def count_on_bits(number):
  count = 0
  for i in range(32):
    count += (number & (1 << i) != 0)
  return count

nums = [0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D, 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD]

lOnes = 0
lZeroes = 0

for n in nums:
  ones = count_on_bits(n)
  if (ones > lOnes):
    lOnes = ones
  zeroes = count_on_bits(~n)
  if (zeroes > lZeroes):
    lZeroes = zeroes

print(f"Largest ones: {lOnes} or {bin(lOnes)}")
print(f"Largest zeroes: {lZeroes} or {bin(lZeroes)}")



