-- このスクリプトを実行するためにコマンドプロンプトに
-- 「lua tarek-test.lua」を入力してください。

function some_math(a, b)
    local output
    output = math.sqrt(a * b)
    output = math.floor(output)
    return output + 3
end

-- 上記：関数の宣言    + + + + + +    下記：プログラムの流れ

-- 変数
local x_string
local x_number

-- ユーザー入力を読む
io.write("Please enter a number.\n")
io.flush()
x_string = io.read()
x_number = tonumber(x_string)

-- if分岐
if type(x_number) == "nil" then
    print("What you entered is not a number.")
    os.exit()
end

-- for文
for i=0, 10, 1 do
    print(some_math(x_number, i))
end

-- ユーザー入力を読む
io.write("\n")
io.flush()
x_string = io.read()
x_number = tonumber(x_string)
