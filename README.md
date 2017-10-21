# minilang

# 背景

Tech-Nightの大場さん

  < "Rubyは式木にparseされたものインタプリタがバイトコードにしてRubyVMが実行してるよ"

Me

  < コンンパイルしない言語ってどうやって動いてるんだろう?



# 結論

Q. Rubyはどうやって動いている?

A.
```
ソースコード
  => 文字解析

トークン列
  => 構文解析

式木
  => コンパイル

バイトコード
  => RubyVM  => x
```




# 参考

- パーサー(構文解析器)

https://www.slideshare.net/takahashim/what-is-parser


- Rubyの式木(AST)を見る方法

例えば、
`ruby -e "(1 + 2)*3" --dump=parsetree`


- Rubyバイトコード見る方法

https://qiita.com/Altech/items/5730c44df9c2ceafa98c

`disasm`ファイルを作成して
```
#!/usr/bin/env ruby

puts RubyVM::InstructionSequence.new(DATA).disassemble
```

実行する
```
$ ./disasm
```

- ちなみに、バイトコードキャッシュ

一度読み込まれたソースコードのバイトコードはキャッシュされているらしい > Ruby 2.3.0


