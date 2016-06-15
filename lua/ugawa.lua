print('fjakljfda')
--配列
ary1 = {10,20,30}
print(ary1[1])
--連想配列
ary2 = {first=1,secound=2}
print(ary2.first)

a = {}
function a.test
	print("a")
end
a.test()

b ={}
function b:test2
	print("b")
end
b:test()

--条件分岐
print('Please enter number!!')
num = io.read()
if num % 2 == 0 then
	print('It is Even')
else
	print('It is Odd')
end

--繰り返し文
print('How many times do you repeat?')
numnum = io.read()
numnum = numnum + 1
i = 1

while i < numnum do
	print("Hello World");
	i = i + 1
end

-- 関数
function roop()
	print('Thank you')
	print('first number')
	fnum = io.read()
	print('secound number')
	snum = io.read()

	print('sum:'..fnum + snum)

end	

--関数実行
print('Please enter a 1 in order to perform a function')
numm = io.read()
if numm +1 == 2 then
	roop()
else
	print('You are bad!')

end

io.read()